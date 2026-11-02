/*!
\qmltype DropDownPopup
\inqmlmodule SmoothUI.Controls
\brief A popup used as the dropdown menu container.
Provides a themed popup with configurable offset, position
tracking, and optional enter/exit animation support.
*/
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.impl
T.Popup{
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.radius: Theme.popupRadius
property int offsetY: 3
property int posY: 0
property bool animationEnabled: true
modal: true
dim: false
transformOrigin: Item.Top
verticalPadding: 0
enter: Transition {
enabled: control.animationEnabled
ParallelAnimation {
NumberAnimation {
target: control
property: "opacity"
from: 0
to: 1
duration: Theme.fasterAnimationDuration
}
NumberAnimation {
target: control
property: "y"
from: {
return d.isTop ?  control.posY + 15 : control.posY + -15
}
to: control.posY
duration: d.animationDuration
easing.type: Theme.animationCurve
}
}
}
exit: Transition {
enabled: control.animationEnabled
ParallelAnimation {
NumberAnimation {
target: control
property: "opacity"
from: 1
to: 0
duration: Theme.fasterAnimationDuration
}
}
}
Item{
id: d
property int animationDuration: control.animationEnabled ? Theme.fastAnimationDuration : 0
property bool isTop: false
}
background: Rectangle{
radius: control.SmoothUI.radius
border.width: 1
color: control.SmoothUI.theme.res.popupBackgroundColor
border.color: control.SmoothUI.theme.res.popupBorderColor
Shadow{
radius: control.SmoothUI.radius
}
}
Overlay.modal: Item {}
function popup(target){
var pos = target.mapToItem(target.Window.contentItem,0, 0)
if(pos.y+control.height+target.height+control.offsetY<target.Window.contentItem.height){
d.isTop = false
control.posY = target.height + control.offsetY
}else if(pos.y>control.height+control.offsetY){
d.isTop = true
control.posY = -control.height - control.offsetY
}else{
d.isTop = false
control.posY = target.height + control.offsetY
}
control.open()
}
}
