/*!
\qmltype SyntaxHighlighter
\inqmlmodule SmoothUI.impl
\brief A QML syntax highlighter interface.
Provides a QML-accessible syntax highlighter wrapping the
C++ SyntaxHighlighterImpl. Supports custom TextCharFormat
children for defining highlighting rules.
*/
import QtQuick
import SmoothUI.impl
Objects {
id: control
default property list<TextCharFormat> children
property alias textDocument: syntax_highlighter_impl.textDocument
signal highlightBlockChanged(var text)
SyntaxHighlighterImpl {
id: syntax_highlighter_impl
onHighlightBlockChanged: (text)=>{control.highlightBlockChanged(text)}
}
function setFormat(start,count,format){
syntax_highlighter_impl.setFormat(start,count,format)
}
}
