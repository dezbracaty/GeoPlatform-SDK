import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.Controls
import SmoothUI.impl
/**
* QuickActionMenu - 带搜索功能的快速操作菜单
*
* 特点：
* 1. 支持多级菜单（hover 在右侧弹出子菜单）
* 2. 支持搜索（搜索时显示扁平化结果）
* 3. 数据源：TMenuGroup.items（TMenuItem 列表）
*/
Popup {
id: control
SmoothUI.theme: Theme.of(control)
property var menuItems: []
property bool searchEnabled: true
property string searchPlaceholder: qsTr("Search...")
property string searchText: ""
property int minItemsForSearch: 3
property bool autoFocusSearch: true
property string pendingInitialQuery: ""
property var displayModel: []
property var currentSubmenu: null
property int totalItemCount: countTotalItems(menuItems)
property bool showSearchBox: searchEnabled && totalItemCount >= minItemsForSearch
property bool isSearching: searchText.length > 0
property int searchResultCount: isSearching ? displayModel.length : 0
width: 280
implicitHeight: contentColumn.implicitHeight + topPadding + bottomPadding
padding: 4
topPadding: 6
bottomPadding: 6
modal: false
focus: true
closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
background: Rectangle {
radius: control.SmoothUI.radius
color: control.SmoothUI.theme.res.popupBackgroundColor
border.color: control.SmoothUI.theme.res.popupBorderColor
border.width: 1
Shadow {
radius: control.SmoothUI.radius
}
}
onAboutToShow: {
searchInput.text = pendingInitialQuery
searchInput.cursorPosition = searchInput.text.length
pendingInitialQuery = ""
updateDisplayModel()
}
onOpened: focusSearchInput()
onClosed: {
pendingInitialQuery = ""
searchText = ""
searchInput.text = ""
closeSubmenu()
}
onSearchTextChanged: {
closeSubmenu()
updateDisplayModel()
}
onMenuItemsChanged: {
updateDisplayModel()
}
function focusSearchInput() {
Qt.callLater(function() {
if (!control.visible) return
if (autoFocusSearch && showSearchBox) {
searchInput.forceActiveFocus()
searchInput.cursorPosition = searchInput.text.length
} else {
contentColumn.forceActiveFocus()
}
})
}
function restoreKeyboardFocus() {
focusSearchInput()
}
function openWithQuery(query) {
var queryText = showSearchBox && query ? String(query) : ""
// 此时追加后续字符，防止快速连续输入丢字。
if (visible) {
if (queryText.length > 0) {
searchInput.text += queryText
searchInput.cursorPosition = searchInput.text.length
}
focusSearchInput()
return
}
pendingInitialQuery = queryText
open()
focusSearchInput()
}
function toArray(items) {
if (!items) return []
if (Array.isArray(items)) return items
if (typeof items.length === 'number') {
var arr = []
for (var i = 0; i < items.length; i++) {
arr.push(items[i])
}
return arr
}
return []
}
function countTotalItems(items) {
var arr = toArray(items)
if (arr.length === 0) return 0
var count = 0
for (var i = 0; i < arr.length; i++) {
if (!arr[i].separator) {
count++
if (arr[i].isMenu && arr[i].items) {
count += countTotalItems(arr[i].items)
}
}
}
return count
}
function updateDisplayModel() {
if (isSearching) {
displayModel = flattenAndFilter(menuItems, searchText)
} else {
displayModel = buildFlatList(menuItems)
}
selectFirstItem()
}
function isSelectableIndex(index) {
if (index < 0 || index >= displayModel.length) return false
var entry = displayModel[index]
var item = entry ? entry.item : null
return item && item.separator !== true && item.enabled !== false
}
function selectFirstItem() {
menuListView.currentIndex = -1
for (var i = 0; i < displayModel.length; i++) {
if (isSelectableIndex(i)) {
menuListView.currentIndex = i
menuListView.positionViewAtIndex(i, ListView.Contain)
return
}
}
}
function moveSelection(direction) {
var count = displayModel.length
if (count === 0) {
menuListView.currentIndex = -1
return
}
var start = menuListView.currentIndex
if (start < 0 || start >= count) {
start = direction > 0 ? -1 : 0
}
for (var offset = 1; offset <= count; offset++) {
var index = (start + direction * offset) % count
if (index < 0) index += count
if (isSelectableIndex(index)) {
closeSubmenu()
menuListView.currentIndex = index
menuListView.positionViewAtIndex(index, ListView.Contain)
return
}
}
}
function activateCurrentItem() {
var index = menuListView.currentIndex
if (!isSelectableIndex(index)) return
var item = displayModel[index].item
if (item.isMenu && !isSearching) {
var delegateItem = menuListView.itemAtIndex(index)
if (delegateItem) openSubmenu(item, delegateItem, true)
} else {
triggerItem(item)
}
}
function buildFlatList(items) {
var arr = toArray(items)
var result = []
for (var i = 0; i < arr.length; i++) {
result.push({
item: arr[i],
parentPath: "",
isSearchResult: false
})
}
return result
}
function flattenAndFilter(items, query) {
var arr = toArray(items)
if (arr.length === 0) return []
if (!query || query.trim() === "") return buildFlatList(items)
var lowerQuery = query.toLowerCase().trim()
var result = []
function processItems(itemList, parentPath) {
var list = toArray(itemList)
for (var i = 0; i < list.length; i++) {
var item = list[i]
if (item.separator) continue
var itemText = item.text || ""
var itemActionCode = item.actionCode || ""
var textMatch = itemText.toLowerCase().indexOf(lowerQuery) !== -1
var actionMatch = itemActionCode.toLowerCase().indexOf(lowerQuery) !== -1
if (item.isMenu && item.items) {
var newPath = parentPath ? (parentPath + " › " + itemText) : itemText
processItems(item.items, newPath)
} else if (textMatch || actionMatch) {
result.push({
item: item,
parentPath: parentPath || "",
isSearchResult: true
})
}
}
}
processItems(items, "")
return result
}
function closeSubmenu() {
if (currentSubmenu) {
currentSubmenu.close()
currentSubmenu.destroy()
currentSubmenu = null
}
}
function openSubmenu(menuItem, delegateItem, takeKeyboardFocus) {
if (!menuItem || !menuItem.items) return
closeSubmenu()
var component = submenuComponent
if (component.status === Component.Ready) {
currentSubmenu = component.createObject(control, {
menuItems: menuItem.items,
parentMenu: control,
ownerMenu: control,
takeKeyboardFocus: takeKeyboardFocus === true
})
if (currentSubmenu) {
var globalPos = delegateItem.mapToGlobal(delegateItem.width - 3, 0)
var popupPos = control.parent.mapFromGlobal(globalPos.x, globalPos.y)
currentSubmenu.x = popupPos.x
currentSubmenu.y = popupPos.y
currentSubmenu.open()
}
}
}
function triggerItem(item) {
if (item && !item.isMenu && item.enabled !== false) {
control.close()
item.onTriggered()
}
}
Component {
id: submenuComponent
QuickActionSubmenu {}
}
contentItem: Column {
id: contentColumn
width: parent.width
spacing: 0
focus: !control.showSearchBox
Keys.onUpPressed: control.moveSelection(-1)
Keys.onDownPressed: control.moveSelection(1)
Keys.onReturnPressed: control.activateCurrentItem()
Keys.onEnterPressed: control.activateCurrentItem()
Keys.onEscapePressed: control.close()
Item {
id: searchContainer
width: parent.width
height: control.showSearchBox ? 44 : 0
visible: control.showSearchBox
clip: true
Column {
anchors.fill: parent
anchors.margins: 8
anchors.bottomMargin: 4
spacing: 4
Rectangle {
width: parent.width
height: 32
radius: Theme.controlRadius
color: searchInput.activeFocus ?
control.SmoothUI.theme.res.controlFillColorInputActive :
(searchBoxMouseArea.containsMouse ?
control.SmoothUI.theme.res.controlFillColorSecondary :
control.SmoothUI.theme.res.controlFillColorDefault)
border.width: searchInput.activeFocus ? 2 : 1
border.color: searchInput.activeFocus ?
control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark) :
control.SmoothUI.theme.res.controlStrokeColorDefault
MouseArea {
id: searchBoxMouseArea
anchors.fill: parent
hoverEnabled: true
onClicked: searchInput.forceActiveFocus()
}
RowLayout {
anchors.fill: parent
anchors.leftMargin: 10
anchors.rightMargin: 6
spacing: 6
Icon {
source: FluentIcons.graph_Search
width: 14
height: 14
color: searchInput.activeFocus ?
control.SmoothUI.theme.res.textFillColorPrimary :
control.SmoothUI.theme.res.textFillColorSecondary
Layout.alignment: Qt.AlignVCenter
}
TextInput {
id: searchInput
Layout.fillWidth: true
Layout.alignment: Qt.AlignVCenter
font: Typography.body
color: control.SmoothUI.theme.res.textFillColorPrimary
selectionColor: control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
selectByMouse: true
clip: true
Text {
anchors.fill: parent
text: control.searchPlaceholder
font: parent.font
color: control.SmoothUI.theme.res.textFillColorSecondary
visible: !parent.text && !parent.activeFocus
verticalAlignment: Text.AlignVCenter
}
onTextChanged: control.searchText = text
Keys.onEscapePressed: {
if (text.length > 0) {
text = ""
control.searchText = ""
} else {
control.close()
}
}
Keys.onDownPressed: {
control.moveSelection(1)
}
Keys.onUpPressed: {
control.moveSelection(-1)
}
Keys.onReturnPressed: {
control.activateCurrentItem()
}
Keys.onEnterPressed: control.activateCurrentItem()
}
IconButton {
Layout.preferredWidth: 22
Layout.preferredHeight: 22
Layout.alignment: Qt.AlignVCenter
visible: control.searchText.length > 0
icon.name: FluentIcons.graph_ChromeClose
icon.width: 10
icon.height: 10
radius: Theme.controlRadius
onClicked: {
searchInput.text = ""
control.searchText = ""
searchInput.forceActiveFocus()
}
}
}
}
}
}
Rectangle {
width: parent.width - 16
height: 1
anchors.horizontalCenter: parent.horizontalCenter
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
visible: control.showSearchBox && menuListView.count > 0
opacity: 0.6
}
Item {
width: parent.width
height: (control.isSearching && control.searchResultCount > 0) ? searchResultText.implicitHeight + 8 : 0
visible: height > 0
clip: true
Text {
id: searchResultText
width: parent.width - 16
anchors.centerIn: parent
text: qsTr("%1 results found").arg(control.searchResultCount)
font: Typography.caption
color: control.SmoothUI.theme.res.textFillColorTertiary
horizontalAlignment: Text.AlignLeft
leftPadding: 8
}
}
Item {
width: parent.width
height: control.isSearching && control.searchResultCount === 0 ? 80 : 0
visible: height > 0
clip: true
Column {
anchors.centerIn: parent
spacing: 8
Icon {
anchors.horizontalCenter: parent.horizontalCenter
source: FluentIcons.graph_SearchAndApps
width: 24
height: 24
color: control.SmoothUI.theme.res.textFillColorTertiary
}
Text {
anchors.horizontalCenter: parent.horizontalCenter
text: qsTr("No matching results")
font: Typography.body
color: control.SmoothUI.theme.res.textFillColorSecondary
}
Text {
anchors.horizontalCenter: parent.horizontalCenter
text: qsTr("Try different keywords")
font: Typography.caption
color: control.SmoothUI.theme.res.textFillColorTertiary
}
}
}
ListView {
id: menuListView
width: parent.width
height: Math.min(contentHeight, 400)
model: control.displayModel
clip: true
ScrollBar.vertical: ScrollBar {}
boundsBehavior: ListView.StopAtBounds
currentIndex: -1
keyNavigationEnabled: false
delegate: Item {
id: delegateItem
width: menuListView.width
height: isSeparator ? 9 : 40
required property var modelData
required property int index
property var itemData: modelData ? modelData.item : null
property bool isSeparator: itemData ? (itemData.separator === true) : false
property bool hasSubmenu: itemData ? (itemData.isMenu === true) : false
property string itemText: itemData ? (itemData.text || "") : ""
property var itemIcon: itemData && itemData.iconSource ? (FluentIcons[itemData.iconSource] || "") : ""
property bool itemEnabled: itemData ? (itemData.enabled !== false) : true
property string parentPath: modelData ? (modelData.parentPath || "") : ""
property bool isSearchResult: modelData ? (modelData.isSearchResult === true) : false
property bool isSelected: menuListView.currentIndex === index && !isSeparator
Rectangle {
visible: isSeparator
width: parent.width - 16
height: 1
anchors.centerIn: parent
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
opacity: 0.6
}
Rectangle {
id: itemBackground
visible: !isSeparator
anchors.fill: parent
anchors.margins: 3
radius: Theme.controlRadius
color: delegateItem.isSelected ?
control.SmoothUI.theme.res.subtleFillColorSecondary :
"transparent"
property color textColor: itemEnabled ?
control.SmoothUI.theme.res.textFillColorPrimary :
control.SmoothUI.theme.res.textFillColorDisabled
RowLayout {
anchors.fill: parent
anchors.leftMargin: 10
anchors.rightMargin: 10
spacing: 6
IconLabel {
Layout.fillWidth: true
Layout.alignment: Qt.AlignVCenter
spacing: 6
display: Button.TextBesideIcon
alignment: Qt.AlignLeft | Qt.AlignVCenter
icon.source: itemIcon
icon.width: 16
icon.height: 16
icon.color: itemBackground.textColor
text: itemText
font: Typography.body
color: itemBackground.textColor
iconFamily: FluentIcons.fontLoader.name
}
Text {
visible: isSearchResult && parentPath !== ""
text: parentPath
font: Typography.caption
color: control.SmoothUI.theme.res.textFillColorTertiary
elide: Text.ElideRight
Layout.alignment: Qt.AlignVCenter
}
Icon {
visible: hasSubmenu && !control.isSearching
source: FluentIcons.graph_ChevronRight
width: 16
height: 16
color: itemBackground.textColor
family: FluentIcons.fontLoader.name
Layout.alignment: Qt.AlignVCenter
}
}
MouseArea {
id: itemMouseArea
anchors.fill: parent
hoverEnabled: true
enabled: itemEnabled
cursorShape: itemEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
acceptedButtons: Qt.LeftButton
Timer {
id: hoverTimer
interval: 200
repeat: false
onTriggered: {
if (itemMouseArea.containsMouse && hasSubmenu && !control.isSearching && itemData) {
control.openSubmenu(itemData, delegateItem)
}
}
}
onContainsMouseChanged: {
if (containsMouse) {
menuListView.currentIndex = index
if (hasSubmenu && !control.isSearching) {
hoverTimer.start()
} else {
control.closeSubmenu()
}
} else {
hoverTimer.stop()
}
}
onClicked: {
if (hasSubmenu && !control.isSearching) {
control.openSubmenu(itemData, delegateItem, false)
} else if (itemData) {
control.triggerItem(itemData)
}
}
}
}
}
}
}
}
