import QtQuick
import QtQuick.Window
import QtQuick.Templates as T
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype TextEditingContextMenu
\inqmlmodule SmoothUI.Controls
\brief Context menu for text editing operations
*/
T.Menu {
id: control
popupType: {
if(Tools.isQtVersionOrGreater(6, 11, 0)){
return Qt.platform.pluginName !== "wayland" ? Popup.Window : Popup.Item
}
return Popup.Item
}
required property Item editor
SmoothUI.theme: Theme.of(control)
SmoothUI.radius: Theme.popupRadius
implicitWidth: 180
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
margins: 0
verticalPadding: 3
horizontalPadding: 3
overlap: 10
focus: false
contentItem: Item{
implicitHeight: list_content.height + 8
clip: enter.running ? true : false
Rectangle {
id: layout_container
property var window: Window.window
width: parent.width
height: parent.height
radius: control.SmoothUI.radius
border.width: 1
color: control.SmoothUI.theme.res.popupBackgroundColor
border.color: control.SmoothUI.theme.res.popupBorderColor
Shadow{
radius: control.SmoothUI.radius
}
anchors.centerIn: parent
ListView {
id: list_content
width: parent.width - 8
height: Math.min(contentHeight,control.SmoothUI.minimumHeight)
model: control.contentModel
interactive: Window.window
? contentHeight + control.topPadding + control.bottomPadding > control.height
: false
clip: true
anchors.centerIn: parent
currentIndex: control.currentIndex
ScrollBar.vertical: ScrollBar {}
boundsBehavior: ListView.StopAtBounds
}
}
}
height: __heightScale * implicitHeight
enter: Transition {
NumberAnimation { property: "__heightScale"; from: 0.33; to: 1; easing.type: Easing.OutCubic; duration: 250 }
}
background: Item{
implicitWidth: 180
implicitHeight: 0
}
T.Overlay.modal: Item{}
T.Overlay.modeless: Item{}
property real __heightScale: 1
function shortcutDisplayName(key) {
if (key === StandardKey.Undo) return "Ctrl+Z"
if (key === StandardKey.Redo) return "Ctrl+Y"
if (key === StandardKey.Cut) return "Ctrl+X"
if (key === StandardKey.Copy) return "Ctrl+C"
if (key === StandardKey.Paste) return "Ctrl+V"
if (key === StandardKey.Delete) return "Del"
if (key === StandardKey.SelectAll) return "Ctrl+A"
return ""
}
delegate: ListTile {
id: itemDelegate
SmoothUI.theme: Theme.of(control)
height: 34
spacing: 8
leading: itemDelegate.action?.icon.name === "" ? null : comp_icon
Component{
id: comp_icon
Icon{
width: 14
height: 14
source: itemDelegate.action?.icon.name
color: itemDelegate.textColor
}
}
Label {
anchors {
right: parent.right
rightMargin: 16
verticalCenter: parent.verticalCenter
}
text: control.shortcutDisplayName(itemDelegate.action?.shortcut)
color: itemDelegate.SmoothUI.theme.res.textFillColorTertiary
font.pixelSize: 12
}
}
Action {
text: qsTr("Undo")
icon.name: FluentIcons.graph_Undo
onTriggered: {
control.editor.undo()
control.close()
}
enabled: control.editor.canUndo
shortcut: StandardKey.Undo
}
Action {
text: qsTr("Redo")
icon.name: FluentIcons.graph_Redo
enabled: control.editor.canRedo
onTriggered: {
control.editor.redo()
control.close()
}
shortcut: StandardKey.Redo
}
MenuSeparator {}
Action {
text: qsTr("Cut")
icon.name: FluentIcons.graph_Cut
enabled: !control.editor.readOnly && control.editor.selectedText.length > 0 && control.editor.hasOwnProperty("cut")
onTriggered: {
control.editor.cut()
control.close()
}
shortcut: StandardKey.Cut
}
Action {
text: qsTr("Copy")
icon.name: FluentIcons.graph_Copy
enabled: control.editor.selectedText.length > 0 && control.editor.hasOwnProperty("copy")
onTriggered: {
control.editor.copy()
control.close()
}
shortcut: StandardKey.Copy
}
Action {
text: qsTr("Paste")
icon.name: FluentIcons.graph_Paste
enabled: !control.editor.readOnly && control.editor.hasOwnProperty("paste")
onTriggered: {
control.editor.paste()
control.close()
}
shortcut: StandardKey.Paste
}
Action {
text: qsTr("Delete")
icon.name: FluentIcons.graph_Delete
enabled: !control.editor.readOnly && control.editor.selectedText.length > 0
onTriggered: {
control.editor.remove(control.editor.selectionStart, control.editor.selectionEnd)
control.close()
}
shortcut: StandardKey.Delete
}
MenuSeparator {}
Action {
text: qsTr("Select All")
icon.name: ""
shortcut: StandardKey.SelectAll
onTriggered: {
if(control.editor instanceof MultiLineTextBox){
if(control.editor.onClickSelectAll){
control.editor.onClickSelectAll()
}else{
control.editor.selectAll()
}
}else{
control.editor.selectAll()
}
control.close()
}
}
}
