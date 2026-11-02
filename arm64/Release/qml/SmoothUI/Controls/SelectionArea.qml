import QtQuick
import SmoothUI.impl
/*!
\qmltype SelectionArea
\inqmlmodule SmoothUI.Controls
\brief A mouse selection area for selecting items
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property Flickable target
property alias rectangle: area
signal areaSizeChanged(var p1,var p2)
property int threshold: 50
anchors.fill: target
parent: target
Rectangle{
id: area
property bool flag: false
property real scrollSpeed: 20
property int scrollDirections: 0
property point startPoint: Qt.point(0, 0)
property point endPoint: Qt.point(0, 0)
color: Colors.withOpacity(border.color,0.2)
border.color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
border.width: 1
x: Math.min(area.startPoint.x,area.endPoint.x) - target.contentX
y: Math.min(area.startPoint.y,area.endPoint.y) - target.contentY
width: Math.abs(area.endPoint.x - area.startPoint.x)
height: Math.abs(area.endPoint.y - area.startPoint.y)
onYChanged: debounce_timer.restart()
onXChanged: debounce_timer.restart()
onHeightChanged: debounce_timer.restart()
onWidthChanged: debounce_timer.restart()
function updateArea() {
if(flag) {
const rectX1 = x + target.contentX - target.originX
const rectY1 = y + target.contentY - target.originY
const rectX2 = rectX1 + width
const rectY2 = rectY1 + height
control.areaSizeChanged(Qt.point(rectX1,rectY1), Qt.point(rectX2,rectY2))
}
}
}
MouseArea{
id: ma
property bool isDragging: false
property point pressPosition: Qt.point(0,0)
property int minimumDragDistance: 20
property point screenPos: Qt.point(0,0)
anchors.fill: parent
propagateComposedEvents: true
preventStealing : true
onPressed:
(mouse)=> {
const mouseX = mouse.x
const mouseY = mouse.y
pressPosition = Qt.point(mouseX, mouseY)
area.flag = true
area.startPoint = Qt.point(mouse.x + target.contentX, mouse.y + target.contentY)
area.endPoint = Qt.point(mouse.x + target.contentX, mouse.y + target.contentY)
}
onPositionChanged:
(mouse)=> {
screenPos = Qt.point(mouse.x, mouse.y)
const mouseX = mouse.x
const mouseY = mouse.y
const distance = Math.sqrt(Math.pow(mouseX - pressPosition.x, 2) + Math.pow(mouseY - pressPosition.y, 2))
if (distance > minimumDragDistance) {
isDragging = true
}
if(isDragging){
let directions = 0
let hOffset = 0, vOffset = 0
if(mouse.y < control.threshold) {
directions |= Qt.TopEdge
vOffset = Math.abs(mouse.y - control.threshold)
} else if(mouse.y > target.height - control.threshold) {
directions |= Qt.BottomEdge
vOffset = mouse.y - target.height + control.threshold
}
if(mouse.x < control.threshold) {
directions |= Qt.LeftEdge
hOffset = Math.abs(mouse.x - control.threshold)
} else if(mouse.x > target.width-control.threshold) {
directions |= Qt.RightEdge
hOffset = mouse.x - target.width + control.threshold
}
area.scrollDirections = directions
area.scrollSpeed = Math.min(Math.max(Math.max(hOffset, vOffset) * 0.5, 10),100)
if(directions) scroll_animation.start()
else scroll_animation.stop()
area.endPoint = Qt.point(screenPos.x + target.contentX, screenPos.y + target.contentY)
}
}
onReleased:
(mouse)=> {
isDragging = false
area.flag = false
area.startPoint = Qt.point(0,0)
area.endPoint = Qt.point(0,0)
scroll_animation.stop()
}
onCanceled:
(mouse)=> {
isDragging = false
area.flag = false
area.startPoint = Qt.point(0,0)
area.endPoint = Qt.point(0,0)
scroll_animation.stop()
}
onClicked:
(mouse)=>{
if(isDragging){
mouse.accepted = true
}else{
mouse.accepted = false
}
}
}
Timer{
id: debounce_timer
interval: 16
onTriggered: area.updateArea()
}
Timer{
id: scroll_animation
interval: 30
repeat: true
onTriggered: {
const maxX = Math.max(target.contentWidth - target.width + target.originX, target.originX)
const maxY = Math.max(target.contentHeight - target.height + target.originY, target.originY)
if(area.scrollDirections & Qt.TopEdge) {
target.contentY = Math.max(target.contentY - area.scrollSpeed, target.originY)
}
if(area.scrollDirections & Qt.BottomEdge) {
target.contentY = Math.min(target.contentY + area.scrollSpeed, maxY)
}
if(area.scrollDirections & Qt.LeftEdge) {
target.contentX = Math.max(target.contentX - area.scrollSpeed, target.originX)
}
if(area.scrollDirections & Qt.RightEdge) {
target.contentX = Math.min(target.contentX + area.scrollSpeed, maxX)
}
if(ma.isDragging) {
area.endPoint = Qt.point(ma.screenPos.x + target.contentX, ma.screenPos.y + target.contentY)
}
}
}
}
