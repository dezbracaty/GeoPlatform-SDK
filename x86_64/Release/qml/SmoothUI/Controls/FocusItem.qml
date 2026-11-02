/*!
\qmltype FocusItem
\inqmlmodule SmoothUI.Controls
\brief A focus rectangle overlay that follows the target control.
Provides an accent outer ring and contrasting inset ring without changing the target
control geometry or receiving pointer and keyboard events.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
SmoothUI.theme: Theme.of(control)
property int radius: target ? target.SmoothUI.radius : Theme.controlRadius
property var target
anchors.fill: parent
Rectangle{
width: control.width
height: control.height
anchors.centerIn: parent
color: "#00000000"
border.width: Theme.focusBorderWidth
radius: control.radius
visible: target && target.activeFocus
border.color: {
const target = control.target
const theme = target ? Theme.of(target) : control.SmoothUI.theme
const accent = target && target.accentColor ? target.accentColor : theme.accentColor
return accent.defaultBrushFor(target ? target.SmoothUI.dark : control.SmoothUI.dark)
}
z: 65535
Rectangle {
anchors.fill: parent
anchors.margins: Theme.focusBorderWidth
color: "transparent"
border.width: 1
border.color: control.target ? Theme.of(control.target).res.focusStrokeColorInner
: control.SmoothUI.theme.res.focusStrokeColorInner
radius: Math.max(0, control.radius - Theme.focusBorderWidth)
}
}
}
