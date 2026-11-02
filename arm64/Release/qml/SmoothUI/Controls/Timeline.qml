import QtQuick
import QtQuick.Controls
import SmoothUI.impl
/*!
\qmltype Timeline
\inqmlmodule SmoothUI.Controls
\brief A vertical timeline display for chronological events
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
//! \value TimelineType.Left Timeline items aligned to the left
//! \value TimelineType.Alternate Timeline items alternate left and right
property int mode: TimelineType.Left
property alias model: repeater.model
property color lineColor: control.SmoothUI.theme.res.dividerStrokeColorDefault
implicitWidth: 380
implicitHeight: layout_column.implicitHeight
QtObject{
id: d
property bool isLeft: control.mode === TimelineType.Left
property bool isRight: control.mode === TimelineType.Right
property bool isAlternate: control.mode === TimelineType.Alternate
property bool hasLable: {
if(!model){
return false
}
for(var i=0;i<model.count;i++){
var lable = model.get(i).lable
if(lable !== undefined && undefined !== ""){
return true
}
}
return false
}
property string stateName : {
if(hasLable){
return "Center"
}
if(isRight){
return "Right"
}
if(isAlternate){
return "Center"
}
return "Left"
}
}
Rectangle{
id: rect_line
color: control.lineColor
height: {
if(repeater.count===0){
return parent.height
}
return parent.height - layout_column.children[repeater.count-1].height
}
width: 2
visible: repeater.count!==0
state: d.stateName
states: [
State {
name: "Left"
AnchorChanges {
target: rect_line
anchors.left: control.left
}
PropertyChanges {
target: rect_line
anchors.leftMargin: 7
}
},
State {
name: "Right"
AnchorChanges {
target: rect_line
anchors.right: control.right
}
PropertyChanges {
target: rect_line
anchors.rightMargin: 7
}
},
State {
name: "Center"
AnchorChanges {
target: rect_line
anchors.horizontalCenter: control.horizontalCenter
}
}
]
}
Component{
id: com_dot
Rectangle{
width: 16
height: 16
radius: 8
border.width: 4
color: control.SmoothUI.theme.res.cardBackgroundColor
border.color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
}
Component{
id: comp_label
Label{
wrapMode: Text.WordWrap
horizontalAlignment: isRight ? Qt.AlignRight : Qt.AlignLeft
text: {
if(modelData.lable){
return modelData.lable
}
return ""
}
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
}
Component{
id: com_text
Label{
wrapMode: Text.WordWrap
horizontalAlignment: isRight ? Qt.AlignRight : Qt.AlignLeft
text: modelData.text
textFormat: Text.RichText
}
}
Column{
id: layout_column
spacing: 30
width: control.width
Repeater{
id: repeater
Item{
id: item_layout
width: layout_column.width
height: loader_text.height
AutoLoader{
id: item_loader
state: d.stateName
states: [
State {
name: "Left"
AnchorChanges {
target: item_loader
anchors.left: item_layout.left
}
},
State {
name: "Right"
AnchorChanges {
target: item_loader
anchors.right: item_layout.right
}
},
State {
name: "Center"
AnchorChanges {
target: item_loader
anchors.horizontalCenter: item_layout.horizontalCenter
}
}
]
sourceComponent: {
if(model.dotDelegate)
return model.dotDelegate()
return com_dot
}
}
AutoLoader{
property var modelData: control.model.get(index)
property bool isRight: state === "Right"
id: loader_label
sourceComponent: {
if(!modelData){
return undefined
}
var lableDelegate = model.lableDelegate
if(lableDelegate instanceof Function && lableDelegate() instanceof Component){
return lableDelegate()
}
return comp_label
}
state: {
if(d.isRight){
return "Left"
}
if(d.isAlternate){
if(index%2===0){
return "Right"
}else{
return "Left"
}
}
return "Right"
}
states: [
State {
name: "Left"
AnchorChanges {
target: loader_label
anchors.left: item_loader.right
anchors.right: item_layout.right
}
PropertyChanges {
target: loader_label
anchors.leftMargin: 14
anchors.rightMargin: 14
}
},
State {
name: "Right"
AnchorChanges {
target: loader_label
anchors.right: item_loader.left
anchors.left: item_layout.left
}
PropertyChanges {
target: loader_label
anchors.leftMargin: 14
anchors.rightMargin: 14
}
},
State {
name: "Center"
AnchorChanges {
target: loader_label
anchors.right: item_loader.left
anchors.left: item_layout.left
}
PropertyChanges {
target: loader_label
anchors.leftMargin: 14
anchors.rightMargin: 14
}
}
]
}
AutoLoader{
id: loader_text
property var modelData: control.model.get(index)
property bool isRight: state === "Right"
state: {
if(d.isRight){
return "Right"
}
if(d.isAlternate){
if(index%2===0){
return "Left"
}else{
return "Right"
}
}
return "Left"
}
sourceComponent: {
if(!modelData){
return undefined
}
var textDelegate = model.textDelegate
if(textDelegate instanceof Function && textDelegate() instanceof Component){
return textDelegate()
}
return com_text
}
states: [
State {
name: "Left"
AnchorChanges {
target: loader_text
anchors.left: item_loader.right
anchors.right: item_layout.right
}
PropertyChanges {
target: loader_text
anchors.leftMargin: 14
anchors.rightMargin: 14
}
},
State {
name: "Right"
AnchorChanges {
target: loader_text
anchors.right: item_loader.left
anchors.left: item_layout.left
}
PropertyChanges {
target: loader_text
anchors.leftMargin: 14
anchors.rightMargin: 14
}
},
State {
name: "Center"
AnchorChanges {
target: loader_text
anchors.right: item_loader.left
anchors.left: item_layout.left
}
PropertyChanges {
target: loader_text
anchors.leftMargin: 14
anchors.rightMargin: 14
}
}
]
}
}
}
}
}
