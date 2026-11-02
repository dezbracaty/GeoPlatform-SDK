/*!
\qmltype CalendarPicker
\inqmlmodule SmoothUI.Controls
\brief A date/time picker with calendar popup.
Provides a button-triggered calendar popup for date selection,
with optional time picker mode, configurable date range, and
custom format strings.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import SmoothUI.impl
StandardButton {
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property string formart: showTime ? "yyyy-M-d HH:mm:ss" : "yyyy/M/d"
property date from: new Date(1924, 0, 1)
property date to: new Date(2124, 11, 31)
property var current
property bool showTime: false
property string hourText: qsTr("hour")
property string minuteText: qsTr("minute")
property int hourFormat: TimePickerType.H
property int minuteIncrement: 1
signal accepted()
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
text: {
if(control.current){
return control.current.toLocaleString(control.locale,formart)
}
return qsTr("Pick a date")
}
id: control
icon.name: FluentIcons.graph_Calendar
icon.width: 14
icon.height: 14
horizontalPadding: Theme.controlHorizontalPadding
LayoutMirroring.enabled: true
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
height: 350
width: control.showTime ? 500 : 300
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
Component.onCompleted: {
popup.popup(control)
}
onClosed:{
loader_popup.sourceComponent = undefined
}
CalendarModel {
id: calendar_model
from: control.from
to: control.to
}
Item{
anchors.fill: parent
Item{
id: d
property var window : Window.window
property date displayDate: {
if(control.current){
return control.current
}
return new Date()
}
property date toDay : new Date()
property int pageIndex: 0
signal nextButton
signal previousButton
property point yearRing : Qt.point(0,0)
property bool isPm: displayDate.getHours() >= 12
function formatHour(hour) {
const date = new Date(0, 0, 0, hour)
return date.toLocaleTimeString(locale, "HH")
}
function formatMinute(minute) {
const date = new Date(0, 0, 0, 0, minute)
return date.toLocaleTimeString(locale, "mm")
}
function finalHour(hour){
return hour
}
}
AutoLoader{
visible: control.showTime
height: parent.height
width: 200
anchors.right: parent.right
sourceComponent: visible ? comp_time_pane : undefined
}
Component{
id: comp_time_pane
Item {
property color hitColor: control.SmoothUI.dark ? control.accentColor.lightest() : control.accentColor.darkest()
property color textColor: Colors.basedOnLuminance(hitColor)
function formatText(tumbler, modelData) {
const data = modelData
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
let index = h
if(index !== -1){
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
if(index !== -1){
tumbler_minutes.positionViewAtIndex(index,Tumbler.Center)
}
index = -1
const s = date.getSeconds()
index = s
if(index !== -1){
tumbler_second.positionViewAtIndex(index,Tumbler.Center)
}
}
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
Rectangle{
anchors{
top: parent.top
bottom: parent.bottom
left: parent.left
}
width: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
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
model: 24
delegate: comp_delegate
Layout.fillWidth: true
Layout.fillHeight: true
visibleItemCount: 9
clip: true
Rectangle{
width: parent.width
height: 30
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
height: 30
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
height: 30
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
height: 30
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
}
Tumbler {
id: tumbler_second
model: 60
delegate: comp_delegate
Layout.fillWidth: true
Layout.fillHeight: true
visibleItemCount: 9
clip: true
Rectangle{
width: parent.width
height: 30
z: 999
color: control.SmoothUI.theme.res.popupBackgroundColor
visible: tumbler_second.hovered
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
let index = tumbler_second.currentIndex-1
if(index === -1){
index = tumbler_second.count-1
}
tumbler_second.currentIndex = index
}
}
}
Rectangle{
width: parent.width
height: 30
z: 999
anchors.bottom: parent.bottom
color: control.SmoothUI.theme.res.popupBackgroundColor
visible: tumbler_second.hovered
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
let index = tumbler_second.currentIndex+1
if(index === tumbler_second.count){
index = 0
}
tumbler_second.currentIndex = index
}
}
}
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
const h = tumbler_hours.currentIndex
const m = tumbler_minutes.currentIndex
const s =  tumbler_second.currentIndex
const date = d.displayDate
date.setHours(h)
date.setMinutes(m)
date.setSeconds(s)
d.displayDate = date
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
ColumnLayout  {
height: parent.height
width: 300
spacing: 0
Item{
Layout.fillWidth: true
Layout.preferredHeight: 50
RowLayout{
anchors.fill: parent
spacing: 10
Item{
Layout.leftMargin: parent.spacing
Layout.fillWidth: true
Layout.fillHeight: true
IconButton{
width: parent.width
anchors.centerIn: parent
visible: d.pageIndex === 0
Label{
text: d.displayDate.toLocaleString(control.locale, "MMMM yyyy")
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 10
}
}
onClicked: {
d.pageIndex = 1
}
}
IconButton{
width: parent.width
anchors.centerIn: parent
visible: d.pageIndex === 1
Label{
text: d.displayDate.toLocaleString(control.locale, "yyyy")
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 10
}
}
onClicked: {
d.pageIndex = 2
}
}
IconButton{
width: parent.width
anchors.centerIn: parent
visible: d.pageIndex === 2
enabled: false
Label{
text: "%1-%2".arg(d.yearRing.x).arg(d.yearRing.y)
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 10
}
}
}
}
IconButton{
id: icon_up
icon.name: FluentIcons.graph_CaretUpSolid8
icon.width: 10
icon.height: 10
onClicked: {
d.previousButton()
}
}
IconButton{
id: icon_down
icon.name: FluentIcons.graph_CaretDownSolid8
icon.width: 10
icon.height: 10
Layout.rightMargin: parent.spacing
onClicked: {
d.nextButton()
}
}
}
Rectangle{
width: parent.width
height: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
anchors.bottom: parent.bottom
}
}
Item{
Layout.fillWidth: true
Layout.fillHeight: true
StackView{
id: stack_view
anchors.fill: parent
initialItem: com_page_one
replaceEnter : Transition{
NumberAnimation{
property: "opacity"
from: 0
to: 1
duration: Theme.fasterAnimationDuration
}
NumberAnimation{
property: "scale"
from: 0.5
to: 1
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
replaceExit : Transition{
NumberAnimation{
property: "opacity"
from: 1
to: 0
duration: Theme.fasterAnimationDuration
}
NumberAnimation{
property: "scale"
from: 1.0
to: 0.5
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
Connections{
target: d
function onPageIndexChanged(){
if(d.pageIndex === 0){
stack_view.replace(com_page_one)
}
if(d.pageIndex === 1){
stack_view.replace(com_page_two)
}
if(d.pageIndex === 2){
stack_view.replace(com_page_three)
}
}
}
Component{
id: com_page_three
GridView{
id: grid_view
cellHeight: 75
cellWidth: 75
clip: true
boundsBehavior: GridView.StopAtBounds
ScrollBar.vertical: ScrollBar {}
model: {
const fromYear = calendar_model.from.getFullYear()
const toYear = calendar_model.to.getFullYear()
return toYear-fromYear+1
}
highlightRangeMode: GridView.StrictlyEnforceRange
onCurrentIndexChanged:{
const year = currentIndex + calendar_model.from.getFullYear()
const start = Math.ceil(year / 10) * 10
const end = start+10
d.yearRing = Qt.point(start,end)
}
highlightMoveDuration: Theme.fastAnimationDuration
Component.onCompleted: {
grid_view.highlightMoveDuration = 0
currentIndex = d.displayDate.getFullYear()-calendar_model.from.getFullYear()
timer_delay.restart()
}
Connections{
target: d
function onNextButton(){
grid_view.currentIndex = Math.min(grid_view.currentIndex+16,grid_view.count-1)
}
function onPreviousButton(){
grid_view.currentIndex = Math.max(grid_view.currentIndex-16,0)
}
}
Timer{
id: timer_delay
interval: 100
onTriggered: {
grid_view.highlightMoveDuration = Theme.fastAnimationDuration
}
}
currentIndex: -1
delegate: Item{
property int year : calendar_model.from.getFullYear()+modelData
property bool toYear: year === d.toDay.getFullYear()
implicitHeight: 75
implicitWidth: 75
IconButton{
id: control_delegate
width: 60
height: 60
anchors.centerIn: parent
radius: 30
highlighted: toYear
accentColor: control.accentColor
Label{
text: year
anchors.centerIn: parent
opacity: {
if(toYear){
return 1
}
if(year >= d.yearRing.x &&  year <= d.yearRing.y){
return 1
}
if(control_delegate.hovered){
return 1
}
return 0.3
}
color: {
if(toYear)
return Colors.white
if(control_delegate.pressed)
return control.SmoothUI.theme.res.textFillColorSecondary
if(control_delegate.hovered)
return control.SmoothUI.theme.res.textFillColorTertiary
return control.SmoothUI.theme.res.textFillColorPrimary
}
}
onClicked: {
d.displayDate = new Date(year,0,1)
d.pageIndex = 1
}
}
}
}
}
Component{
id: com_page_two
ListView{
id: listview
ScrollBar.vertical: ScrollBar {}
highlightRangeMode: ListView.StrictlyEnforceRange
clip: true
boundsBehavior: ListView.StopAtBounds
spacing: 0
highlightMoveDuration: Theme.fastAnimationDuration
model: {
const fromYear = calendar_model.from.getFullYear()
const toYear = calendar_model.to.getFullYear()
const yearsArray = []
for (let i = fromYear; i <= toYear; i++) {
yearsArray.push(i)
}
return yearsArray
}
currentIndex: -1
onCurrentIndexChanged:{
const year = model[currentIndex]
const month = d.displayDate.getMonth()
d.displayDate = new Date(year,month,1)
}
Connections{
target: d
function onNextButton(){
listview.currentIndex = Math.min(listview.currentIndex+1,listview.count-1)
}
function onPreviousButton(){
listview.currentIndex = Math.max(listview.currentIndex-1,0)
}
}
Component.onCompleted: {
listview.highlightMoveDuration = 0
currentIndex = model.indexOf(d.displayDate.getFullYear())
timer_delay.restart()
}
Timer{
id: timer_delay
interval: 100
onTriggered: {
listview.highlightMoveDuration = Theme.fastAnimationDuration
}
}
delegate: Item{
id: layout_control
property int year : modelData
width: listview.width
height: 75*3
GridView{
anchors.fill: parent
cellHeight: 75
cellWidth: 75
clip: true
interactive: false
boundsBehavior: GridView.StopAtBounds
model: 12
delegate: Item{
property int month : modelData
property bool toMonth: layout_control.year === d.toDay.getFullYear() && month === d.toDay.getMonth()
implicitHeight: 75
implicitWidth: 75
IconButton{
id: control_delegate
width: 60
height: 60
radius: 30
highlighted: toMonth
accentColor: control.accentColor
anchors.centerIn: parent
Label{
text: new Date(layout_control.year,month).toLocaleString(control.locale, "MMMM")
anchors.centerIn: parent
opacity: {
if(toMonth){
return 1
}
if(layout_control.year === d.displayDate.getFullYear()){
return 1
}
if(control_delegate.hovered){
return 1
}
return 0.3
}
color: {
if(toMonth)
return Colors.white
if(control_delegate.pressed)
return control.SmoothUI.theme.res.textFillColorSecondary
if(control_delegate.hovered)
return control.SmoothUI.theme.res.textFillColorTertiary
return control.SmoothUI.theme.res.textFillColorPrimary
}
}
onClicked: {
d.displayDate = new Date(layout_control.year,month)
d.pageIndex = 0
}
}
}
}
}
}
}
Component{
id: com_page_one
ColumnLayout  {
DayOfWeekRow {
id: row_day_of_week
locale: control.locale
font: Typography.body
delegate: Label {
text: model.shortName
font: row_day_of_week.font
horizontalAlignment: Text.AlignHCenter
verticalAlignment: Text.AlignVCenter
}
Layout.column: 1
Layout.fillWidth: true
}
ListView{
id: listview
property bool isCompleted: false
Layout.fillWidth: true
Layout.fillHeight: true
highlightRangeMode: ListView.StrictlyEnforceRange
clip: true
boundsBehavior: ListView.StopAtBounds
spacing: 0
highlightMoveDuration: Theme.fastAnimationDuration
currentIndex: -1
reuseItems: true
ScrollBar.vertical: ScrollBar {}
onCurrentIndexChanged:{
if(isCompleted){
const month = calendar_model.monthAt(currentIndex)
const year = calendar_model.yearAt(currentIndex)
d.displayDate = new Date(year,month,1)
}
}
Component.onCompleted: {
listview.model = calendar_model
listview.highlightMoveDuration = 0
currentIndex  = calendar_model.indexOf(d.displayDate)
timer_delay.restart()
isCompleted = true
}
Timer{
id: timer_delay
interval: 100
onTriggered: {
listview.highlightMoveDuration = Theme.fastAnimationDuration
}
}
Connections{
target: d
function onNextButton(){
listview.currentIndex = Math.min(listview.currentIndex+1,listview.count-1)
}
function onPreviousButton(){
listview.currentIndex = Math.max(listview.currentIndex-1,0)
}
}
delegate: MonthGrid {
id: grid
width: listview.width
height: listview.height
month: model.month
year: model.year
spacing: 0
locale: control.locale
delegate: Item{
required property bool today
required property int year
required property int month
required property int day
required property int visibleMonth
property color hitColor: control.SmoothUI.dark ? control.accentColor.lightest() : control.accentColor.darkest()
visibleMonth: grid.month
IconButton {
id: control_delegate
implicitHeight: 40
implicitWidth: 40
radius: 20
anchors.centerIn: parent
Rectangle{
width: 34
height: 34
radius: width/2
anchors.centerIn: parent
color:today ? hitColor : "transparent"
}
Rectangle{
width: 40
height: 40
border.width: 1
anchors.centerIn: parent
radius: width/2
border.color: hitColor
color: "transparent"
visible: {
if(d.displayDate){
const yy = d.displayDate.getFullYear()
const mm = d.displayDate.getMonth()
const dd =  d.displayDate.getDate()
if(yy === year && mm === month && dd === day){
return true
}
return false
}
return false
}
}
Label{
text: day
opacity: {
if(today){
return 1
}
if(month === grid.month){
return 1
}
if(control_delegate.hovered){
return 1
}
return 0.3
}
anchors.centerIn: parent
color: {
if(today)
return Colors.white
if(control_delegate.pressed)
return control.SmoothUI.theme.res.textFillColorSecondary
if(control_delegate.hovered)
return control.SmoothUI.theme.res.textFillColorTertiary
return control.SmoothUI.theme.res.textFillColorPrimary
}
}
onClicked: {
if(control.showTime){
d.displayDate = new Date(year,month,day)
}else{
control.current = new Date(year,month,day)
control.accepted()
popup.close()
}
}
}
}
background: Item {
x: grid.leftPadding
y: grid.topPadding
width: grid.availableWidth
height: grid.availableHeight
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
}
