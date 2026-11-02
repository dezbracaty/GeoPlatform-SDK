/*!
\qmltype DialogWindow
\inqmlmodule SmoothUI.Controls
\brief A frameless dialog window with ContentDialog content.
Provides a themed popup window wrapping ContentDialog with
frameless style, configurable border width, and standard
button support.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
Window {
id: control
default property alias content: content_dialog.contentData
property alias dialog: content_dialog
property alias standardButtons: content_dialog.standardButtons
property int borderWidth: 5
flags: Qt.FramelessWindowHint | Qt.Dialog
SmoothUI.radius: Theme.dialogRadius
SmoothUI.theme: Theme.of(control)
SmoothUI.dark: Theme.dark
SmoothUI.primaryColor: Theme.primaryColor
color: Colors.transparent
WindowOpacityFixer{}
ContentDialog{
id: content_dialog
title: control.title
x: control.borderWidth
y: control.borderWidth
modal: false
background: Rectangle {
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
border.color: control.SmoothUI.theme.res.controlStrokeColorSecondary
border.width: 1
radius: control.SmoothUI.radius
MouseArea{
anchors.fill: parent
onPositionChanged: {
control.startSystemMove()
}
}
Shadow{
radius: control.SmoothUI.radius
anchors.fill: parent
}
}
onClosed: {
control.close()
}
}
onVisibleChanged: {
if(visible){
content_dialog.open()
control.width = content_dialog.implicitWidth+(2*control.borderWidth)
control.height = content_dialog.implicitHeight+(2*control.borderWidth)
control.minimumWidth = width
control.maximumWidth = width
control.minimumHeight = height
control.maximumHeight = height
}else{
content_dialog.close()
}
}
function open(){
control.show()
}
}
