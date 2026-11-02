/*!
\qmltype Chip
\inqmlmodule SmoothUI.Controls
\brief A compact chip/tag element with optional close button.
Provides a themed chip component based on StandardButton, supporting
a close action, custom icon, and compact styling for use in tag
inputs and filter displays.
*/
import QtQuick
import QtQuick.Controls.impl
import SmoothUI.impl
StandardButton{
id: control
rightPadding: loader_close.width+8
padding: 4
font: Typography.caption
signal closeClicked
property var closeButton: Component{
IconButton{
id: btn_close
icon.width: 8
icon.height: 8
icon.name: FluentIcons.graph_ChromeClose
icon.color: control.SmoothUI.textColor
width: 16
height: 16
padding: 0
radius: 8
backgroundColor: {
if(!btn_close.enabled){
return Theme.buttonColor(btn_close,false,control.SmoothUI.dark)
}else{
if(control.highlighted){
if(btn_close.pressed){
return control.SmoothUI.theme.res.controlFillColorTertiary
}
if(btn_close.hovered){
return control.SmoothUI.theme.res.controlFillColorSecondary
}
}
return Theme.uncheckedInputColor(btn_close,true,false,control.SmoothUI.dark)
}
}
onClicked: {
control.closeClicked()
}
}
}
AutoLoader{
id: loader_close
sourceComponent: control.closeButton
anchors{
verticalCenter: parent.verticalCenter
right: parent.right
rightMargin: 4
}
}
background.implicitHeight: 20
background.implicitWidth: 0
}
