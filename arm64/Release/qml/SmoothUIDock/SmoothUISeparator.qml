import QtQuick
import SmoothUI.Controls
import SmoothUI.impl
Item {
id: control
anchors.fill: parent
SmoothUI.theme: Theme.of(control)
readonly property QtObject kddwSeparator: parent
readonly property bool isVertical: kddwSeparator ? kddwSeparator.isVertical : false
Rectangle {
anchors.fill: parent
clip: true
color:{
if(!control.enabled){
return control.SmoothUI.theme.res.controlFillColorDisabled
}else{
if(mouseArea.pressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(mouseArea.containsMouse){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
}
Rectangle{
width: control.isVertical ? control.width : Theme.borderWidth
height: control.isVertical ? Theme.borderWidth : control.height
anchors.centerIn: parent
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
MouseArea {
id: mouseArea
cursorShape: kddwSeparator ? (control.isVertical ? Qt.SizeVerCursor : Qt.SizeHorCursor)
: Qt.SizeHorCursor
anchors.fill: parent
onPressed: {
kddwSeparator.onMousePressed();
}
hoverEnabled: true
onReleased: {
kddwSeparator.onMouseReleased();
}
onPositionChanged: (mouse) => {
kddwSeparator.onMouseMoved(Qt.point(mouse.x, mouse.y));
}
onDoubleClicked: {
kddwSeparator.onMouseDoubleClicked();
}
}
}
