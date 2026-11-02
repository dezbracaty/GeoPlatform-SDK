import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype TreeDataGrid
\inqmlmodule SmoothUI.Controls
\brief A tree-structured data grid view
*/
Item{
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
required property var sourceModel
required property var columnSourceModel
property var columnWidthProvider : function(column){
var val =  columnSourceModel.get(column)
if(!val){
return d.defaultWidth
}
var width = d.defaultWidth
if(val.width){
width = val.width
}
return width
}
property alias defaultColumnHeader: comp_column_header
property var columnHeaderProvider : function(dataIndex){
return defaultColumnHeader
}
property alias defaultDelegate: comp_display
property var delegateProvider : function(dataIndex){
return defaultDelegate
}
property alias defaultEditDelegate: comp_edit
property var editDelegateProvider : function(dataIndex){
return defaultEditDelegate
}
property var rowHeightProvider : function(row){
var val =  sourceModel.get(row)
if(!val){
return d.defaultHeight
}
if(val){
var height = d.defaultHeight
if(val.height){
height = val.height
}
return height
}
return d.defaultHeight
}
property color rowCheckedColor: Colors.withOpacity(control.accentColor.defaultBrushFor(control.SmoothUI.dark),0.1)
property color rowCurrentColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
property bool horizonalHeaderVisible: true
property bool verticalHeaderVisible: true
property int horizonalHeaderHeight: 40
property alias view: list_table
property alias delegateModel: source_delegate_model
property alias selectionModel: selected_items
signal rowClicked(var model)
signal rowRightClicked(var model)
property Component cellBackground: Component{
Rectangle{
color: {
if(isSelected){
return control.rowCheckedColor
}
if(rowPressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(rowHoverd){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return rowModel.index%2===0 ? control.SmoothUI.theme.res.subtleFillColorTertiary : control.SmoothUI.theme.res.subtleFillColorTransparent
}
}
}
property Component cellForeground: Component{
Item{
visible: isCurrentRow
Rectangle{
width: 1/Screen.devicePixelRatio
height: parent.height
anchors.left: parent.left
color: control.rowCurrentColor
visible: columnModel.index === 0
}
Rectangle{
width: 1/Screen.devicePixelRatio
height: parent.height
anchors.right: parent.right
color: control.rowCurrentColor
visible: columnModel.index === control.columnSourceModel.count-1
}
Rectangle{
width: parent.width
height: 1/Screen.devicePixelRatio
anchors.top: parent.top
color: control.rowCurrentColor
}
Rectangle{
width: parent.width
height: 1/Screen.devicePixelRatio
anchors.bottom: parent.bottom
color: control.rowCurrentColor
}
}
}
clip: true
QtObject{
id: d
property int defaultWidth: 120
property int defaultHeight: 40
property var editPoint: null
property int horizonalHeaderHeight: control.horizonalHeaderVisible ? control.horizonalHeaderHeight : 0
property int verticalHeaderHeight: 50
}
Component{
id: comp_display
Item{
Label{
text: String(display)
elide: Label.ElideRight
maximumLineCount: 1
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 10
right: parent.right
rightMargin: 10
}
}
}
}
Component{
id: comp_column_header
Label{
anchors.fill: parent
text: columnModel.title
verticalAlignment: Qt.AlignVCenter
leftPadding: 10
rightPadding: 10
elide: Label.ElideRight
}
}
Component{
id: comp_edit
ScrollableTextBox{
TextArea.flickable: MultiLineTextBox{
id: text_box
wrapMode: Text.WrapAnywhere
implicitWidth: control.width
topPadding: 4
bottomPadding: 4
padding: 0
leftPadding: 10
rightPadding: 10
verticalAlignment: Qt.AlignVCenter
onActiveFocusChanged: {
if(!activeFocus){
control.closeEditor()
}
}
Component.onCompleted: {
text = display
forceActiveFocus()
selectAll()
}
Keys.onEnterPressed: {
changeDisplay()
}
Keys.onReturnPressed: {
changeDisplay()
}
}
function changeDisplay(){
rowModel[columnModel.dataIndex] = text_box.text
control.closeEditor()
}
}
}
ItemSelectionModel{
id: selected_items
model: control.sourceModel
}
DelegateModel{
id: source_delegate_model
model: control.sourceModel
delegate: Item{
id: item_layout
property var rowModel: model
property bool rowHoverd: row_hover_handler.hovered
property bool rowPressed: row_tap_handler.pressed
property bool isCurrentRow: ListView.isCurrentItem
property bool hide: false
property bool isSelected: {
selected_items.selectedIndexes
return selected_items.isSelected(control.sourceModel.index(model.index,0))
}
visible: !hide
implicitWidth: item_layout_row.width
implicitHeight: {
model.height
return control.rowHeightProvider(model.index)
}
opacity: 0
onIsCurrentRowChanged: {
if(model.index<0){
list_table.currentIndex = -1
}
}
Component.onCompleted: {
opacity = 1
}
ListView.onPooled:{
item_layout.hide = true
}
ListView.onReused:{
item_layout.hide = false
}
ListView.onRemove:{
item_layout.hide = true
}
ListView.onAdd:{
item_layout.hide = false
}
HoverHandler{
id: row_hover_handler
}
Keys.onPressed:
(event)=>{
if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_A) {
control.sourceModel.selectRange(selected_items,0,control.sourceModel.count-1)
}
}
MouseArea{
id: row_tap_handler
acceptedButtons: Qt.LeftButton | Qt.RightButton
anchors.fill: parent
onClicked:
(mouse)=> {
if(mouse.button === Qt.RightButton){
control.rowRightClicked(model)
return
}
if(!(mouse.modifiers & Qt.ControlModifier)){
selected_items.clear()
}
if(mouse.modifiers & Qt.ShiftModifier){
if (list_table.currentIndex === -1) {
item_layout.forceActiveFocus()
list_table.currentIndex = model.index
selected_items.select(control.sourceModel.index(model.index,0), ItemSelectionModel.Select)
} else {
var start = Math.min(list_table.currentIndex, model.index)
var end = Math.max(list_table.currentIndex, model.index)
control.sourceModel.selectRange(selected_items, start, end)
}
return
}
control.rowClicked(model)
if(item_layout.isSelected){
selected_items.select(control.sourceModel.index(model.index,0),ItemSelectionModel.Deselect)
}else{
selected_items.select(control.sourceModel.index(model.index,0),ItemSelectionModel.Select)
}
item_layout.forceActiveFocus()
list_table.currentIndex = model.index
}
}
Rectangle{
width: list_table.leftMargin
height: item_layout.height
parent: item_layout.hide ? item_layout : list_table
visible: item_layout.visible && control.verticalHeaderVisible
y: item_layout.y-list_table.contentY
z: 988
color: control.SmoothUI.theme.res.micaBackgroundColor
Rectangle{
anchors.fill: parent
color:{
if(mouse_header_row.pressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(mouse_header_row.containsMouse){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
}
MouseArea {
id: mouse_header_row
anchors.fill: parent
hoverEnabled: true
}
Label{
id: text_index
text: {
if(index === -1){
return ""
}
return index+1
}
verticalAlignment: Qt.AlignVCenter
leftPadding: 10
rightPadding: 10
elide: Label.ElideRight
anchors.centerIn: parent
onWidthChanged: {
timer_width.textWidth = text_index.implicitWidth
timer_width.restart()
}
Timer{
id: timer_width
property int textWidth: 50
interval: 30
onTriggered: {
d.verticalHeaderHeight = Math.max(50, timer_width.textWidth + 8)
}
}
}
Rectangle{
width: parent.width
height: 1
anchors.bottom: parent.bottom
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
Rectangle{
width: 1
height: parent.height
anchors.right: parent.right
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
MouseArea{
property point clickPos: "0,0"
width: parent.width
height: 6
cursorShape: Qt.SplitVCursor
anchors.bottom: parent.bottom
onPressed :
(mouse)=>{
control.closeEditor()
list_table.interactive = false
Tools.setOverrideCursor(Qt.SplitVCursor)
clickPos = Qt.point(mouse.x, mouse.y)
}
onReleased:{
list_table.interactive = true
Tools.restoreOverrideCursor()
}
onCanceled: {
list_table.interactive = true
Tools.restoreOverrideCursor()
}
onPositionChanged:
(mouse)=>{
if(!pressed){
return
}
var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
var minimumHeight = model.minimumHeight
var maximumHeight = model.maximumHeight
if(!minimumHeight){
minimumHeight = 10
}
if(!maximumHeight){
maximumHeight = 65535
}
var height = d.defaultHeight
if(model.height){
height = model.height
}
model.height = Math.min(Math.max(minimumHeight, height + delta.y),maximumHeight)
}
}
}
Row{
id: item_layout_row
spacing: 0
height: item_layout.implicitHeight
Repeater{
model: control.columnSourceModel
delegate: Item{
id: item_layout_display
implicitWidth: item_loader_content.width
implicitHeight: item_loader_content.height
property bool isFrozenOffset: {
if(true === frozen){
if(Number(item_loader_content.x+list_table.contentX) === Number(item_layout_display.x)){
return false
}
return true
}
return false
}
Rectangle{
id: item_loader_content
width: {
if(model){
return control.columnWidthProvider(model.index)
}
return 0
}
height: item_layout.implicitHeight
z: 89
visible: item_layout.visible
opacity: item_layout.opacity
parent: {
if(item_layout.hide){
return item_layout_display
}
return frozen ? list_table : item_layout_display
}
y: frozen ? (item_layout.y-list_table.contentY) : 0
x: {
if(frozen){
var minX = list_table.leftMargin
var maxX = control.width-width
for(var i=0;i<model.index;i++){
var item = control.columnSourceModel.get(i)
if(item.frozen){
minX = minX + control.columnWidthProvider(i)
}
}
for(i=model.index+1;i<control.columnSourceModel.count;i++){
item = control.columnSourceModel.get(i)
if(item.frozen){
maxX =  maxX - control.columnWidthProvider(i)
}
}
return Math.min(Math.max(item_layout_display.x - list_table.contentX,minX),maxX)
}
return 0
}
color: {
if(isFrozenOffset){
return control.SmoothUI.theme.res.micaBackgroundColor
}
return Colors.transparent
}
AutoLoader{
property var display: item_row_loader.display
property var columnModel: item_row_loader.columnModel
property var rowModel: item_row_loader.rowModel
property bool isCurrentRow: item_layout.isCurrentRow
property bool rowPressed: item_layout.rowPressed
property bool rowHoverd: item_layout.rowHoverd
property bool isSelected: item_layout.isSelected
anchors.fill: parent
sourceComponent: control.cellBackground
}
MouseArea{
propagateComposedEvents: true
anchors.fill: parent
onDoubleClicked:
(mouse)=>{
d.editPoint = Qt.point(model.index,rowModel.index)
mouse.accepted = false
}
onClicked:
(mouse)=>{
control.closeEditor()
mouse.accepted = false
}
}
Repeater{
model: 4
Rectangle{
visible: isFrozenOffset
width: index
height: parent.height
x: -index
color: control.SmoothUI.theme.res.textFillColorPrimary
opacity: 0.01 * (4-index+1)
}
}
Repeater{
model: 4
Rectangle{
visible: isFrozenOffset
width: index
height: parent.height
x: parent.width-1
color: control.SmoothUI.theme.res.textFillColorPrimary
opacity: 0.01 * (4-index+1)
}
}
AutoLoader{
id: item_row_loader
anchors.fill: parent
anchors.margins: 1
sourceComponent: {
return control.delegateProvider(item_row_loader.columnModel.dataIndex)
}
property var columnModel: model
property bool frozen: {
if(model.frozen === undefined){
return false
}
return model.frozen
}
property var display: rowModel[columnModel.dataIndex]
property var rowModel: item_layout.rowModel
}
Rectangle{
anchors.fill: item_row_loader
color: control.SmoothUI.theme.res.micaBackgroundColor
visible: {
if(item_loader_edit.sourceComponent)
return true
return false
}
AutoLoader{
id: item_loader_edit
anchors.fill: parent
property var display: item_row_loader.display
property var columnModel: item_row_loader.columnModel
property var rowModel: item_row_loader.rowModel
property bool isCurrentRow: item_layout.isCurrentRow
property bool rowPressed: item_layout.rowPressed
property bool rowHoverd: item_layout.rowHoverd
sourceComponent: {
if(d.editPoint === null){
return undefined
}
if(d.editPoint.x !== model.index){
return undefined
}
if(d.editPoint.y !== rowModel.index){
return undefined
}
return control.editDelegateProvider(item_row_loader.columnModel.dataIndex)
}
}
}
AutoLoader{
property var display: item_row_loader.display
property var columnModel: item_row_loader.columnModel
property var rowModel: item_row_loader.rowModel
property bool isCurrentRow: item_layout.isCurrentRow
anchors.fill: parent
sourceComponent: control.cellForeground
}
}
}
}
}
}
}
ListView{
id: list_table
model: source_delegate_model
flickableDirection: Flickable.HorizontalAndVerticalFlick
width: control.width
highlightFollowsCurrentItem: false
height: control.height - d.horizonalHeaderHeight
y: d.horizonalHeaderHeight
ScrollBar.vertical: scrollbar_v
ScrollBar.horizontal: scrollbar_h
boundsBehavior: ListView.StopAtBounds
contentWidth:{
if(Number(contentItem.childrenRect.width) === 0){
return horizontal_list_header.contentWidth
}
return contentItem.childrenRect.width
}
currentIndex: -1
reuseItems: true
leftMargin: control.verticalHeaderVisible ? d.verticalHeaderHeight : 0
Rectangle{
width: list_table.leftMargin
height: d.horizonalHeaderHeight
y: -d.horizonalHeaderHeight
color: control.SmoothUI.theme.res.micaBackgroundColor
visible: control.horizonalHeaderVisible
Rectangle{
width: parent.width
height: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
anchors.bottom: parent.bottom
}
z: 999
Rectangle{
width: 1
height: parent.height
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
anchors.right: parent.right
}
}
Rectangle{
id: horizontal_header
width: list_table.width
height: d.horizonalHeaderHeight
x: list_table.x
y: -d.horizonalHeaderHeight
z: 99
visible: control.horizonalHeaderVisible
color: control.SmoothUI.theme.res.micaBackgroundColor
ListView{
id: horizontal_list_header
anchors.fill: parent
model: control.columnSourceModel
leftMargin: list_table.leftMargin
interactive: false
contentWidth: list_table.contentWidth
contentX: list_table.contentX
displaced: Transition {
NumberAnimation {
properties: "x,y"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
cacheBuffer: Math.max(65535,contentWidth)
orientation: ListView.Horizontal
delegate: Item{
id: layout_header_column
implicitWidth: layout_header_column_content.width
implicitHeight: layout_header_column_content.height
property bool isFrozenOffset: {
if(frozen){
if(Number(layout_header_column_content.x+list_table.contentX) === Number(layout_header_column.x)){
return false
}
return true
}
return false
}
DropArea{
anchors.fill: parent
onEntered:
(drag)=>{
if(!frozen){
control.columnSourceModel.move(drag.source.visualIndex, layout_header_column_content.visualIndex,1)
}
}
}
Rectangle{
property int visualIndex: model.index
id: layout_header_column_content
width: control.columnWidthProvider(model.index)
height: horizontal_header.height
Drag.active: mouse_header_column.drag.active
Drag.source: layout_header_column_content
Drag.hotSpot.x: width/2
z: 102
visible: control.horizonalHeaderVisible
parent: frozen ? list_table : layout_header_column
y: frozen ? -d.horizonalHeaderHeight : 0
x: {
if(frozen){
var minX = list_table.leftMargin
var maxX = control.width-width
for(var i=0;i<model.index;i++){
var item = control.columnSourceModel.get(i)
if(item.frozen){
minX = minX + control.columnWidthProvider(i)
}
}
for(i=model.index+1;i<control.columnSourceModel.count;i++){
item = control.columnSourceModel.get(i)
if(item.frozen){
maxX =  maxX - control.columnWidthProvider(i)
}
}
return Math.min(Math.max(layout_header_column.x - list_table.contentX,minX),maxX)
}
return 0
}
color: control.SmoothUI.theme.res.micaBackgroundColor
Rectangle{
anchors.fill: parent
color:{
if(mouse_header_column.pressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(mouse_header_column.containsMouse){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
}
Repeater{
model: 4
Rectangle{
visible: isFrozenOffset
width: index
height: parent.height
x: -index
color: control.SmoothUI.theme.res.textFillColorPrimary
opacity: 0.01 * (4-index+1)
}
}
Repeater{
model: 4
Rectangle{
visible: isFrozenOffset
width: index
height: parent.height
x: parent.width-1
color: control.SmoothUI.theme.res.textFillColorPrimary
opacity: 0.01 * (4-index+1)
}
}
states: [
State {
when: mouse_header_column.drag.active
ParentChange {
target: layout_header_column_content
parent: control
}
AnchorChanges {
target: layout_header_column_content
anchors {
horizontalCenter: undefined
verticalCenter: undefined
}
}
}
]
MouseArea {
id: mouse_header_column
anchors.fill: parent
hoverEnabled: true
drag.target: frozen ? null : parent
drag.axis: Drag.XAxis
onPressed :
(mouse)=>{
control.closeEditor()
list_table.interactive = false
}
onReleased:{
list_table.interactive = true
}
onCanceled: {
list_table.interactive = true
}
}
AutoLoader{
property var columnModel: model
anchors.fill: parent
sourceComponent: {
return control.columnHeaderProvider(model.dataIndex)
}
}
Rectangle{
id: divider_column
width: 0.5
height: parent.height
anchors.right: parent.right
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
Rectangle{
width: 0.5
height: parent.height
anchors.left: parent.left
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
Rectangle{
width: parent.width
height: 1
anchors.bottom: parent.bottom
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
MouseArea{
property point clickPos: "0,0"
width: 6
height: parent.height
cursorShape: Qt.SplitHCursor
anchors.right: parent.right
onPressed :
(mouse)=>{
list_table.interactive = false
Tools.setOverrideCursor(Qt.SplitHCursor)
clickPos = Qt.point(mouse.x, mouse.y)
}
onReleased:{
list_table.interactive = true
Tools.restoreOverrideCursor()
}
onCanceled: {
list_table.interactive = true
Tools.restoreOverrideCursor()
}
onPositionChanged:
(mouse)=>{
if(!pressed){
return
}
var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
var minimumWidth = model.minimumWidth
var maximumWidth = model.maximumWidth
if(!minimumWidth){
minimumWidth = control.horizonalHeaderHeight
}
if(!maximumWidth){
maximumWidth = 65535
}
var width = d.defaultWidth
if(model.width){
width = model.width
}
model.width = Math.min(Math.max(minimumWidth, width + delta.x),maximumWidth)
}
}
}
}
}
}
}
ScrollBar{
id: scrollbar_v
anchors{
right: control.right
top: parent.top
bottom: parent.bottom
topMargin: d.horizonalHeaderHeight
}
z: 999
}
ScrollBar{
id: scrollbar_h
anchors{
bottom: parent.bottom
left: parent.left
right: parent.right
leftMargin: list_table.leftMargin
}
z: 999
visible: {
if(control.columnSourceModel){
for(var i=0;i<control.columnSourceModel.count;i++){
var item = control.columnSourceModel.get(i)
if(!item.frozen){
return scrollbar_h.policy !== ScrollBar.AlwaysOff && scrollbar_h.size < 1.0
}
}
}
return false
}
}
function closeEditor(){
d.editPoint = null
}
}
