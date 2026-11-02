import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.impl
/*!
\qmltype TimePicker
\inqmlmodule SmoothUI.Controls
\brief Time selection control
*/
StandardButton {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
readonly property bool isH: hourFormat === TimePickerType.H
property string hourText: qsTr("hour")
property string minuteText: qsTr("minute")
property string pmText: locale.pmText
property string amText: locale.amText
//! \value TimePickerType.H 12-hour format with AM/PM
property int hourFormat: TimePickerType.H
property int minuteIncrement: 1
property var current
signal accepted()
implicitHeight: Math.max(Theme.controlHeight, implicitContentHeight + topPadding + bottomPadding)
implicitWidth: 240
topPadding: 0
bottomPadding: 0
rightPadding: 1
leftPadding: 1
SmoothUI.textColor: {
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textFillColorSecondary
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
QtObject{
id: d
property date time: new Date()
property bool isPm: time.getHours() >= 12
function formatHour(hour) {
const format = control.isH ? "hh" : "HH"
const date = new Date(0, 0, 0, hour)
return date.toLocaleTimeString(locale, format)
}
function formatMinute(minute) {
const date = new Date(0, 0, 0, 0, minute)
return date.toLocaleTimeString(locale, "mm")
}
function finalHour(hour){
let finalHour = hour
if (control.isH) {
if (finalHour === 0) {
finalHour = 12
} else if (finalHour > 12) {
finalHour = finalHour - 12
}
}
return finalHour
}
Component.onCompleted: {
if(current){
d.time = current
}
}
}
contentItem:  RowLayout{
spacing: 0
Item{
Layout.fillHeight: true
Layout.fillWidth: true
Label{
id: label_hour
text: {
if(!control.current){
return control.hourText
}
return d.formatHour(d.finalHour(d.time.getHours()))
}
color: control.SmoothUI.textColor
anchors.horizontalCenter: parent.horizontalCenter
y: (parent.height-height)/2
}
}
Rectangle{
Layout.fillHeight: true
implicitWidth: 1
color: control.SmoothUI.theme.res.controlStrokeColorDefault
}
Item{
Layout.fillHeight: true
Layout.fillWidth: true
Label{
id: label_minute
text: {
if(!control.current){
return control.minuteText
}
return d.formatMinute(d.time.getMinutes())
}
color: control.SmoothUI.textColor
anchors.horizontalCenter: parent.horizontalCenter
y: (parent.height-height)/2
}
}
Rectangle{
Layout.fillHeight: true
implicitWidth: 1
color: control.SmoothUI.theme.res.controlStrokeColorDefault
visible: control.isH
}
Item{
Layout.fillHeight: true
Layout.fillWidth: true
visible: control.isH
Label{
id: label_ampm
text: {
if(d.isPm){
return control.pmText
}
return control.amText
}
color: control.SmoothUI.textColor
anchors.horizontalCenter: parent.horizontalCenter
y: (parent.height-height)/2
}
}
}
onClicked: {
loader_popup.sourceComponent = comp_popup
}
AutoLoader{
id: loader_popup
}
Component{
id: comp_popup
DropDownPopup{
id: popup
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
height: 400
width: control.width
Component.onCompleted: {
popup.popup(control)
}
onClosed:{
loader_popup.sourceComponent = undefined
}
property color hitColor: control.SmoothUI.dark ? control.accentColor.lightest() : control.accentColor.darkest()
property color textColor: Colors.basedOnLuminance(hitColor)
function formatText(tumbler, modelData) {
const data = (tumbler === tumbler_hours && control.isH) ? modelData + 1 : modelData
return data.toString().length < 2 ? "0" + data : data
}
function generatePossibleMinutes(minuteIncrement) {
const possibleMinutes = []
for (let index = 0; index < 60 / minuteIncrement; index++) {
possibleMinutes.push(index * minuteIncrement)
}
return possibleMinutes
}
function getClosestMinute(possibleMinutes, goal) {
if (possibleMinutes.length === 0) {
return null
}
const closest = possibleMinutes.reduce((prev, curr) => {
return Math.abs(curr - goal) < Math.abs(prev - goal) ? curr : prev
})
return clamp(closest, 0, 59)
}
function clamp(value, min, max) {
return Math.max(min, Math.min(max, value))
}
function updatePosition(){
let date
if(control.current){
date = control.current
}else{
date = new Date()
}
const h = d.finalHour(date.getHours())
if(h === 0){
if(control.isH){
h = 12
}else{
h = 24
}
}
let index = -1
for(let i=0;i<tumbler_hours.model;i++){
let item = i
if(control.isH){
item = i+1
}
if(h === item){
index = i
break
}
}
if(index != -1){
tumbler_hours.positionViewAtIndex(index,Tumbler.Center)
}
index = -1
const m = getClosestMinute(tumbler_minutes.model,date.getMinutes())
for(let i=0;i<tumbler_minutes.model.length;i++){
if(m === tumbler_minutes.model[i]){
index = i
break
}
}
if(index != -1){
tumbler_minutes.positionViewAtIndex(index,Tumbler.Center)
}
if(d.isPm){
index = 1
}else{
index = 0
}
tumbler_am_pm.positionViewAtIndex(index,Tumbler.Center)
}
Item {
anchors.fill: parent
Connections{
target: popup
function onOpened(){
updatePosition()
}
}
Component {
id: comp_delegate
Item{
implicitHeight: 40
implicitWidth: control.width
IconButton{
id: tile
text: formatText(Tumbler.tumbler, modelData)
anchors{
fill: parent
margins: 4
}
SmoothUI.textColor: model.index === Tumbler.tumbler.currentIndex? textColor : control.SmoothUI.theme.res.textFillColorPrimary
onClicked: {
Tumbler.tumbler.currentIndex = model.index
}
}
}
}
ColumnLayout{
anchors.fill: parent
anchors.margins: 1
spacing: 0
Item{
Layout.fillHeight: true
Layout.fillWidth: true
Rectangle{
radius: control.SmoothUI.radius
height: 40
width: parent.width - 8
color: hitColor
anchors.centerIn: parent
}
RowLayout {
anchors.fill: parent
spacing: 0
Tumbler {
id: tumbler_hours
model: control.isH ? 12 : 24
delegate: comp_delegate
Layout.fillWidth: true
Layout.fillHeight: true
visibleItemCount: 9
clip: true
Rectangle{
width: parent.width
height: 40
z: 1
color: control.SmoothUI.theme.res.popupBackgroundColor
visible: tumbler_hours.hovered
radius: control.SmoothUI.radius
IconButton{
anchors{
fill: parent
margins: 4
}
background: Item{}
icon.name: FluentIcons.graph_CaretUpSolid8
icon.width: 8
icon.height: 8
scale: pressed ? 0.85 : 1
onClicked: {
let index = tumbler_hours.currentIndex-1
if(index === -1){
index = tumbler_hours.count-1
}
tumbler_hours.currentIndex = index
}
}
}
Rectangle{
width: parent.width
height: 40
z: 999
anchors.bottom: parent.bottom
color: control.SmoothUI.theme.res.popupBackgroundColor
visible: tumbler_hours.hovered
IconButton{
anchors{
fill: parent
margins: 4
}
background: Item{}
icon.name: FluentIcons.graph_CaretDownSolid8
icon.width: 8
icon.height: 8
scale: pressed ? 0.85 : 1
onClicked: {
let index = tumbler_hours.currentIndex+1
if(index === tumbler_hours.count){
index = 0
}
tumbler_hours.currentIndex = index
}
}
}
}
Rectangle{
Layout.fillHeight: true
implicitWidth: 1
color: control.SmoothUI.theme.res.controlStrokeColorDefault
}
Tumbler {
id: tumbler_minutes
model: generatePossibleMinutes(control.minuteIncrement)
delegate: comp_delegate
Layout.fillWidth: true
Layout.fillHeight: true
visibleItemCount: 9
clip: true
Rectangle{
width: parent.width
height: 40
z: 999
color: control.SmoothUI.theme.res.popupBackgroundColor
visible: tumbler_minutes.hovered
IconButton{
anchors{
fill: parent
margins: 4
}
background: Item{}
icon.name: FluentIcons.graph_CaretUpSolid8
icon.width: 8
icon.height: 8
scale: pressed ? 0.85 : 1
onClicked: {
let index = tumbler_minutes.currentIndex-1
if(index === -1){
index = tumbler_minutes.count-1
}
tumbler_minutes.currentIndex = index
}
}
}
Rectangle{
width: parent.width
height: 40
z: 999
anchors.bottom: parent.bottom
color: control.SmoothUI.theme.res.popupBackgroundColor
visible: tumbler_minutes.hovered
IconButton{
anchors{
fill: parent
margins: 4
}
background: Item{}
icon.name: FluentIcons.graph_CaretDownSolid8
icon.width: 8
icon.height: 8
scale: pressed ? 0.85 : 1
onClicked: {
let index = tumbler_minutes.currentIndex+1
if(index === tumbler_minutes.count){
index = 0
}
tumbler_minutes.currentIndex = index
}
}
}
}
Rectangle{
Layout.fillHeight: true
implicitWidth: 1
color: control.SmoothUI.theme.res.controlStrokeColorDefault
visible: control.isH
}
Tumbler {
id: tumbler_am_pm
model: [control.amText, control.pmText]
delegate: comp_delegate
Layout.fillWidth: true
Layout.fillHeight: true
visibleItemCount: 9
visible: control.isH
clip: true
}
}
}
Rectangle{
Layout.fillWidth: true
implicitHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
Item{
Layout.fillWidth: true
implicitHeight: 40
RowLayout{
anchors.fill: parent
spacing: 0
Item{
Layout.fillWidth: true
Layout.fillHeight: true
IconButton{
anchors{
fill: parent
margins: 4
}
icon.name: FluentIcons.graph_Accept
icon.width: 15
icon.height: 15
onClicked: {
const h = tumbler_hours.currentIndex+1
const m = tumbler_minutes.model[tumbler_minutes.currentIndex]
const isPm =  tumbler_am_pm.currentIndex === 1
let finalHour = 0
if(control.isH){
if (isPm) {
finalHour = (h === 12) ? 12 : h + 12
} else {
finalHour = (h === 12) ? 0 : h
}
}else{
finalHour = h - 1
}
const date = new Date()
date.setHours(finalHour)
date.setMinutes(m)
d.time = date
control.current = date
control.accepted()
popup.close()
}
}
}
Rectangle{
Layout.fillHeight: true
implicitWidth: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
Item{
Layout.fillWidth: true
Layout.fillHeight: true
IconButton{
anchors{
fill: parent
margins: 4
}
icon.name: FluentIcons.graph_Cancel
icon.width: 15
icon.height: 15
onClicked: {
popup.close()
}
}
}
}
}
}
}
}
}
}
