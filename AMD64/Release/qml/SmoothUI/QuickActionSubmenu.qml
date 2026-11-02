import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.Controls
import SmoothUI.impl
/**
* QuickActionSubmenu - 子菜单组件（递归支持多级）
*/
Popup {
id: submenu
SmoothUI.theme: Theme.of(submenu)
property var menuItems: []
property var parentMenu: null
property var ownerMenu: null
property var currentSubmenu: null
property bool takeKeyboardFocus: false
width: 240
implicitHeight: contentColumn.implicitHeight + topPadding + bottomPadding
padding: 4
topPadding: 6
bottomPadding: 6
modal: false
focus: takeKeyboardFocus
closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
background: Rectangle {
radius: submenu.SmoothUI.radius
color: submenu.SmoothUI.theme.res.popupBackgroundColor
border.color: submenu.SmoothUI.theme.res.popupBorderColor
border.width: 1
Shadow {
radius: submenu.SmoothUI.radius
}
}
onClosed: {
closeSubmenu()
}
onAboutToShow: selectFirstItem()
onOpened: {
if (takeKeyboardFocus) focusMenuList()
}
onMenuItemsChanged: selectFirstItem()
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
function closeSubmenu() {
if (currentSubmenu) {
currentSubmenu.close()
currentSubmenu.destroy()
currentSubmenu = null
}
}
function focusMenuList() {
Qt.callLater(function() {
if (submenu.visible) contentColumn.forceActiveFocus()
})
}
function restoreKeyboardFocus() {
focusMenuList()
}
function isSelectableIndex(index) {
var items = toArray(menuItems)
if (index < 0 || index >= items.length) return false
var item = items[index]
return item && item.separator !== true && item.enabled !== false
}
function selectFirstItem() {
var items = toArray(menuItems)
submenuListView.currentIndex = -1
for (var i = 0; i < items.length; i++) {
if (isSelectableIndex(i)) {
submenuListView.currentIndex = i
submenuListView.positionViewAtIndex(i, ListView.Contain)
return
}
}
}
function moveSelection(direction) {
var items = toArray(menuItems)
var count = items.length
if (count === 0) {
submenuListView.currentIndex = -1
return
}
var start = submenuListView.currentIndex
if (start < 0 || start >= count) {
start = direction > 0 ? -1 : 0
}
for (var offset = 1; offset <= count; offset++) {
var index = (start + direction * offset) % count
if (index < 0) index += count
if (isSelectableIndex(index)) {
closeSubmenu()
submenuListView.currentIndex = index
submenuListView.positionViewAtIndex(index, ListView.Contain)
return
}
}
}
function activateCurrentItem() {
var index = submenuListView.currentIndex
if (!isSelectableIndex(index)) return
var item = toArray(menuItems)[index]
if (item.isMenu) {
var delegateItem = submenuListView.itemAtIndex(index)
if (delegateItem) openSubmenu(item, delegateItem, true)
} else {
triggerItem(item)
}
}
function closeAndRestoreOwnerFocus() {
close()
if (ownerMenu && ownerMenu.restoreKeyboardFocus) {
ownerMenu.restoreKeyboardFocus()
}
}
property var _submenuComponent: null
function getSubmenuComponent() {
if (!_submenuComponent) {
_submenuComponent = Qt.createComponent("QuickActionSubmenu.qml")
}
return _submenuComponent
}
function openSubmenu(menuItem, delegateItem, takeFocus) {
if (!menuItem || !menuItem.items) return
closeSubmenu()
var component = getSubmenuComponent()
if (component.status === Component.Ready) {
currentSubmenu = component.createObject(submenu, {
menuItems: menuItem.items,
parentMenu: submenu.parentMenu || submenu,
ownerMenu: submenu,
takeKeyboardFocus: takeFocus === true
})
if (currentSubmenu) {
var globalPos = delegateItem.mapToGlobal(delegateItem.width - 3, 0)
var popupPos = submenu.parent.mapFromGlobal(globalPos.x, globalPos.y)
currentSubmenu.x = popupPos.x
currentSubmenu.y = popupPos.y
currentSubmenu.open()
}
} else if (component.status === Component.Error) {
console.error("QuickActionSubmenu: Failed to create submenu component:", component.errorString())
}
}
function triggerItem(item) {
if (item && !item.isMenu && item.enabled !== false) {
submenu.close()
if (parentMenu) {
parentMenu.close()
}
item.onTriggered()
}
}
contentItem: Column {
id: contentColumn
width: parent.width
spacing: 0
focus: submenu.takeKeyboardFocus
Keys.onUpPressed: submenu.moveSelection(-1)
Keys.onDownPressed: submenu.moveSelection(1)
Keys.onReturnPressed: submenu.activateCurrentItem()
Keys.onEnterPressed: submenu.activateCurrentItem()
Keys.onLeftPressed: submenu.closeAndRestoreOwnerFocus()
Keys.onEscapePressed: submenu.closeAndRestoreOwnerFocus()
ListView {
id: submenuListView
width: parent.width
height: Math.min(contentHeight, 400)
model: submenu.toArray(submenu.menuItems)
clip: true
ScrollBar.vertical: ScrollBar {}
boundsBehavior: ListView.StopAtBounds
currentIndex: -1
keyNavigationEnabled: false
delegate: Item {
id: delegateItem
width: submenuListView.width
height: isSeparator ? 9 : 40
required property var modelData
required property int index
property var itemData: modelData
property bool isSeparator: itemData ? (itemData.separator === true) : false
property bool hasSubmenu: itemData ? (itemData.isMenu === true) : false
property string itemText: itemData ? (itemData.text || "") : ""
property var itemIcon: itemData && itemData.iconSource ? (FluentIcons[itemData.iconSource] || "") : ""
property bool itemEnabled: itemData ? (itemData.enabled !== false) : true
property bool isSelected: submenuListView.currentIndex === index && !isSeparator
Rectangle {
visible: isSeparator
width: parent.width - 16
height: 1
anchors.centerIn: parent
color: submenu.SmoothUI.theme.res.dividerStrokeColorDefault
opacity: 0.6
}
Rectangle {
id: itemBackground
visible: !isSeparator
anchors.fill: parent
anchors.margins: 3
radius: Theme.controlRadius
color: delegateItem.isSelected ?
submenu.SmoothUI.theme.res.subtleFillColorSecondary :
"transparent"
property color textColor: itemEnabled ?
submenu.SmoothUI.theme.res.textFillColorPrimary :
submenu.SmoothUI.theme.res.textFillColorDisabled
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
Icon {
visible: hasSubmenu
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
if (itemMouseArea.containsMouse && hasSubmenu && itemData) {
submenu.openSubmenu(itemData, delegateItem)
}
}
}
onContainsMouseChanged: {
if (containsMouse) {
submenuListView.currentIndex = index
if (hasSubmenu) {
hoverTimer.start()
} else {
submenu.closeSubmenu()
}
} else {
hoverTimer.stop()
}
}
onClicked: {
if (hasSubmenu) {
submenu.openSubmenu(itemData, delegateItem, false)
} else if (itemData) {
submenu.triggerItem(itemData)
}
}
}
}
}
}
}
}
