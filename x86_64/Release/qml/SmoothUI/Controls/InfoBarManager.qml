/*!
\qmltype InfoBarManager
\inqmlmodule SmoothUI.Controls
\brief Manages the queued display of InfoBar notifications.
Provides a managed overlay that displays InfoBar notifications
in sequence with configurable edge positioning, spacing, and
maximum message width.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
Objects {
id: control
property int edge: Qt.TopEdge
property var target
property int offsetX: 20
property int offsetY: 50
property int messageMaximumWidth: 520
property int spacing: 20
property bool isOverlay: false
Objects{
id: d
property bool isBottom: (control.edge & Qt.BottomEdge)
property var screenLayout: null
function create(severity,title,duration,message,action){
initScreenLayout()
screenLayout.append({severity:severity,title:title,duration:duration,message:message,action:action})
}
function createCustom(customcomponent,duration){
initScreenLayout()
screenLayout.append({customcomponent:customcomponent,duration:duration})
}
function initScreenLayout(){
if(screenLayout == null){
screenLayout = comp_list.createObject(control.target)
screenLayout.z = 65535
}
}
Component{
id: comp_list
Item{
id: info_control
parent: target
z: 65535
anchors.fill: target
ListModel{
id: data_model
dynamicRoles: true
onCountChanged: {
if(count === 0){
info_control.destroy()
}
}
}
Component{
id: comp_infobar
InfoBar{
id: info_bar
property var __model: model
severity: model.severity
title: model.title
message: model.message
closable: model.duration <= 0
action: AutoLoader{
property var model: info_bar.__model
property var infoControl: info_control
sourceComponent: model.action
}
messageMaximumWidth: control.messageMaximumWidth
onClickCloseListener: function(){
info_control.remove(model.index)
}
}
}
Column{
id: layout_column
spacing: control.spacing
parent: control.isOverlay ? Overlay.overlay : info_control
width: parent.width
anchors.top: parent.top
anchors.bottom: undefined
anchors.topMargin: control.offsetY
anchors.bottomMargin: undefined
states: State {
when: d.isBottom
AnchorChanges {
target: layout_column
anchors.top: undefined
anchors.bottom: parent.bottom
}
PropertyChanges {
target: layout_column
anchors.bottomMargin: control.offsetY
anchors.topMargin: 0
}
}
move: Transition {
enabled: !d.isBottom
NumberAnimation {
properties: "x,y"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
Repeater{
delegate: Item{
id: item_layout
property var __model: model
property bool isExiting: false
implicitWidth: layout_column.width
implicitHeight: loader_content.height
Shadow{
radius: Theme.controlRadius
anchors.fill: loader_content
elevation: 3
}
Component.onCompleted: {
if(control.edge & Qt.LeftEdge){
add_animation_left.start()
}else if(control.edge & Qt.RightEdge){
add_animation_right.start()
}else{
add_animation.start()
}
}
SequentialAnimation {
id: add_animation
ParallelAnimation{
NumberAnimation{
target: loader_content
property: "y"
from: d.isBottom ? loader_content.height : -loader_content.height
to: 0
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
NumberAnimation{
target: loader_content
property: "opacity"
from: 0
to: 1
duration: Theme.fasterAnimationDuration
}
}
}
SequentialAnimation {
id: add_animation_left
ParallelAnimation{
NumberAnimation{
target: loader_content
property: "anchors.leftMargin"
from: -loader_content.width
to: control.offsetX
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
NumberAnimation{
target: loader_content
property: "opacity"
from: 0
to: 1
duration: Theme.fasterAnimationDuration
}
}
}
SequentialAnimation {
id: add_animation_right
ParallelAnimation{
NumberAnimation{
target: loader_content
property: "anchors.rightMargin"
from: -loader_content.width
to: control.offsetX
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
NumberAnimation{
target: loader_content
property: "opacity"
from: 0
to: 1
duration: Theme.fasterAnimationDuration
}
}
}
SequentialAnimation {
id: exit_animation
ParallelAnimation{
NumberAnimation{
target: loader_content
property: "y"
from: 0
to: d.isBottom ? loader_content.height+offsetY : -loader_content.height-offsetY
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
NumberAnimation{
target: loader_content
property: "opacity"
from: 1
to: 0
duration: Theme.fasterAnimationDuration
}
}
ScriptAction {
script: {
info_control.remove(model.index)
}
}
}
SequentialAnimation {
id: exit_animation_left
ParallelAnimation{
NumberAnimation{
target: loader_content
property: "anchors.leftMargin"
to: -loader_content.width
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
NumberAnimation{
target: loader_content
property: "opacity"
from: 1
to: 0
duration: Theme.fasterAnimationDuration
}
}
ScriptAction {
script: {
info_control.remove(model.index)
}
}
}
SequentialAnimation {
id: exit_animation_right
ParallelAnimation{
NumberAnimation{
target: loader_content
property: "anchors.rightMargin"
to: -loader_content.width
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
NumberAnimation{
target: loader_content
property: "opacity"
from: 1
to: 0
duration: Theme.fasterAnimationDuration
}
}
ScriptAction {
script: {
info_control.remove(model.index)
}
}
}
AutoLoader{
id: loader_content
property var model: item_layout.__model
property var infoControl: info_control
sourceComponent: {
if(model.customcomponent){
return model.customcomponent
}
return comp_infobar
}
anchors {
left: (control.edge & Qt.LeftEdge) ? parent.left : undefined
right: (control.edge & Qt.RightEdge) ? parent.right : undefined
horizontalCenter: (control.edge === Qt.TopEdge) || (control.edge === Qt.BottomEdge) ? parent.horizontalCenter : undefined
}
anchors.leftMargin: control.offsetX
anchors.rightMargin: control.offsetX
}
Timer {
id: delay_timer
interval: model.duration
running: model.duration > 0
repeat: model.duration > 0
onTriggered: {
if (control.edge & Qt.LeftEdge) {
exit_animation_left.start()
} else if (control.edge & Qt.RightEdge) {
exit_animation_right.start()
} else {
exit_animation.start()
}
}
}
}
model: data_model
}
}
function append(data){
if(d.isBottom){
data_model.insert(0,data)
}else{
data_model.append(data)
}
}
function remove(index){
if(index>=0 && index<data_model.count){
data_model.remove(index)
}
}
}
}
}
function showSuccess(title,duration=1500,message,action){
return d.create(InfoBarType.Success,title,duration,message ? message : "",action ? action : null)
}
function showInfo(title,duration=1500,message,action){
return d.create(InfoBarType.Info,title,duration,message ? message : "",action ? action : null)
}
function showWarning(title,duration=1500,message,action){
return d.create(InfoBarType.Warning,title,duration,message ? message : "",action ? action : null)
}
function showError(title,duration=1500,message,action){
return d.create(InfoBarType.Error,title,duration,message ? message : "",action ? action : null)
}
function show(type,title,duration=1500,message,action){
return d.create(type,title,duration,message ? message : "",action ? action : null)
}
function showCustom(customcomponent,duration=1500){
return d.createCustom(customcomponent,duration)
}
function clearAllInfo(){
if(d.screenLayout != null) {
d.screenLayout.destroy()
d.screenLayout = null
}
return true
}
}
