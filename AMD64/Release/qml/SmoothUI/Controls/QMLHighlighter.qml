/*!
\qmltype QMLHighlighter
\inqmlmodule SmoothUI.Controls
\brief A QML syntax highlighter with dark/light theme colors.
Provides syntax highlighting for QML code with color schemes for
keywords, components, numbers, strings, comments, and properties,
adapting to both light and dark themes.
*/
import QtQuick
import SmoothUI.Controls
import SmoothUI.impl
SyntaxHighlighter {
id: control
SmoothUI.theme: Theme.of(control)
readonly property color keywordColor: control.SmoothUI.dark ? "#c678dd" : "#808000"
readonly property color componentColor: control.SmoothUI.dark ? "#61afef" : "#aa00aa"
readonly property color numberColor: control.SmoothUI.dark ? "#d19a66" : "#0055af"
readonly property color propertyColor: control.SmoothUI.dark ? "#e06c75" : "#800000"
readonly property color stringColor: control.SmoothUI.dark ? "#98c379" : "#008000"
readonly property color commentColor: control.SmoothUI.dark ? "#5c6370" : "#008000"
TextCharFormat { id: keywordFormat; foreground: control.keywordColor }
TextCharFormat { id: componentFormat; foreground: control.componentColor}
TextCharFormat { id: numberFormat; foreground: control.numberColor }
TextCharFormat { id: propertyFormat; foreground: control.propertyColor }
TextCharFormat { id: stringFormat; foreground: control.stringColor }
TextCharFormat { id: commentFormat; foreground: control.commentColor }
onHighlightBlockChanged:
(text)=>{
highlightSyntax(text)
}
property bool __dark: control.SmoothUI.dark
on__DarkChanged: {
var doc = textDocument
textDocument = null
textDocument = doc
}
function highlightSyntax(text) {
let rx = /\/\/.*|[A-Za-z.]+(\s*:)?|\d+(.\d*)?|'[^']*?'|"[^"]*?"/g
let m
while ( ( m = rx.exec(text) ) != null ) {
if (m[0].match(/^\/\/.*/)) {
setFormat(m.index, m[0].length, commentFormat)
continue
}
if (m[0].match(/^[a-z][A-Za-z.]*\s*:/)) {
setFormat(m.index, m[0].match(/^[a-z][A-Za-z.]*/)[0].length, propertyFormat)
continue
}
if (m[0].match(/^[a-z]/)) {
let keywords = [ 'import', 'function', 'bool', 'var',
'int', 'string', 'let', 'const', 'property',
'if', 'continue', 'for', 'break', 'while',
]
if (keywords.includes(m[0])) {
setFormat(m.index, m[0].length, keywordFormat)
continue
}
continue
}
if (m[0].match(/^[A-Z]/)) {
setFormat(m.index, m[0].length, componentFormat)
continue
}
if (m[0].match(/^\d/)) {
setFormat(m.index, m[0].length, numberFormat)
continue
}
if (m[0].match(/^'/)) {
setFormat(m.index, m[0].length, stringFormat)
continue
}
if (m[0].match(/^"/)) {
setFormat(m.index, m[0].length, stringFormat)
continue
}
}
}
}
