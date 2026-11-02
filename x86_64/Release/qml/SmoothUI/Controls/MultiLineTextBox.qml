/*!
\qmltype MultiLineTextBox
\inqmlmodule SmoothUI.Controls
\brief A multi-line text input control with theme integration.
Provides a themed rich text editor with accent-colored selection,
leading/trailing content slots, and right-click context menu support.
*/
import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Controls.impl as QQCImpl
import QtQuick.Templates as T
import SmoothUI.impl
T.TextArea {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property Component leading
property Component trailing
property var onClickSelectAll
readonly property bool pressed: tap_handler.pressed
implicitWidth: Math.max(contentWidth + leftPadding + rightPadding,
implicitBackgroundWidth + leftInset + rightInset,
placeholder.implicitWidth + leftPadding + rightPadding)
implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
implicitBackgroundHeight + topInset + bottomInset)
padding: Theme.controlPadding
topPadding: padding+2
leftPadding: padding + (control.leading ? 0 : 4) + loader_leading.width + loader_leading.anchors.leftMargin
rightPadding: padding + loader_trailing.width + loader_trailing.anchors.rightMargin
font: Typography.body
focusPolicy: Qt.TabFocus
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
TapHandler{
id: tap_handler
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
wrapMode: control.wrapMode
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
}
