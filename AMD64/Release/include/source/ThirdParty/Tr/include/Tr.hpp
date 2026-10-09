#pragma once

// Tr — GPlatform's foundational, Qt-free translation library (gettext backend).
//
// The lowest layer: zero dependencies (std only), so ANY library can link it — including the Qt-free
// ones (OrcaConfigCore, DataDB, Utils…). It is the single translation backend for the whole app. Qt's
// tr()/qsTr() are routed to the same catalog by a ~15-line QTranslator subclass that lives in core/
// (NOT a separate library) — see core/GettextBridge. There are no Qt .ts/.qm files.
//
//   _T("Save")                       -> std::string translation (source string if untranslated)
//   _T("Saved {} of {} files", a, b) -> translated, then positional-formatted ({} sequential, {N} indexed)
//   _TN("Save")                      -> mark for extraction only; returns the source literal unchanged
//
// Usage in a Qt-free library: link GPlatform::Tr, include <Tr.hpp>, wrap user-facing strings in _T(...).
// Loading the catalog and choosing the language happen once at app startup; call sites stay oblivious.

#include <cstddef>
#include <functional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

namespace tr {

class Translator {
public:
    static Translator& instance();

    void setLanguage(std::string language);
    const std::string& language() const;

    // Load a compiled .mo catalog into a domain ("" is the application domain).
    bool loadCatalog(const std::string& moPath, const std::string& domain = std::string());
    // Load from an in-memory .mo image (e.g. bytes read from an embedded Qt resource by core).
    bool loadCatalogFromBuffer(const char* data, std::size_t size, const std::string& domain = std::string());
    void clear();

    // True + writes the translation on hit; false on miss (used by the Qt bridge to fall back to source).
    bool find(const std::string& msgid, std::string& out, const std::string& domain = std::string()) const;
    // Translation, or msgid unchanged when absent.
    std::string translate(const std::string& msgid, const std::string& domain = std::string()) const;

    bool hasCatalog(const std::string& domain = std::string()) const;

    // Observe catalog changes. The callback runs (synchronously, on the caller's thread) whenever the
    // active catalog is reloaded — i.e. on a successful loadCatalog/loadCatalogFromBuffer. This is how
    // C++ models that expose translated DATA (e.g. settings rows built outside QML) learn to refresh on
    // a language switch: Qt's QQmlEngine::retranslate() only re-runs QML qsTr bindings, not C++ data.
    // The notification lives here because Tr owns the catalog — Qt-free (std::function), so any module
    // (Qt or not) can subscribe without coupling to the app. Intended for long-lived observers
    // (app-lifetime singletons); callbacks are not auto-removed, so do not register short-lived objects.
    void onChanged(std::function<void()> callback);

private:
    Translator() = default;
    void notifyChanged();
    std::string m_language;
    std::unordered_map<std::string, std::unordered_map<std::string, std::string>> m_catalogs;
    std::vector<std::function<void()>> m_observers;
};

// --- argument stringification (for positional formatting) ------------------------------------------
namespace detail {
inline std::string toStr(std::string value) { return value; }
inline std::string toStr(std::string_view value) { return std::string(value); }
inline std::string toStr(const char* value) { return value ? std::string(value) : std::string(); }
inline std::string toStr(char value) { return std::string(1, value); }
inline std::string toStr(bool value) { return value ? "1" : "0"; }
template <typename T>
inline std::string toStr(const T& value) { return std::to_string(value); }

// Substitute {} (sequential) and {N} (indexed) placeholders. {{ and }} are literal braces.
std::string vformat(std::string_view fmt, const std::vector<std::string>& args);
} // namespace detail

// --- public translate entry points (what the _T macro forwards to) --------------------------------
inline std::string translate(std::string_view msgid) {
    return Translator::instance().translate(std::string(msgid));
}

template <typename... Args>
inline std::string translate(std::string_view msgid, Args&&... args) {
    const std::string pattern = Translator::instance().translate(std::string(msgid));
    return detail::vformat(pattern, { detail::toStr(std::forward<Args>(args))... });
}

} // namespace tr

// _T(...) translate now; _TN(s) mark-only. Variadic _T dispatches to the overloaded tr::translate
// (plain vs format). Guarded so a stray platform define doesn't break the build.
#ifndef _T
#define _T(...) (::tr::translate(__VA_ARGS__))
#endif
#ifndef _TN
#define _TN(s) (s)
#endif
