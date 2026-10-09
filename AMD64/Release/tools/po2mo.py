#!/usr/bin/env python3
"""Compile a gettext .po to .mo (pure Python — no msgfmt/gettext binary needed).

The Tr toolchain's catalog compiler (Tr's "msgfmt"): any <lang>.po -> <lang>.mo, parsed at runtime by
the Qt-free tr::Translator. Generic — no project-specific knowledge. Single/multi-line msgid/msgstr
with standard escaping; no plurals/contexts (the Tr catalog is context-less by design).

  usage: po2mo.py <input.po> <output.mo>
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path


def unescape(text: str) -> str:
    out, i = [], 0
    while i < len(text):
        ch = text[i]
        if ch == "\\" and i + 1 < len(text):
            out.append({"n": "\n", "t": "\t", "r": "\r", "\"": "\"", "\\": "\\"}.get(text[i + 1], text[i + 1]))
            i += 2
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def parse_po(path: Path) -> dict[str, str]:
    entries: dict[str, str] = {}
    msgid: list[str] | None = None
    msgstr: list[str] | None = None
    target: list[str] | None = None

    def flush() -> None:
        if msgid is not None and msgstr is not None:
            key, value = "".join(msgid), "".join(msgstr)
            if key and value:
                entries[key] = value

    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("msgid "):
            flush()
            msgid, msgstr = [], None
            target = msgid
            target.append(unescape(line[len("msgid "):].strip().strip('"')))
        elif line.startswith("msgstr "):
            msgstr = []
            target = msgstr
            target.append(unescape(line[len("msgstr "):].strip().strip('"')))
        elif line.startswith('"') and target is not None:
            target.append(unescape(line.strip().strip('"')))
    flush()
    return entries


def write_mo(entries: dict[str, str], path: Path) -> None:
    keys = sorted(entries.keys())
    count = len(keys)
    header_size = 28
    table_size = count * 8
    data_start = header_size + table_size * 2
    blob = bytearray()
    originals: list[tuple[int, int]] = []
    translations: list[tuple[int, int]] = []

    def add(text: str) -> tuple[int, int]:
        data = text.encode("utf-8")
        offset = data_start + len(blob)
        blob.extend(data)
        blob.append(0)
        return len(data), offset

    for key in keys:
        originals.append(add(key))
    for key in keys:
        translations.append(add(entries[key]))

    out = bytearray()
    out += struct.pack("<I", 0x950412de)
    out += struct.pack("<I", 0)
    out += struct.pack("<I", count)
    out += struct.pack("<I", header_size)
    out += struct.pack("<I", header_size + table_size)
    out += struct.pack("<I", 0)
    out += struct.pack("<I", 0)
    for length, offset in originals:
        out += struct.pack("<II", length, offset)
    for length, offset in translations:
        out += struct.pack("<II", length, offset)
    out += blob

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(bytes(out))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("po", type=Path)
    parser.add_argument("mo", type=Path)
    args = parser.parse_args()
    if not args.po.is_file():
        print(f"missing po: {args.po}", file=sys.stderr)
        return 2
    entries = parse_po(args.po)
    write_mo(entries, args.mo)
    print(f"{args.po.name}: {len(entries)} translation(s) -> {args.mo}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
