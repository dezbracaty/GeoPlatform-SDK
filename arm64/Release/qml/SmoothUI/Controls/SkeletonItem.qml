import QtQuick
import SmoothUI.impl
/*!
\qmltype SkeletonItem
\inqmlmodule SmoothUI.Controls
\brief A single skeleton placeholder shape for loading states.
Renders an individual skeleton element (rectangle, circle, rounded rectangle,
or text lines) that can be used inside a SkeletonView. The shimmer animation
overlay is applied by the parent SkeletonView.
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
//! Supported types: "rectangle", "circle", "rounded", "text".
property string type: "rectangle"
property color boneColor: control.SmoothUI.theme.res.dividerStrokeColorDefault
property real radius: control.SmoothUI.radius
property int lines: 3
property real lineSpacing: 8
///        If an array, each element specifies the width of the corresponding line.
property var lineWidth: [0.9, 0.75, 0.6]
property real lineHeight: 12
property bool show: true
implicitWidth: {
if (control.type === "text") {
return 200
}
return 60
}
implicitHeight: {
if (control.type === "text") {
return control.lines * control.lineHeight + (control.lines - 1) * control.lineSpacing
}
return 60
}
visible: control.show
QtObject {
id: d
readonly property bool isText: control.type === "text"
readonly property bool isCircle: control.type === "circle"
readonly property bool isRounded: control.type === "rounded"
}
Rectangle {
id: shape_rect
anchors.fill: parent
visible: !d.isText
radius: {
if (d.isCircle) return Math.min(width, height) / 2
if (d.isRounded) return control.radius
return 0
}
color: control.boneColor
}
Column {
id: text_lines
visible: d.isText
anchors.fill: parent
spacing: control.lineSpacing
topPadding: 0
Repeater {
model: control.lines
delegate: Rectangle {
required property int index
width: {
var widths = typeof control.lineWidth === "number"
? [control.lineWidth]
: control.lineWidth
if (index < widths.length) {
return parent.width * widths[index]
}
return parent.width * (index === control.lines - 1 ? 0.5 : 0.8)
}
height: control.lineHeight
radius: height / 2
color: control.boneColor
}
}
}
}
