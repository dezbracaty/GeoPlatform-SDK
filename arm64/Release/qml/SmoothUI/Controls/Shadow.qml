import QtQuick
import QtQuick.Controls
import SmoothUI.impl
/*!
\qmltype Shadow
\inqmlmodule SmoothUI.Controls
\brief Renders a drop shadow effect
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property color color: control.SmoothUI.theme.res.shadowColor
opacity: Theme.shadowOpacityFor(control.SmoothUI.dark)
property int elevation: 5
property int radius: control.SmoothUI.radius
anchors.fill: parent
Repeater{
model: Math.max(0, control.elevation)
Rectangle{
anchors.fill: parent
color: "#00000000"
opacity: {
const count = Math.max(1, control.elevation)
return 2 * Math.max(0, control.elevation - index) / (count * (count + 1))
}
anchors.margins: -(index + 1)
radius: control.radius + index + 1
border.width: index + 1
border.color: control.color
}
}
}
