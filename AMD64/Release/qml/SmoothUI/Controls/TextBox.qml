import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import QtQuick.Controls.impl as QQCImpl
import QtQuick.Templates as T
import SmoothUI.impl
/*!
\qmltype TextBox
\inqmlmodule SmoothUI.Controls
\brief Single-line text input with Fluent Design styling
*/
T.TextField {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property bool pressed: tap_handler.pressed
property Component leading
property Component trailing
implicitWidth: implicitBackgroundWidth + leftInset + rightInset
|| Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding,
placeholder.implicitHeight + topPadding + bottomPadding)
padding: Theme.controlPadding
leftPadding: (control.leading ? padding : Theme.controlHorizontalPadding) + loader_leading.width + loader_leading.anchors.leftMargin
rightPadding: (control.trailing ? padding : Theme.controlHorizontalPadding) + loader_trailing.width + loader_trailing.anchors.rightMargin
font: Typography.body
color: {
if(!enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
selectionColor: accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
renderType: Theme.textRender
placeholderTextColor: control.SmoothUI.theme.res.textFillColorSecondary
verticalAlignment: TextInput.AlignVCenter
property var __currentMenu
function __showMenu() {
if(__currentMenu){
Tools.deleteLater(__currentMenu)
__currentMenu = undefined
}
if(!control.activeFocus){
control.forceActiveFocus()
control.selectAll()
}
__currentMenu = input_menu.createObject(control)
__currentMenu.popup()
}
TapHandler {
acceptedButtons: Qt.RightButton
acceptedDevices: PointerDevice.Mouse
onTapped: function(eventPoint) {
eventPoint.accepted = true
control.__showMenu()
}
}
TapHandler {
acceptedDevices: PointerDevice.TouchScreen
onLongPressed: control.__showMenu()
}
Component {
id: input_menu
TextEditingContextMenu {
editor: control
onClosed: {
Tools.deleteLater(this)
__currentMenu = undefined
}
}
}
QQCImpl.PlaceholderText {
id: placeholder
x: control.leftPadding
y: control.topPadding
width: control.width - (control.leftPadding + control.rightPadding)
height: control.height - (control.topPadding + control.bottomPadding)
text: control.placeholderText
font: control.font
color: control.placeholderTextColor
verticalAlignment: control.verticalAlignment
visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
elide: Text.ElideRight
renderType: control.renderType
}
TapHandler{
id: tap_handler
}
background: InputBackground {
implicitWidth: 200
implicitHeight: Theme.controlHeight
radius: control.SmoothUI.radius
activeColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
color: {
if(!control.enabled){
return control.SmoothUI.theme.res.controlFillColorDisabled
}else if(control.activeFocus){
return control.SmoothUI.theme.res.controlFillColorInputActive
}else if(control.hovered){
return control.SmoothUI.theme.res.controlFillColorSecondary
}else{
return control.SmoothUI.theme.res.controlFillColorDefault
}
}
target: control
}
AutoLoader{
id: loader_leading
sourceComponent: control.leading
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: control.leading ? 6 : 0
}
}
AutoLoader{
id: loader_trailing
sourceComponent: control.trailing
anchors{
verticalCenter: parent.verticalCenter
right: parent.right
rightMargin: control.trailing ? 6 : 0
}
}
}
