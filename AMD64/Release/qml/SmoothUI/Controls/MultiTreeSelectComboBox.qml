/*!
\qmltype MultiTreeSelectComboBox
\inqmlmodule SmoothUI.Controls
\brief A tree-based combo box for hierarchical multi-selection.
Extends the combo box pattern to support navigating and
selecting items from a hierarchical tree structure with
indentation and expand/collapse handling.
*/
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ComboBox {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property string placeholderText: qsTr("Please select")
property bool highlighted: false
property var treeData: []
valueRole: "value"
property string titleRole: "title"
property string childrenRole: "children"
property bool checkStrictly: false
property bool selectableInternal: true
property string itemEnabledRole: ""
property bool defaultExpandAll: false
property int indent: 20
property int popupHeight: 320
property var selectedValues: []
signal selectionChanged(var values)
signal nodeChecked(var value, bool checked)
signal nodeExpanded(var value)
signal nodeCollapsed(var value)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
font: Typography.body
editable: false
onTreeDataChanged: {
d.rebuildIndices()
d.applyExternalSelection()
d.rebuildFlatList()
}
onValueRoleChanged: {
d.rebuildIndices()
d.applyExternalSelection()
d.rebuildFlatList()
}
onTitleRoleChanged: {
d.rebuildFlatList()
}
onChildrenRoleChanged: {
d.rebuildIndices()
d.applyExternalSelection()
d.rebuildFlatList()
}
onSelectedValuesChanged: {
d.applyExternalSelection()
}
onCheckStrictlyChanged: {
d.applyExternalSelection()
}
onSelectableInternalChanged: {
d.applyExternalSelection()
}
onItemEnabledRoleChanged: {
d.rebuildFlatList()
}
Component.onCompleted: {
d.rebuildIndices()
d.applyExternalSelection()
d.rebuildFlatList()
}
ListModel {
id: flat_model
}
QtObject {
id: d
property var nodeIndex: ({})
property var parentIndex: ({})
property var childrenIndex: ({})
property var depthIndex: ({})
property var internalNodes: []
property var expandedSet: ({})
property var selectedSet: ({})
property var indeterminateSet: ({})
property int selectionRevision: 0
property bool syncingSelected: false
function getValue(node) {
return node[control.valueRole]
}
function getTitle(node) {
return node[control.titleRole]
}
function getChildren(node) {
const c = node[control.childrenRole]
return Array.isArray(c) ? c : []
}
function isLeaf(node) {
return d.getChildren(node).length === 0
}
function rebuildIndices() {
const nextNode = ({})
const nextParent = ({})
const nextChildren = ({})
const nextDepth = ({})
const nextInternals = []
const nextExpanded = ({})
const data = control.treeData || []
const stack = []
for (let i = data.length - 1; i >= 0; --i) {
stack.push({ node: data[i], parent: null, depth: 0 })
}
while (stack.length > 0) {
const top = stack.pop()
const node = top.node
if (!node) {
continue
}
const value = d.getValue(node)
nextNode[value] = node
nextParent[value] = top.parent
nextDepth[value] = top.depth
const children = d.getChildren(node)
const childValues = []
for (let j = 0; j < children.length; ++j) {
childValues.push(d.getValue(children[j]))
}
nextChildren[value] = childValues
if (children.length > 0) {
nextInternals.push(value)
if (control.defaultExpandAll || d.expandedSet[value]) {
nextExpanded[value] = true
}
}
for (let k = children.length - 1; k >= 0; --k) {
stack.push({ node: children[k], parent: value, depth: top.depth + 1 })
}
}
nextInternals.sort((a, b) => nextDepth[b] - nextDepth[a])
d.nodeIndex = nextNode
d.parentIndex = nextParent
d.childrenIndex = nextChildren
d.depthIndex = nextDepth
d.internalNodes = nextInternals
d.expandedSet = nextExpanded
}
function rebuildFlatList() {
flat_model.clear()
const data = control.treeData || []
const stack = []
for (let i = data.length - 1; i >= 0; --i) {
stack.push({ node: data[i], depth: 0 })
}
while (stack.length > 0) {
const top = stack.pop()
const node = top.node
if (!node) {
continue
}
const value = d.getValue(node)
const children = d.getChildren(node)
flat_model.append({
nodeValue: String(value),
nodeTitle: String(d.getTitle(node)),
depth: top.depth,
hasChildren: children.length > 0,
nodeEnabled: control.itemEnabledRole ? (node[control.itemEnabledRole] !== false) : true
})
if (children.length > 0 && d.expandedSet[value]) {
for (let k = children.length - 1; k >= 0; --k) {
stack.push({ node: children[k], depth: top.depth + 1 })
}
}
}
}
function applyExternalSelection() {
if (d.syncingSelected) {
return
}
if (Object.keys(d.nodeIndex).length === 0) {
return
}
const next = ({})
const values = control.selectedValues || []
for (var i = 0; i < values.length; ++i) {
const v = values[i]
if (d.nodeIndex[v] !== undefined) {
next[v] = true
}
}
if (!control.checkStrictly) {
const seeds = Object.keys(next)
for (let i = 0; i < seeds.length; ++i) {
const node = d.nodeIndex[seeds[i]]
if (node) {
d.fanOut(node, true, next)
}
}
}
d.selectedSet = next
if (!control.checkStrictly) {
d.recomputeAllAncestors()
} else {
d.indeterminateSet = ({})
}
d.syncSelectedValues()
d.bumpRevision()
}
function syncSelectedValues() {
d.syncingSelected = true
const out = []
for (const v in d.selectedSet) {
const node = d.nodeIndex[v]
if (!node) {
continue
}
if (control.selectableInternal || d.isLeaf(node)) {
out.push(v)
}
}
control.selectedValues = out
d.syncingSelected = false
}
function bumpRevision() {
d.selectionRevision = d.selectionRevision + 1
}
function isChecked(value) {
d.selectionRevision
return d.selectedSet[value] === true
}
function isIndeterminate(value) {
d.selectionRevision
return d.indeterminateSet[value] === true
}
function setChecked(value, checked) {
const node = d.nodeIndex[value]
if (!node) {
return
}
if (!d.isLeaf(node) && !control.selectableInternal) {
return
}
const next = Object.assign({}, d.selectedSet)
if (checked) {
next[value] = true
} else {
delete next[value]
}
if (!control.checkStrictly) {
d.fanOut(node, checked, next)
}
d.selectedSet = next
if (!control.checkStrictly) {
d.recomputeAllAncestors()
} else {
d.indeterminateSet = ({})
}
control.nodeChecked(value, checked)
d.syncSelectedValues()
d.bumpRevision()
control.selectionChanged(control.selectedValues)
}
function fanOut(node, checked, target) {
const stack = [node]
while (stack.length > 0) {
const cur = stack.pop()
const children = d.getChildren(cur)
for (let i = 0; i < children.length; ++i) {
const child = children[i]
const childValue = d.getValue(child)
if (checked) {
target[childValue] = true
} else {
delete target[childValue]
}
stack.push(child)
}
}
}
function recomputeAllAncestors() {
const indeterminate = ({})
const selected = Object.assign({}, d.selectedSet)
const internals = d.internalNodes
for (let i = 0; i < internals.length; ++i) {
const value = internals[i]
const childValues = d.childrenIndex[value] || []
if (childValues.length === 0) {
continue
}
let checkedCount = 0
let partialCount = 0
for (let j = 0; j < childValues.length; ++j) {
const cv = childValues[j]
if (selected[cv]) {
checkedCount++
} else if (indeterminate[cv]) {
partialCount++
}
}
if (checkedCount === childValues.length && partialCount === 0) {
selected[value] = true
delete indeterminate[value]
} else if (checkedCount === 0 && partialCount === 0) {
delete selected[value]
delete indeterminate[value]
} else {
delete selected[value]
indeterminate[value] = true
}
}
d.selectedSet = selected
d.indeterminateSet = indeterminate
}
function toggleExpand(value) {
const next = Object.assign({}, d.expandedSet)
if (next[value]) {
delete next[value]
d.expandedSet = next
d.rebuildFlatList()
control.nodeCollapsed(value)
} else {
next[value] = true
d.expandedSet = next
d.rebuildFlatList()
control.nodeExpanded(value)
}
}
function setExpandedAll(expanded) {
const next = ({})
if (expanded) {
for (let i = 0; i < d.internalNodes.length; ++i) {
next[d.internalNodes[i]] = true
}
}
d.expandedSet = next
d.rebuildFlatList()
}
function selectAllNodes() {
const next = ({})
for (const v in d.nodeIndex) {
next[v] = true
}
d.selectedSet = next
d.indeterminateSet = ({})
d.syncSelectedValues()
d.bumpRevision()
control.selectionChanged(control.selectedValues)
}
function clearAll() {
d.selectedSet = ({})
d.indeterminateSet = ({})
d.syncSelectedValues()
d.bumpRevision()
control.selectionChanged(control.selectedValues)
}
}
delegate: ListTile {
id: control_item
width: ListView.view.width
leftPadding: 6 + model.depth * control.indent
rightPadding: 6
spacing: 6
text: model.nodeTitle
font: control.font
hoverEnabled: control.hoverEnabled
highlighted: control.highlightedIndex === index
enabled: model.nodeEnabled !== undefined ? model.nodeEnabled : true
leading: Item {
implicitWidth: 48
implicitHeight: 28
Icon {
id: arrow_icon
width: 12
height: 12
anchors {
left: parent.left
leftMargin: 8
verticalCenter: parent.verticalCenter
}
source: FluentIcons.graph_ChevronDown
color: control.SmoothUI.theme.res.textFillColorSecondary
visible: model.hasChildren
rotation: d.expandedSet[model.nodeValue] ? 0 : -90
Behavior on rotation {
NumberAnimation {
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
MouseArea {
width: 24
height: 24
anchors.centerIn: arrow_icon
visible: model.hasChildren
cursorShape: Qt.PointingHandCursor
onClicked: (mouse)=>{
d.toggleExpand(model.nodeValue)
mouse.accepted = true
}
}
CheckBox {
padding: 0
anchors {
right: parent.right
verticalCenter: parent.verticalCenter
}
tristate: true
checkable: false
enabled: control_item.enabled
checkState: {
d.selectionRevision
if (d.indeterminateSet[model.nodeValue]) {
return Qt.PartiallyChecked
}
return d.selectedSet[model.nodeValue] ? Qt.Checked : Qt.Unchecked
}
onClicked: {
if (!enabled) return
const currentlyChecked = d.selectedSet[model.nodeValue] === true || d.indeterminateSet[model.nodeValue] === true
d.setChecked(model.nodeValue, !currentlyChecked)
}
}
}
background: FocusItem {
radius: control.SmoothUI.radius
implicitHeight: Theme.controlHeight
implicitWidth: 100
target: control_item
Rectangle {
radius: control.SmoothUI.radius
anchors {
fill: parent
leftMargin: 6
rightMargin: 6
topMargin: 2
bottomMargin: 2
}
color: {
d.selectionRevision
return d.selectedSet[model.nodeValue]
? control.SmoothUI.theme.res.subtleFillColorSecondary
: Theme.uncheckedInputColor(control_item, true, true, control.SmoothUI.dark)
}
}
}
onClicked: {
const currentlyChecked = d.selectedSet[model.nodeValue] === true || d.indeterminateSet[model.nodeValue] === true
d.setChecked(model.nodeValue, !currentlyChecked)
}
}
indicator: Item {
x: control.mirrored ? control.padding : control.width - width - control.padding
y: (control.topPadding + (control.availableHeight - height) / 2) + (control.pressed ? 1 : 0)
width: 35
height: 35
Behavior on y {
NumberAnimation {
easing.type: Theme.animationCurve
duration: Theme.fastAnimationDuration
}
}
Icon {
width: 12
height: 12
anchors.centerIn: parent
source: FluentIcons.graph_ChevronDown
color: control.enabled ? control.SmoothUI.theme.res.textFillColorSecondary : control.SmoothUI.theme.res.textFillColorDisabled
}
}
contentItem: T.TextField {
z: 999
leftPadding: Theme.controlHorizontalPadding
autoScroll: false
enabled: false
readOnly: control.down
inputMethodHints: control.inputMethodHints
validator: control.validator
selectByMouse: false
color: control.enabled ? control.SmoothUI.theme.res.textFillColorPrimary : control.SmoothUI.theme.res.textFillColorDisabled
placeholderText: list_view_chip.count === 0 ? control.placeholderText : ""
placeholderTextColor: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.body
renderType: Theme.textRender
selectionColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
verticalAlignment: Text.AlignVCenter
PlaceholderText {
id: placeholder
x: parent.leftPadding
y: parent.topPadding
width: parent.width - (parent.leftPadding + parent.rightPadding)
height: parent.height - (parent.topPadding + parent.bottomPadding)
text: parent.placeholderText
font: parent.font
color: parent.placeholderTextColor
verticalAlignment: parent.verticalAlignment
visible: !parent.length && !parent.preeditText && (!parent.activeFocus || parent.horizontalAlignment !== Qt.AlignHCenter)
elide: Text.ElideRight
renderType: parent.renderType
}
}
background: Item {
implicitWidth: 180
implicitHeight: Theme.controlHeight
ControlBackground {
anchors.fill: parent
target: control
radius: control.SmoothUI.radius
}
}
popup: T.Popup {
topMargin: 8
bottomMargin: 8
y: control.height
width: control.width
height: {
flat_model.count
return Math.min(contentItem && contentItem.implicitHeight ? contentItem.implicitHeight + topPadding + bottomPadding : 0,
control.popupHeight,
control.Window.height - topMargin - bottomMargin)
}
verticalPadding: 6
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
onVisibleChanged: {
if (visible && contentItem) {
contentItem.forceLayout()
}
}
enter: Transition {
NumberAnimation {
property: "height"
from: 0
to: control.popup.height
easing.type: Theme.animationCurve
duration: Theme.fastAnimationDuration
}
}
contentItem: ListView {
clip: true
implicitHeight: Math.min(contentHeight, control.popupHeight)
highlightMoveDuration: 0
model: flat_model
delegate: control.delegate
currentIndex: control.highlightedIndex
boundsBehavior: ListView.StopAtBounds
reuseItems: true
ScrollBar.vertical: ScrollBar {
visible: !control.popup.enter.running && policy !== ScrollBar.AlwaysOff && size < 1.0
}
}
background: Rectangle {
radius: Theme.popupRadius
color: control.SmoothUI.theme.res.popupBackgroundColor
border {
width: 1
color: control.SmoothUI.theme.res.popupBorderColor
}
Shadow {
radius: Theme.popupRadius
}
}
}
Item {
anchors.fill: contentItem
ListView {
id: list_view_chip
width: Math.min(parent.width - 10, contentItem.childrenRect.width)
height: contentItem.childrenRect.height
clip: true
spacing: 5
orientation: ListView.Horizontal
boundsBehavior: ListView.StopAtBounds
anchors {
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 5
}
model: {
d.selectionRevision
return control.selectedValues
}
delegate: Chip {
text: {
const node = d.nodeIndex[modelData]
return node ? String(d.getTitle(node)) : String(modelData)
}
onCloseClicked: {
d.setChecked(modelData, false)
}
}
}
}
function clearSelection() {
d.clearAll()
}
function selectAll() {
d.selectAllNodes()
}
function expandAll() {
d.setExpandedAll(true)
}
function collapseAll() {
d.setExpandedAll(false)
}
function isChecked(value) {
return d.isChecked(value)
}
function isIndeterminate(value) {
return d.isIndeterminate(value)
}
}
