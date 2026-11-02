/*!
\qmltype AppBar
\inqmlmodule SmoothUI.Controls
\brief A top application bar with window control buttons.
Provides a themed title bar area with minimize/maximize/close
buttons and a custom action slot for additional controls.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.impl
Rectangle {
id: control
SmoothUI.theme: Theme.of(control)
property Component action
property bool actionsOnLeft: false
property bool showClose: true
property bool showMinimize: true
property bool showMaximize: true
property alias buttonClose: btn_close
property alias buttonMaximized: btn_maximized
property alias buttonMinimized: btn_minimized
property Component windowIcon: comp_window_icon
property string windowTitle
width: {
if(parent){
return parent.width
}
return 0
}
implicitHeight: 30
color: Colors.transparent
Component{
id: comp_window_icon
Image{
width: 18
height: 18
source: R.windowIcon
}
}
Item{
id: d
property int buttonWidth : 46
property bool isRestore: Window.Maximized === Window.visibility || Window.FullScreen === Window.visibility
function setHitTestVisible(id){
if(Window.window && Window.window instanceof FramelessWindow){
Window.window.setHitTestVisible(id)
}
}
}
Item{
width: parent.width
height: 30
AutoLoader{
id: loader_left_action
anchors.left: parent.left
height: parent.height
sourceComponent: control.actionsOnLeft ? control.action : null
onLoaded: d.setHitTestVisible(this)
}
Row{
id: layout_title
anchors{
left: loader_left_action.right
right: layout_win_controls.left
horizontalCenter: undefined
top: parent.top
bottom: parent.bottom
leftMargin: 10
}
spacing: 6
state: Qt.platform.os
states: State {
name: "osx"
AnchorChanges{
target: layout_title
anchors.left: undefined
anchors.right: undefined
anchors.horizontalCenter: parent.horizontalCenter
}
PropertyChanges {
target: layout_title
anchors.leftMargin: 0
}
}
Loader{
id: loader_window_icon
sourceComponent: control.windowIcon
anchors.verticalCenter: parent.verticalCenter
}
Label{
text: control.windowTitle
elide: Qt.ElideRight
font: Typography.bodyStrong
anchors.verticalCenter: parent.verticalCenter
}
}
RowLayout{
id: layout_win_controls
spacing: 0
anchors.right: parent.right
height: parent.height
AutoLoader{
id: loader_action
Layout.fillHeight: true
sourceComponent: control.actionsOnLeft ? null : control.action
}
IconButton{
id: btn_minimized
implicitWidth: d.buttonWidth
implicitHeight: parent.height
radius: 0
icon.width: 12
icon.height: 12
visible: control.showMinimize && Qt.platform.os !== "osx"
icon.name: FluentIcons.graph_ChromeMinimize
ToolTip.visible: hovered
ToolTip.text: qsTr("Minimized")
ToolTip.delay: Theme.tooltipDelay
onClicked: {
Window.window.showMinimized()
}
}
IconButton{
id: btn_maximized
property bool hover: hovered
implicitWidth: d.buttonWidth
implicitHeight: parent.height
radius: 0
icon.width: 12
icon.height: 12
visible: control.showMaximize && Qt.platform.os !== "osx"
icon.name: d.isRestore ? FluentIcons.graph_ChromeRestore : FluentIcons.graph_ChromeMaximize
ToolTip.visible: hovered
ToolTip.text: d.isRestore ? qsTr("Restore") : qsTr("Maximized")
ToolTip.delay: Theme.tooltipDelay
backgroundColor: {
if(btn_maximized.down){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(btn_maximized.hover){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
onClicked: {
if(d.isRestore){
Window.window.showNormal()
}else{
Window.window.showMaximized()
}
}
}
IconButton{
id: btn_close
implicitWidth: d.buttonWidth
implicitHeight: parent.height
radius: 0
icon.width: 12
icon.height: 12
visible: control.showClose && Qt.platform.os !== "osx"
icon.name: FluentIcons.graph_ChromeClose
SmoothUI.textColor: btn_close.hovered ? control.SmoothUI.theme.res.textFillColorInverse : control.SmoothUI.theme.res.textFillColorPrimary
ToolTip.visible: hovered
ToolTip.text: qsTr("Close")
ToolTip.delay: Theme.tooltipDelay
backgroundColor: {
if(btn_close.pressed){
return Colors.red.dark()
}
if(btn_close.hovered){
return Colors.red.light()
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
onClicked: {
Window.window.close()
}
}
Component.onCompleted: {
d.setHitTestVisible(this)
}
}
}
}
