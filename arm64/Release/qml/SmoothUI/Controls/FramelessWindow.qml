/*!
\qmltype FramelessWindow
\inqmlmodule SmoothUI.Controls
\brief A frameless window with native title bar integration.
Provides a custom window chrome with optional AppBar title bar,
frameless drag regions, and configurable launch mode, sizing,
and window effects (mica/acrylic).
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
Window {
id: control
SmoothUI.theme: Theme.of(control)
required property var initialItem
property alias containerItem: layout_container
property alias framelessHelper: frameless
property int launchMode: WindowType.Standard
property bool fitsAppBarWindows: false
property bool topmost: false
property bool fixSize: false
property AppBar appBar: AppBar{
showMaximize: !control.fixSize
windowTitle: control.title
}
property int __margins: 0
property int __borderWidth: 0
property var __windowRegister
property string __route
property Component background: comp_background
property bool autoDestroy: true
property int windowEffect: WindowEffectType.Normal
property bool useQtFrameless: Qt.platform.os === "linux"
signal init(var argument)
signal newInit(var argument)
SmoothUI.dark: Theme.dark
SmoothUI.primaryColor: Theme.primaryColor
property var onCloseListener: function(event){
if(autoDestroy){
WindowRouter.removeWindow(control)
}else{
control.hide()
event.accepted = false
}
}
color: {
if(Qt.platform.os === "windows"){
return Colors.transparent
}
return control.SmoothUI.theme.res.micaBackgroundColor
}
Component.onCompleted: {
WindowRouter.addWindow(control)
if(appBar && Number(appBar.width) === 0){
appBar.width = Qt.binding(function(){ return control.width })
}
}
Component.onDestruction: {
frameless.onDestruction()
}
Component{
id: comp_background
Rectangle{
color: {
if(Qt.platform.os === "windows" && windowEffect !== WindowEffectType.Normal && Tools.isWindows11OrGreater()){
return Colors.transparent
}
return control.SmoothUI.theme.res.micaBackgroundColor
}
}
}
Connections{
target: control
function onClosing(event){onCloseListener(event)}
}
AutoLoader{
anchors.fill: parent
sourceComponent: control.background
}
Frameless{
id: frameless
appbar: control.appBar
topmost: control.topmost
fixSize: control.fixSize
buttonMaximized: control.appBar?.buttonMaximized??null
dark: control.SmoothUI.dark
windowEffect: control.windowEffect
useQtFrameless: control.useQtFrameless
}
Item{
id: layout_container
anchors.fill: parent
anchors.margins: __margins
HotLoader{
id: loader_container
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
focus: true
anchors{
fill: parent
topMargin: fitsAppBarWindows ? 0 : layout_appbar.height
}
source: {
if(control.initialItem){
return Qt.resolvedUrl(control.initialItem,control)
}
return ""
}
}
Item{
id: layout_appbar
data: [appBar]
width: parent.width
height: childrenRect.height
visible: !frameless.disabled
y: control.visibility === Window.FullScreen ? -childrenRect.height : 0
Behavior on y {
NumberAnimation{
duration: Theme.slowAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
Rectangle{
anchors.fill: parent
visible: __borderWidth > 0 && control.visibility !== Window.FullScreen
color: Colors.transparent
border.width: __borderWidth
border.color: control.SmoothUI.theme.res.controlStrokeColorDefault
}
function setHitTestVisible(id){
frameless.setHitTestVisible(id)
}
function showMaximized(){
frameless.showMaximized()
}
function showMinimized(){
frameless.showMinimized()
}
function showNormal(){
frameless.showNormal()
}
function showFullScreen(){
frameless.showFullScreen()
}
function deleteLater(){
Tools.deleteLater(control)
}
function setResult(data){
if(__windowRegister){
__windowRegister.setResult(data)
}
}
}
