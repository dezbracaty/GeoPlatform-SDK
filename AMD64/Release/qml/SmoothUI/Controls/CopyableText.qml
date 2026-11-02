/*!
\qmltype CopyableText
\inqmlmodule SmoothUI.Controls
\brief A read-only text selection control with copy support.
Provides a selectable text display with right-click context menu
for copy operations, accent-colored selection highlight, and
theme integration.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
TextEdit {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
color: control.SmoothUI.theme.res.textFillColorPrimary
readOnly: true
renderType: Theme.textRender
padding: 0
leftPadding: 0
rightPadding: 0
topPadding: 0
selectByMouse: true
selectionColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
bottomPadding: 0
font: Typography.body
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
