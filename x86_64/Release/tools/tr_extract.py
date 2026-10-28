#!/usr/bin/env python3
"""Extract translatable source-literal strings for a Tr gettext catalog.

The Tr toolchain's string scanner (Tr's "lupdate"): generic, NO project-specific knowledge. It scans
the source paths you give it for the standard marking syntaxes and collects the literal strings:
  · C++ : _T("..") / _TN("..") / tr("..") / QT_TR_NOOP("..")
  · QML : qsTr("..")

Translatable text that lives in DATA (config/JSON/DB), not as a source literal, is out of scope by
design — emit it as _TN("..") marks into a generated source file and point this tool at that file, so
everything flows through one generic extraction (just like gettext's xgettext over generated headers).

Default: write a .pot template (all msgids, empty msgstr).
--augment-po <po>: append any msgid missing from <po> while preserving translations.

  usage: tr_extract.py --src <dir-or-file>... [--source-language en] [--pot out.pot]
                       [--augment-po x.po]
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def po_escape(text: str) -> str:
    return (text.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\t", "\\t"))


def po_unescape(text: str) -> str:
    """Inverse of po_escape — char-by-char so escaped msgids compare equal to decoded source strings
    (else an msgid with \\n / \\" is never recognised as already present and gets re-appended)."""
    out, i = [], 0
    while i < len(text):
        if text[i] == "\\" and i + 1 < len(text):
            out.append({"n": "\n", "t": "\t", "r": "\r", "\"": "\"", "\\": "\\"}.get(text[i + 1], text[i + 1]))
            i += 2
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


_QSTR_RE = re.compile(r'\bqsTr\(\s*"((?:[^"\\]|\\.)*)"')
_MACRO_RE = re.compile(r'\b(?:_T|_TN|tr|QT_TR_NOOP)\(\s*"((?:[^"\\]|\\.)*)"')


def _iter_files(paths: list[Path], suffixes: set[str]):
    """Yield files under each path: a directory is searched recursively; a file is taken if its suffix
    matches (so callers can pass a generated _TN manifest file directly)."""
    for path in paths:
        if path.is_dir():
            for child in path.rglob("*"):
                if child.suffix in suffixes:
                    yield child
        elif path.is_file() and path.suffix in suffixes:
            yield path


def collect_strings(paths: list[Path], suffixes: set[str], pattern: re.Pattern) -> list[str]:
    seen: dict[str, None] = {}
    for path in _iter_files(paths, suffixes):
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for match in pattern.finditer(text):
            # Decode C/QML escapes without round-tripping the complete string
            # through bytes: unicode_escape would reinterpret every UTF-8 byte
            # and corrupt non-ASCII source text (for example Chinese msgids).
            decoded = po_unescape(match.group(1))
            seen.setdefault(decoded, None)
    return list(seen.keys())


def existing_po_msgids(po_path: Path) -> set[str]:
    if not po_path.is_file():
        return set()
    ids: set[str] = set()
    for line in po_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("msgid "):
            value = po_unescape(line[len("msgid "):].strip().strip('"'))
            if value:
                ids.add(value)
    return ids


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--src", type=Path, nargs="+", required=True,
                        help="source dirs (searched recursively) and/or files to scan")
    parser.add_argument("--pot", type=Path, help="write a .pot template here")
    parser.add_argument("--augment-po", type=Path, help="append missing msgids to this .po")
    parser.add_argument("--source-language", choices=("en",),
                        help="validate that translatable source literals use this source language")
    args = parser.parse_args()

    qml = collect_strings(args.src, {".qml"}, _QSTR_RE)
    cpp = collect_strings(args.src, {".cpp", ".hpp", ".h", ".cc", ".cxx"}, _MACRO_RE)

    all_ids: dict[str, None] = {}
    for group in (qml, cpp):
        for msgid in group:
            all_ids.setdefault(msgid, None)
    msgids = list(all_ids.keys())
    print(f"extracted: {len(qml)} qsTr, {len(cpp)} _T/_TN/tr -> {len(msgids)} unique")

    if args.source_language == "en":
        invalid = sorted(msgid for msgid in msgids if re.search(r"[\u3400-\u9fff]", msgid))
        if invalid:
            print("error: Chinese msgid(s) found in English source:")
            for msgid in invalid:
                print(f"  {msgid}")
            return 2

    if args.pot:
        args.pot.parent.mkdir(parents=True, exist_ok=True)
        lines = ['msgid ""', 'msgstr ""', '"Content-Type: text/plain; charset=UTF-8\\n"', '"Language: \\n"', ""]
        for msgid in sorted(msgids):
            lines.append(f'msgid "{po_escape(msgid)}"')
            lines.append('msgstr ""')
            lines.append("")
        args.pot.write_text("\n".join(lines), encoding="utf-8")
        print(f"template -> {args.pot}")

    if args.augment_po:
        have = existing_po_msgids(args.augment_po)
        missing = [m for m in sorted(msgids) if m not in have]
        if missing:
            with args.augment_po.open("a", encoding="utf-8") as handle:
                handle.write("\n# --- appended by tr_extract ---\n")
                for msgid in missing:
                    handle.write(f'\nmsgid "{po_escape(msgid)}"\nmsgstr ""\n')
        print(f"augmented {args.augment_po}: +{len(missing)} new msgid(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
