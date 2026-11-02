/*!
\qmltype Chart
\inqmlmodule SmoothUI.Controls
\brief A charting component supporting multiple chart types.
Provides data visualization on a \l Canvas using the integrated
Chart.js rendering engine. Supports animations, configurable
options, and dynamic data updates.
*/
import QtQuick
import QtQuick.Controls
import "Chart.js" as Chart
Canvas {
id: control
property string type
property var datas
property var options
property double chartAnimationProgress: 0.1
property int animationEasingType: Theme.animationCurve
property double animationDuration: Theme.slowAnimationDuration
property alias animationRunning: anim_chart.running
signal animationFinished()
function animateToNewData()
{
chartAnimationProgress = 0.1
d.jsChart.update()
anim_chart.restart()
}
QtObject{
id: d
property var jsChart: undefined
property var cachedContext
property var cachedData
property var cachedOptions
}
MouseArea {
id: event
anchors.fill: parent
hoverEnabled: true
enabled: true
property var handler: undefined
property QtObject mouseEvent: QtObject {
property int left: 0
property int top: 0
property int x: 0
property int y: 0
property int clientX: 0
property int clientY: 0
property string type: ""
property var target
}
function submitEvent(mouse, type) {
mouseEvent.type = type
mouseEvent.clientX = mouse ? mouse.x : 0
mouseEvent.clientY = mouse ? mouse.y : 0
mouseEvent.x = mouse ? mouse.x : 0
mouseEvent.y = mouse ? mouse.y : 0
mouseEvent.left = 0
mouseEvent.top = 0
mouseEvent.target = control
if(handler) {
handler(mouseEvent)
}
control.requestPaint()
}
onClicked:
(mouse)=> {
submitEvent(mouse, "click")
}
onPositionChanged:
(mouse)=> {
submitEvent(mouse, "mousemove")
}
onExited: {
submitEvent(undefined, "mouseout")
}
onEntered: {
submitEvent(undefined, "mouseenter")
}
onPressed:
(mouse)=> {
submitEvent(mouse, "mousedown")
}
onReleased:
(mouse)=> {
submitEvent(mouse, "mouseup")
}
}
PropertyAnimation {
id: anim_chart
target: control
property: "chartAnimationProgress"
alwaysRunToEnd: true
to: 1
duration: control.animationDuration
easing.type: control.animationEasingType
onFinished: {
control.animationFinished()
}
}
onChartAnimationProgressChanged: {
control.requestPaint()
}
onPaint: {
if(control.getContext('2d') !== null && d.cachedContext !== control.getContext('2d') || d.cachedData !== control.datas || d.cachedOptions !== control.options) {
var ctx = control.getContext('2d')
d.jsChart =  Chart.build(ctx, {type: control.type,data: control.datas,options: control.options})
d.cachedData = control.datas
d.cachedContext = control.getContext('2d')
d.cachedOptions = control.options
d.jsChart.bindEvents(function(newHandler) {event.handler = newHandler})
anim_chart.start()
}
d.jsChart.draw(chartAnimationProgress)
}
onWidthChanged: {
if(d.jsChart) {
d.jsChart.resize()
}
}
onHeightChanged: {
if(d.jsChart) {
d.jsChart.resize()
}
}
}
