import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/**
* TreeView - 可展开折叠的树形视图组件
*
* 用法示例:
* TreeView {
*     width: 250
*     model: ListModel {
*         ListElement { text: "平面"; icon: FluentIcons.graph_Document; depth: 0; hasChildren: true; expanded: true }
*         ListElement { text: "1F"; icon: FluentIcons.graph_Page; depth: 1; parentId: "平面"; hasChildren: false }
*         ListElement { text: "2F"; icon: FluentIcons.graph_Page; depth: 1; parentId: "平面"; hasChildren: false }
*     }
* }
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
required property var model
property int rowHeight: Theme.compactControlHeight
property int indentWidth: 20
property int iconSize: 16
property int expandIconSize: 12
property int leftPadding: 8
property int rightPadding: 8
property int currentIndex: -1
property var currentItem: currentIndex >= 0 && model ? model.get(currentIndex) : null
property var levelBackgrounds: [
control.SmoothUI.theme.res.subtleFillColorTertiary,
control.SmoothUI.theme.res.subtleFillColorSecondary,
control.SmoothUI.theme.res.subtleFillColorTransparent
]
signal itemClicked(var item, int index)
signal itemDoubleClicked(var item, int index)
signal itemExpanded(var item, int index)
signal itemCollapsed(var item, int index)
QtObject {
id: d
function getBackgroundColor(depth, isHovered, isPressed, isSelected) {
if (isSelected) {
return Colors.withOpacity(control.accentColor.defaultBrushFor(control.SmoothUI.dark), 0.15)
}
if (isPressed) {
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if (isHovered) {
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
var bgIndex = Math.min(depth, control.levelBackgrounds.length - 1)
return control.levelBackgrounds[bgIndex]
}
function toggleExpand(index) {
if (index < 0 || index >= control.model.count) return
var item = control.model.get(index)
if (!item.hasChildren) return
var newExpanded = !item.expanded
control.model.setProperty(index, "expanded", newExpanded)
if (newExpanded) {
control.itemExpanded(item, index)
} else {
control.itemCollapsed(item, index)
}
}
function isItemVisible(index) {
if (index < 0 || index >= control.model.count) return false
var item = control.model.get(index)
if (item.depth === 0) return true
var parentId = item.parentId
for (var i = index - 1; i >= 0; i--) {
var potentialParent = control.model.get(i)
if (potentialParent.text === parentId || (potentialParent.id && potentialParent.id === parentId)) {
if (!potentialParent.expanded) return false
if (potentialParent.depth === 0) return true
parentId = potentialParent.parentId
}
}
return true
}
}
ListView {
id: listView
anchors.fill: parent
model: control.model
clip: true
boundsBehavior: ListView.StopAtBounds
currentIndex: control.currentIndex
highlightFollowsCurrentItem: false
ScrollBar.vertical: ScrollBar {
policy: ScrollBar.AsNeeded
}
delegate: Item {
id: delegateRoot
width: listView.width
height: d.isItemVisible(model.index) ? control.rowHeight : 0
visible: height > 0
clip: true
Behavior on height {
NumberAnimation {
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
property bool isHovered: mouseArea.containsMouse
property bool isPressed: mouseArea.pressed
property bool isSelected: listView.currentIndex === model.index
property int itemDepth: model.depth !== undefined ? model.depth : 0
property bool hasChildren: model.hasChildren !== undefined ? model.hasChildren : false
property bool isExpanded: model.expanded !== undefined ? model.expanded : false
Rectangle {
id: background
anchors.fill: parent
anchors.leftMargin: 2
anchors.rightMargin: 2
radius: control.SmoothUI.radius
color: d.getBackgroundColor(delegateRoot.itemDepth, delegateRoot.isHovered, delegateRoot.isPressed, delegateRoot.isSelected)
Behavior on color {
ColorAnimation {
duration: Theme.fastAnimationDuration
}
}
}
Rectangle {
visible: delegateRoot.isSelected
width: 3
height: parent.height * 0.5
anchors.left: parent.left
anchors.leftMargin: 4
anchors.verticalCenter: parent.verticalCenter
radius: 1.5
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
RowLayout {
anchors.fill: parent
anchors.leftMargin: control.leftPadding + (delegateRoot.itemDepth * control.indentWidth)
anchors.rightMargin: control.rightPadding
spacing: 6
Item {
implicitWidth: control.expandIconSize + 4
implicitHeight: control.expandIconSize + 4
Layout.alignment: Qt.AlignVCenter
visible: delegateRoot.hasChildren
Icon {
anchors.centerIn: parent
width: control.expandIconSize
height: control.expandIconSize
source: FluentIcons.graph_ChevronRight
color: control.SmoothUI.theme.res.textFillColorSecondary
rotation: delegateRoot.isExpanded ? 90 : 0
Behavior on rotation {
NumberAnimation {
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
MouseArea {
anchors.fill: parent
anchors.margins: -4
onClicked: {
d.toggleExpand(model.index)
}
}
}
Item {
implicitWidth: control.expandIconSize + 4
implicitHeight: 1
visible: !delegateRoot.hasChildren
}
Icon {
id: itemIcon
width: control.iconSize
height: control.iconSize
Layout.alignment: Qt.AlignVCenter
source: model.icon !== undefined ? model.icon : FluentIcons.graph_Document
color: delegateRoot.isSelected
? control.accentColor.defaultBrushFor(control.SmoothUI.dark)
: control.SmoothUI.theme.res.textFillColorPrimary
visible: model.icon !== undefined
}
Label {
id: itemLabel
Layout.fillWidth: true
Layout.alignment: Qt.AlignVCenter
text: model.text !== undefined ? model.text : ""
font: Typography.body
elide: Label.ElideRight
color: {
if (!control.enabled) {
return control.SmoothUI.theme.res.textFillColorDisabled
}
if (delegateRoot.isSelected) {
return control.SmoothUI.theme.res.textFillColorPrimary
}
if (delegateRoot.isPressed) {
return control.SmoothUI.theme.res.textFillColorSecondary
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
}
Label {
visible: model.badge !== undefined && model.badge !== ""
text: model.badge !== undefined ? model.badge : ""
font: Typography.caption
color: control.SmoothUI.theme.res.textFillColorTertiary
Layout.alignment: Qt.AlignVCenter
}
}
MouseArea {
id: mouseArea
anchors.fill: parent
hoverEnabled: true
acceptedButtons: Qt.LeftButton | Qt.RightButton
onClicked: (mouse) => {
if (mouse.button === Qt.LeftButton) {
control.currentIndex = model.index
control.itemClicked(model, model.index)
}
}
onDoubleClicked: (mouse) => {
if (mouse.button === Qt.LeftButton) {
if (delegateRoot.hasChildren) {
d.toggleExpand(model.index)
}
control.itemDoubleClicked(model, model.index)
}
}
}
}
}
function expandAll() {
for (var i = 0; i < model.count; i++) {
var item = model.get(i)
if (item.hasChildren) {
model.setProperty(i, "expanded", true)
}
}
}
function collapseAll() {
for (var i = 0; i < model.count; i++) {
var item = model.get(i)
if (item.hasChildren) {
model.setProperty(i, "expanded", false)
}
}
}
function expandItem(index) {
if (index >= 0 && index < model.count) {
var item = model.get(index)
if (item.hasChildren && !item.expanded) {
model.setProperty(index, "expanded", true)
itemExpanded(item, index)
}
}
}
function collapseItem(index) {
if (index >= 0 && index < model.count) {
var item = model.get(index)
if (item.hasChildren && item.expanded) {
model.setProperty(index, "expanded", false)
itemCollapsed(item, index)
}
}
}
}
