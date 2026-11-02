/*!
\qmltype ProgressButton
\inqmlmodule SmoothUI.Controls
\brief A button that shows progress state.
Extends FilledButton with indeterminate and determinate progress
visualization, transitioning through ready/started/completed states.
*/
import QtQuick
import SmoothUI.impl
import SmoothUI.Controls
FilledButton {
id: control
SmoothUI.theme: Theme.of(control)
property bool indeterminate: false
property real value: 0
readonly property bool completed: control.value === 1
readonly property bool started: control.value === 0
readonly property bool ready: control.value !== 0 && control.value !== 1
contentItem: IconLabel{
spacing: control.spacing
display: control.display
icon: control.icon
text: control.text
font: control.font
color: control.SmoothUI.textColor
visible: {
if(control.indeterminate){
return false
}
if(control.ready){
return false
}
return true
}
}
background.implicitWidth: 120
background.implicitHeight: Theme.controlHeight
ProgressRing{
id: progress_ring
width: 20
height: 20
strokeWidth: 2
indeterminate: control.indeterminate
anchors.centerIn: parent
value: control.value
backgroundColor: Colors.withOpacity(control.SmoothUI.textColor,0.2)
activeColor: control.SmoothUI.textColor
visible: {
if(control.indeterminate || control.ready){
return true
}
return false
}
}
Rectangle{
width: 8
height: 8
radius: 2
color: control.SmoothUI.textColor
anchors.centerIn: parent
visible: progress_ring.visible
}
}
