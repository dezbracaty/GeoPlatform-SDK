import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype TagInputBox
\inqmlmodule SmoothUI.Controls
\brief Text input with tag/chip display for entering multiple items
*/
T.Control {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property bool pressed: tap_handler.pressed
property var tags: []
property int maximumTags: 0
property bool readOnly: false
//! \value TagInputBoxType.Collapse Tags scroll horizontally
//! \value TagInputBoxType.ExpandHeight Tags wrap to multiple rows
property int layoutMode: TagInputBoxType.Collapse
//! \value TagInputBoxType.Rounded Rounded corners
property int tagShape: TagInputBoxType.Rounded
property string placeholderText: qsTr("Add a tag")
property bool showCount: true
property string trailingIcon: FluentIcons.graph_Tag
property Component leading
property Component trailing: trailing_default
signal tagAdded(var tag)
signal tagRemoved(var tag, int index)
signal tagClicked(var tag, int index)
TapHandler {
id: tap_handler
onTapped: (event) => {
control.__activeInput.forceActiveFocus()
}
}
HoverHandler {
cursorShape: Qt.IBeamCursor
}
QtObject {
id: d
property var model: []
property string inputText: ""
function initModel() {
var newModel = []
for (var i = 0; i < control.tags.length; i++) {
var t = control.tags[i]
newModel.push(typeof t === 'string' ? {text: t} : t)
}
model = newModel
}
function addTag(text) {
if (!text || text.trim() === "") return false
if (control.maximumTags > 0 && model.length >= control.maximumTags) return false
var tag = {text: text.trim()}
var newModel = model.slice()
newModel.push(tag)
model = newModel
control.tagAdded(tag)
return true
}
function removeTag(index) {
if (index < 0 || index >= model.length) return
var tag = model[index]
var newModel = model.slice()
newModel.splice(index, 1)
model = newModel
control.tagRemoved(tag, index)
}
function isInputVisible() {
if (control.readOnly || !control.enabled) return false
if (control.maximumTags > 0 && model.length >= control.maximumTags) return false
return true
}
}
onTagsChanged: d.initModel()
Component.onCompleted: d.initModel()
implicitWidth: {
if (control.layoutMode === TagInputBoxType.ExpandWidth) {
var leadMargin = (control.leading && loader_leading.width > 0) ? loader_leading.width + 14 : 0
var trailMargin = loader_trailing.width > 0 ? loader_trailing.width + 14 : 0
return Math.max(340, row_tag.implicitWidth + leftPadding + rightPadding + leadMargin + trailMargin)
}
return 340
}
implicitHeight: {
var base = topPadding + bottomPadding
if (control.layoutMode === TagInputBoxType.ExpandHeight)
return Math.max(container_flow.implicitHeight + base, rowHeight + base)
return rowHeight + base
}
readonly property real rowHeight: Theme.controlHeight
padding: 0
topPadding: 0
bottomPadding: 0
leftPadding: Theme.controlHorizontalPadding
rightPadding: Theme.controlHorizontalPadding
font: Typography.body
property Item __activeInput: control.layoutMode === TagInputBoxType.ExpandHeight ? ti_input : ti_input_row
background: InputBackground {
implicitWidth: 340
implicitHeight: Theme.controlHeight
radius: control.SmoothUI.radius
activeColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
color: {
var field = control.__activeInput
if (!field.enabled)
return control.SmoothUI.theme.res.controlFillColorDisabled
if (field.activeFocus)
return control.SmoothUI.theme.res.controlFillColorInputActive
if (field.hovered)
return control.SmoothUI.theme.res.controlFillColorSecondary
return control.SmoothUI.theme.res.controlFillColorDefault
}
target: control.__activeInput
}
Component {
id: comp_chip
Chip {
id: chip
required property int index
required property var modelData
text: modelData.text || ""
highlighted: !!modelData.color
SmoothUI.primaryColor: modelData.color
SmoothUI.radius: control.tagShape === TagInputBoxType.Pill ? height/2 : control.SmoothUI.radius
width: control.layoutMode === TagInputBoxType.ExpandHeight ? Math.min(implicitWidth, layout_flow.width) : implicitWidth
onClicked: control.tagClicked(modelData, index)
onCloseClicked: d.removeTag(index)
}
}
contentItem: Item {
id: area_content
clip: control.layoutMode !== TagInputBoxType.ExpandHeight
implicitWidth: container_flow.implicitWidth
Item {
id: container_flow
implicitWidth: {
if (control.layoutMode === TagInputBoxType.ExpandHeight)
return layout_flow.implicitWidth
return row_tag.implicitWidth
}
implicitHeight: {
if (control.layoutMode === TagInputBoxType.ExpandHeight)
return layout_flow.implicitHeight
return row_tag.implicitHeight
}
anchors {
left: parent.left
leftMargin: loader_leading.width + (control.leading ? 14 : 0)
top: parent.top
right: parent.right
rightMargin: loader_trailing.width + (control.trailing ? 14 : 0)
bottom: parent.bottom
}
Flow {
id: layout_flow
visible: control.layoutMode === TagInputBoxType.ExpandHeight
width: parent.width
spacing: 6
bottomPadding: 6
topPadding: 6
padding: 0
Repeater {
model: d.model
delegate: comp_chip
}
T.TextField {
id: ti_input
visible: d.isInputVisible()
height: 24
implicitWidth: d.model.length === 0 ? layout_flow.width : Math.max(60, contentWidth + 10)
verticalAlignment: TextInput.AlignVCenter
font: Typography.body
color: {
if (!control.enabled)
return control.SmoothUI.theme.res.textFillColorDisabled
return control.SmoothUI.theme.res.textFillColorPrimary
}
selectionColor: accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
renderType: Theme.textRender
placeholderText: d.model.length === 0 ? control.placeholderText : ""
placeholderTextColor: control.SmoothUI.theme.res.textFillColorSecondary
background: Item {}
leftPadding: 0
rightPadding: 0
topPadding: 0
bottomPadding: 0
readOnly: d.model.length >= control.maximumTags
text: d.inputText
onTextChanged: d.inputText = text
onAccepted: {
if (d.addTag(text)) {
d.inputText = ""
}
}
Keys.onPressed: (event) => {
if (event.key === Qt.Key_Backspace && text.length === 0 && d.model.length > 0) {
d.removeTag(d.model.length - 1)
event.accepted = true
}
}
PlaceholderText {
x: ti_input.leftPadding
y: ti_input.topPadding
width: ti_input.width - (ti_input.leftPadding + ti_input.rightPadding)
height: ti_input.height - (ti_input.topPadding + ti_input.bottomPadding)
text: ti_input.placeholderText
font: ti_input.font
color: ti_input.placeholderTextColor
verticalAlignment: ti_input.verticalAlignment
visible: !ti_input.length && !ti_input.preeditText && (!ti_input.activeFocus || ti_input.horizontalAlignment !== Qt.AlignHCenter)
elide: Text.ElideRight
renderType: ti_input.renderType
}
TapHandler {
acceptedButtons: Qt.RightButton
acceptedDevices: PointerDevice.Mouse
onTapped: function(eventPoint) {
eventPoint.accepted = true
control.__showMenu(ti_input)
}
}
TapHandler {
acceptedDevices: PointerDevice.TouchScreen
onLongPressed: control.__showMenu(ti_input)
}
}
}
Flickable {
id: flickable_row
visible: control.layoutMode !== TagInputBoxType.ExpandHeight
anchors.fill: parent
contentWidth: row_tag.implicitWidth
clip: control.layoutMode !== TagInputBoxType.ExpandHeight
interactive: control.layoutMode === TagInputBoxType.Collapse
boundsBehavior: Flickable.StopAtBounds
ScrollBar.horizontal: ScrollBar {
policy: control.layoutMode === TagInputBoxType.Collapse ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
}
Row {
id: row_tag
spacing: 6
anchors.verticalCenter: parent.verticalCenter
Repeater {
model: d.model
delegate: comp_chip
anchors.verticalCenter: parent.verticalCenter
}
T.TextField {
id: ti_input_row
visible: d.isInputVisible()
height: 24
implicitWidth: d.model.length === 0 ? flickable_row.width : Math.max(60, contentWidth + 10)
verticalAlignment: TextInput.AlignVCenter
anchors.verticalCenter: parent.verticalCenter
font: Typography.body
color: {
if (!control.enabled)
return control.SmoothUI.theme.res.textFillColorDisabled
return control.SmoothUI.theme.res.textFillColorPrimary
}
selectionColor: accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
renderType: Theme.textRender
placeholderText: d.model.length === 0 ? control.placeholderText : ""
placeholderTextColor: control.SmoothUI.theme.res.textFillColorSecondary
background: Item {}
leftPadding: 0
rightPadding: 0
topPadding: 0
bottomPadding: 0
text: d.inputText
onTextChanged: d.inputText = text
onAccepted: {
if (d.addTag(text)) {
d.inputText = ""
}
}
Keys.onPressed: (event) => {
if (event.key === Qt.Key_Backspace && text.length === 0 && d.model.length > 0) {
d.removeTag(d.model.length - 1)
event.accepted = true
}
}
onCursorRectangleChanged: {
if (control.layoutMode !== TagInputBoxType.Collapse)
return
var cursorRight = ti_input_row.x + cursorRectangle.x + cursorRectangle.width
var viewLeft = flickable_row.contentX
var viewRight = viewLeft + flickable_row.width
if (cursorRight > viewRight + 4)
flickable_row.contentX = cursorRight - flickable_row.width + 8
else if (cursorRight < viewLeft)
flickable_row.contentX = cursorRight - 8
}
PlaceholderText {
x: ti_input_row.leftPadding
y: ti_input_row.topPadding
width: ti_input_row.width - (ti_input_row.leftPadding + ti_input_row.rightPadding)
height: ti_input_row.height - (ti_input_row.topPadding + ti_input_row.bottomPadding)
text: ti_input_row.placeholderText
font: ti_input_row.font
color: ti_input_row.placeholderTextColor
verticalAlignment: ti_input_row.verticalAlignment
visible: !ti_input_row.length && !ti_input_row.preeditText && (!ti_input_row.activeFocus || ti_input_row.horizontalAlignment !== Qt.AlignHCenter)
elide: Text.ElideRight
renderType: ti_input_row.renderType
}
TapHandler {
acceptedButtons: Qt.RightButton
acceptedDevices: PointerDevice.Mouse
onTapped: function(eventPoint) {
eventPoint.accepted = true
control.__showMenu(ti_input_row)
}
}
TapHandler {
acceptedDevices: PointerDevice.TouchScreen
onLongPressed: control.__showMenu(ti_input_row)
}
}
}
}
}
}
property var __currentMenu
function __showMenu(editor) {
if(__currentMenu){
Tools.deleteLater(__currentMenu)
__currentMenu = undefined
}
if(!editor.activeFocus){
editor.forceActiveFocus()
editor.selectAll()
}
__currentMenu = input_menu.createObject(control,{editor: editor})
__currentMenu.popup()
}
Component {
id: input_menu
TextEditingContextMenu {
onClosed: {
Tools.deleteLater(this)
__currentMenu = undefined
}
}
}
AutoLoader {
id: loader_leading
sourceComponent: control.leading
anchors {
left: parent.left
top: parent.top
topMargin: 4
leftMargin: 4
}
}
AutoLoader {
id: loader_trailing
sourceComponent: control.trailing
anchors {
right: parent.right
rightMargin: 20
verticalCenter: parent.verticalCenter
}
}
Component {
id: trailing_default
Item {
height: 16
width: count_label.width + count_icon.width + 4
visible: control.showCount
Label {
id: count_label
text: {
if (control.maximumTags > 0)
return d.model.length + "/" + control.maximumTags
return d.model.length.toString()
}
font: Typography.caption
color: {
var res = control.SmoothUI.theme.res
if (!res) return "#797775"
if (!control.enabled) return res.textFillColorDisabled
return res.textFillColorSecondary
}
anchors.verticalCenter: parent.verticalCenter
renderType: Theme.textRender
}
Icon {
id: count_icon
source: control.trailingIcon
width: 12
height: 12
anchors {
left: count_label.right
leftMargin: 6
verticalCenter: parent.verticalCenter
}
color: count_label.color
}
}
}
}
