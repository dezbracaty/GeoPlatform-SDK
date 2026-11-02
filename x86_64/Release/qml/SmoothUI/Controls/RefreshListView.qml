/*!
\qmltype RefreshListView
\inqmlmodule SmoothUI.Controls
\brief A list view with pull-to-refresh support.
Provides a ListView with pull-to-refresh gesture, custom
refresh header/footer, and pull-to-refresh indicator.
*/
import QtQuick
import SmoothUI
import SmoothUI.impl
ListView {
id: control
SmoothUI.theme: Theme.of(control)
header: headerVisible ? comp_header : null
footer: footerVisible ? comp_footer : null
property string pullToRefreshText: qsTr("Pull to refresh")
property string releaseToRefreshText: qsTr("Release to refresh")
property string refreshingText: qsTr("Refreshing...")
property string pullToLoadMoreText: qsTr("Pull to load more")
property string releaseToLoadMoreText: qsTr("Release to load")
property string loadingMoreText: qsTr("Loading...")
property bool headerVisible: false
property bool footerVisible: false
property bool headerHold: false
property bool footerHold: false
property int  headerHeight: 32
property int footerHeight: 32
enum MoveDirection{
NoMove,
UpToDown,
DownToUp
}
property bool autoRefresh: false
property int moveDirection: RefreshListView.NoMove
property real moveStartContentY: 0
property bool readyToRefresh: false
property bool readyToLoadMore: false
signal refresh
signal loadMore
Component{
id: comp_header
Item{
width: control.width
height: control.headerHeight
Row{
anchors.centerIn: parent
spacing: 10
Icon{
anchors.verticalCenter: parent.verticalCenter
width: 14
height: 14
source: FluentIcons.graph_Down
rotation: readyToRefresh ? 180 : 0
Behavior on rotation{
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
visible: !headerHold
}
ProgressRing{
anchors.verticalCenter: parent.verticalCenter
visible: headerHold
width: 18
height: 18
strokeWidth: 3
indeterminate: true
}
Label{
anchors.verticalCenter: parent.verticalCenter
text: {
if (control.headerHold) {
control.refreshingText
} else if (control.readyToRefresh) {
control.releaseToRefreshText
} else {
control.pullToRefreshText
}
}
}
}
}
}
Component{
id: comp_footer
Item{
width: control.width
height: control.footerHeight
Row{
spacing: 10
anchors.centerIn: parent
ProgressRing{
anchors.verticalCenter: parent.verticalCenter
width: 18
height: 18
strokeWidth: 3
indeterminate: control.footerHold
}
Label{
anchors.verticalCenter: parent.verticalCenter
text: {
if (control.footerHold) {
control.loadingMoreText
} else if (control.readyToLoadMore) {
control.releaseToLoadMoreText
} else {
control.pullToLoadMoreText
}
}
}
}
}
}
Component.onCompleted: {
if(autoRefresh){
headerVisible = true
headerHold = true
}
}
onHeaderHoldChanged:{
if(headerHold)
control.refresh()
}
onFooterHoldChanged: {
if(footerHold)
control.loadMore()
}
onContentYChanged: {
if(dragging){
moveDirection = (contentY - moveStartContentY < 0) ? RefreshListView.UpToDown : RefreshListView.DownToUp
switch(moveDirection){
case RefreshListView.UpToDown:
if(contentY < -control.headerHeight){
readyToRefresh = true
} else {
readyToRefresh = false
}
if(atYBeginning && !headerVisible && !footerVisible) {
headerVisible = true
}
break
case RefreshListView.DownToUp:
var overshoot = contentHeight - (contentY + height)
if(overshoot < -control.footerHeight){
readyToLoadMore = true
} else {
readyToLoadMore = false
}
if(atYEnd && !headerVisible && !footerVisible) {
footerVisible = true
}
break
default:
break
}
}
}
onDraggingChanged: {
dragging ? pullStart() : pullEnd()
}
function pullStart(){
moveStartContentY = contentY
}
function pullEnd(){
switch(moveDirection){
case RefreshListView.UpToDown:
if(atYBeginning && headerVisible) {
headerHold = true
}else{
headerVisible = false
footerVisible = false
}
break
case RefreshListView.DownToUp:
if(atYEnd && footerVisible) {
footerHold = true
}else{
headerVisible = false
footerVisible = false
}
break
default:
break
}
moveDirection = RefreshListView.NoMove
}
function endRefresh(){
headerVisible = false
headerHold = false
}
function endLoadMore(){
footerVisible = false
footerHold = false
}
}
