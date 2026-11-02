import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC
import Qt.labs.folderlistmodel
import SmoothUI.Controls
import SmoothUI.impl
Window {
id: control
property string mode: "openFile"
property url currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
property url currentFile
property var nameFilters: [qsTr("All Files (*)")]
property int selectedFilterIndex: 0
property var selectedUrls: []
property string fileName: ""
property bool showHiddenFiles: false
property string searchText: ""
property int sortField: FolderListModel.Name
property bool sortReversed: false
property var navigationHistory: []
property int navigationIndex: -1
property bool closingByAction: false
readonly property bool canGoBack: navigationIndex > 0
readonly property bool canGoForward: navigationIndex >= 0
&& navigationIndex < navigationHistory.length - 1
readonly property bool canGoUp: String(folderModel.parentFolder).length > 0
&& String(folderModel.parentFolder) !== String(currentFolder)
readonly property bool canAccept: mode === "openFolder"
|| mode === "saveFile" && fileName.trim().length > 0
|| mode !== "saveFile" && selectedUrls.length > 0
readonly property var sortOptions: [
{ key: "name", label: qsTr("Name"), field: FolderListModel.Name },
{ key: "modified", label: qsTr("Date Modified"), field: FolderListModel.Time },
{ key: "size", label: qsTr("Size"), field: FolderListModel.Size },
{ key: "type", label: qsTr("Type"), field: FolderListModel.Type }
]
signal accepted(var urls)
signal rejected()
width: 860
height: 590
minimumWidth: 700
minimumHeight: 480
flags: Qt.Dialog | Qt.FramelessWindowHint
modality: Qt.WindowModal
color: Colors.transparent
title: qsTr("Select File")
visible: false
SmoothUI.theme: Theme.of(control)
SmoothUI.dark: Theme.dark
SmoothUI.primaryColor: Theme.primaryColor
function configure(requestMode, options) {
var requestOptions = options || {}
mode = requestMode
title = requestOptions.title || defaultTitle()
nameFilters = requestOptions.nameFilters && requestOptions.nameFilters.length > 0
? requestOptions.nameFilters : [qsTr("All Files (*)")]
selectedFilterIndex = 0
selectedUrls = []
fileName = ""
searchText = ""
if (requestOptions.sortKey !== undefined) {
sortField = FolderListModel.Name
for (var i = 0; i < sortOptions.length; ++i) {
if (sortOptions[i].key === requestOptions.sortKey) {
sortField = sortOptions[i].field
break
}
}
}
if (requestOptions.sortReversed !== undefined)
sortReversed = requestOptions.sortReversed
sortCombo.currentIndex = sortOptionIndex(sortField)
currentFile = requestOptions.currentFile || ""
transientParent = requestOptions.parentWindow || null
var initialFolder = requestOptions.currentFolder
|| parentFolderFromFile(currentFile)
|| currentFolder
|| StandardPaths.writableLocation(StandardPaths.HomeLocation)
resetNavigation(initialFolder)
if (currentFile && String(currentFile).length > 0) {
fileName = fileNameFromUrl(currentFile)
if (mode !== "openFolder") selectedUrls = [currentFile]
}
if (mode === "openFolder") {
selectedUrls = [currentFolder]
}
}
function viewState() {
return {currentFolder: currentFolder,
sortKey: sortOptions[sortOptionIndex(sortField)].key,
sortReversed: sortReversed}
}
function defaultTitle() {
switch (mode) {
case "openFiles": return qsTr("Select Multiple Files")
case "saveFile": return qsTr("Save File")
case "openFolder": return qsTr("Select Folder")
default: return qsTr("Select File")
}
}
function open() {
closingByAction = false
if (transientParent) {
x = transientParent.x + Math.max(0, (transientParent.width - width) / 2)
y = transientParent.y + Math.max(0, (transientParent.height - height) / 2)
}
show()
raise()
requestActivate()
Qt.callLater(function() { fileList.forceActiveFocus() })
}
function rejectSelection() {
if (!visible || closingByAction) return
closingByAction = true
hide()
rejected()
}
function acceptSelection() {
if (!visible || closingByAction || !canAccept) return
var urls
if (mode === "saveFile") {
urls = [appendFileName(currentFolder, fileName.trim())]
} else if (mode === "openFolder") {
urls = selectedUrls.length > 0 ? selectedUrls.slice(0, 1) : [currentFolder]
} else {
urls = selectedUrls.slice()
}
closingByAction = true
hide()
accepted(urls)
}
function resetNavigation(folder) {
var target = folder && String(folder).length > 0
? folder : StandardPaths.writableLocation(StandardPaths.HomeLocation)
navigationHistory = [target]
navigationIndex = 0
currentFolder = target
selectedUrls = mode === "openFolder" ? [target] : []
}
function navigateTo(folder, addToHistory) {
if (!folder || String(folder).length === 0) return
var target = folder
if (addToHistory === undefined || addToHistory) {
var updated = navigationHistory.slice(0, navigationIndex + 1)
if (updated.length === 0 || String(updated[updated.length - 1]) !== String(target)) {
updated.push(target)
}
navigationHistory = updated
navigationIndex = updated.length - 1
}
currentFolder = target
selectedUrls = mode === "openFolder" ? [target] : []
fileList.currentIndex = -1
}
function goBack() {
if (!canGoBack) return
navigationIndex--
navigateTo(navigationHistory[navigationIndex], false)
}
function goForward() {
if (!canGoForward) return
navigationIndex++
navigateTo(navigationHistory[navigationIndex], false)
}
function goUp() {
if (canGoUp) navigateTo(folderModel.parentFolder, true)
}
function refreshFolder() {
folderModel.folder = ""
Qt.callLater(function() {
folderModel.folder = Qt.binding(function() { return control.currentFolder })
})
}
function selectEntry(url, isFolder, index, modifiers) {
fileList.currentIndex = index
if (isFolder) {
selectedUrls = mode === "openFolder" ? [url] : []
return
}
if (mode === "openFolder") return
if (mode === "saveFile") {
selectedUrls = [url]
fileName = fileNameFromUrl(url)
return
}
var multiple = mode === "openFiles"
var additive = multiple && (modifiers & (Qt.ControlModifier | Qt.MetaModifier))
if (!additive) {
selectedUrls = [url]
return
}
var values = selectedUrls.slice()
var target = String(url)
var existingIndex = -1
for (var i = 0; i < values.length; ++i) {
if (String(values[i]) === target) {
existingIndex = i
break
}
}
if (existingIndex >= 0) values.splice(existingIndex, 1)
else values.push(url)
selectedUrls = values
}
function activateEntry(url, isFolder, index) {
if (isFolder) {
navigateTo(url, true)
return
}
selectEntry(url, false, index, Qt.NoModifier)
if (mode !== "openFiles") acceptSelection()
}
function activateCurrentEntry() {
if (fileList.currentIndex < 0) return
var index = fileList.currentIndex
activateEntry(folderModel.get(index, "fileUrl"), folderModel.isFolder(index), index)
}
function isSelected(url) {
var target = String(url)
for (var i = 0; i < selectedUrls.length; ++i) {
if (String(selectedUrls[i]) === target) return true
}
return false
}
function fileNameFromUrl(url) {
var value = decodeURIComponent(String(url))
while (value.endsWith("/")) value = value.substring(0, value.length - 1)
var slash = Math.max(value.lastIndexOf("/"), value.lastIndexOf("\\"))
return slash >= 0 ? value.substring(slash + 1) : value
}
function parentFolderFromFile(url) {
var value = String(url || "")
if (!value) return ""
while (value.length > 1 && value.endsWith("/")) {
value = value.substring(0, value.length - 1)
}
var slash = Math.max(value.lastIndexOf("/"), value.lastIndexOf("\\"))
if (slash < 0) return ""
if (slash === 0) return "/"
var keepRootSlash = value.startsWith("file:///") && slash === 7
|| /^file:\/\/\/[A-Za-z]:\//.test(value) && slash === 10
|| /^[A-Za-z]:\//.test(value) && slash === 2
return value.substring(0, slash + (keepRootSlash ? 1 : 0))
}
function appendFileName(folder, name) {
var base = String(folder)
if (!base.endsWith("/")) base += "/"
return base + encodeURIComponent(name)
}
function displayPath(url) {
var value = decodeURIComponent(String(url))
if (value.startsWith("file:///")) {
value = value.substring(Qt.platform.os === "windows" ? 8 : 7)
} else if (value.startsWith("file://")) {
value = value.substring(7)
}
return value || String(url)
}
function pathInputToUrl(path) {
var value = path.trim()
if (value.startsWith("file:")) return value
value = value.replace(/\\/g, "/")
if (/^[A-Za-z]:\//.test(value)) return "file:///" + value
if (value.startsWith("/")) return "file://" + value
return value
}
function globsForFilter(filter) {
var value = String(filter || "*")
var match = value.match(/\(([^)]*)\)\s*$/)
var globText = match && match.length > 1 ? match[1] : value
var values = globText.trim().split(/\s+/)
return values.length > 0 ? values : ["*"]
}
function activeGlobs() {
if (!nameFilters || nameFilters.length === 0) return ["*"]
var index = Math.max(0, Math.min(selectedFilterIndex, nameFilters.length - 1))
return globsForFilter(nameFilters[index])
}
function filteredGlobs() {
var globs = activeGlobs()
var term = searchText.trim().replace(/[\\\/:*?"<>|\[\]]/g, "")
if (term.length === 0) return globs
var filtered = []
for (var i = 0; i < globs.length; ++i) {
var glob = String(globs[i])
if (glob === "*" || glob === "*.*") {
filtered.push("*" + term + "*")
} else if (glob.startsWith("*.")) {
filtered.push("*" + term + glob.substring(1))
} else {
filtered.push("*" + term + "*")
}
}
return filtered
}
function sortOptionIndex(field) {
for (var i = 0; i < sortOptions.length; ++i) {
if (sortOptions[i].field === field) return i
}
return 0
}
function formatSize(bytes) {
if (bytes < 1024) return bytes + " B"
if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB"
return (bytes / (1024 * 1024 * 1024)).toFixed(1) + " GB"
}
function footerStatusText() {
if (mode === "openFolder") {
return displayPath(selectedUrls.length > 0
? selectedUrls[0] : currentFolder)
}
if (selectedUrls.length > 1) {
return qsTr("%1 files selected").arg(selectedUrls.length)
}
if (selectedUrls.length === 1) {
return fileNameFromUrl(selectedUrls[0])
}
if (searchText.trim().length > 0) {
return qsTr("%1 matches").arg(folderModel.count)
}
return qsTr("%1 items").arg(folderModel.count)
}
onCurrentFolderChanged: {
addressBox.text = displayPath(currentFolder)
}
onSearchTextChanged: {
if (mode !== "openFolder") selectedUrls = []
fileList.currentIndex = -1
}
onSortFieldChanged: {
fileList.currentIndex = -1
sortCombo.currentIndex = sortOptionIndex(sortField)
}
onSortReversedChanged: fileList.currentIndex = -1
onClosing: function(close) {
if (!closingByAction) {
closingByAction = true
rejected()
}
close.accepted = true
}
Shortcut {
sequence: "Escape"
context: Qt.WindowShortcut
enabled: control.visible && !sortCombo.popup.visible && !filterCombo.popup.visible
onActivated: control.rejectSelection()
}
FolderListModel {
id: folderModel
folder: control.currentFolder
nameFilters: control.filteredGlobs()
showDirs: control.mode === "openFolder" || control.searchText.trim().length === 0
showFiles: control.mode !== "openFolder"
showDirsFirst: true
showDotAndDotDot: false
showHidden: control.showHiddenFiles
showOnlyReadable: true
sortField: control.sortField
sortReversed: control.sortField === FolderListModel.Time || control.sortField === FolderListModel.Size
? !control.sortReversed : control.sortReversed
caseSensitive: false
sortCaseSensitive: false
}
Rectangle {
anchors.fill: parent
radius: Theme.dialogRadius
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
border.width: 1
border.color: control.SmoothUI.theme.res.surfaceStrokeColorDefault
ColumnLayout {
anchors.fill: parent
spacing: 0
Item {
Layout.fillWidth: true
Layout.preferredHeight: 44
MouseArea {
anchors.fill: parent
onPressed: control.startSystemMove()
}
RowLayout {
anchors.fill: parent
anchors.leftMargin: 16
anchors.rightMargin: 8
spacing: 8
Icon {
source: FluentIcons.graph_FolderOpen
color: control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark)
Layout.preferredWidth: 18
Layout.preferredHeight: 18
}
Text {
text: control.title
color: control.SmoothUI.theme.res.textFillColorPrimary
font: Typography.bodyStrong
elide: Text.ElideRight
Layout.fillWidth: true
}
IconButton {
icon.name: FluentIcons.graph_Cancel
icon.width: 12
icon.height: 12
implicitWidth: 34
implicitHeight: Theme.controlHeight
onClicked: control.rejectSelection()
}
}
}
Rectangle {
Layout.fillWidth: true
Layout.preferredHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
RowLayout {
Layout.fillWidth: true
Layout.leftMargin: 14
Layout.rightMargin: 14
Layout.topMargin: 10
Layout.bottomMargin: 10
spacing: 6
IconButton {
icon.name: FluentIcons.graph_ChevronLeft
icon.width: 12
icon.height: 12
enabled: control.canGoBack
onClicked: control.goBack()
}
IconButton {
icon.name: FluentIcons.graph_ChevronRight
icon.width: 12
icon.height: 12
enabled: control.canGoForward
onClicked: control.goForward()
}
IconButton {
icon.name: FluentIcons.graph_Up
icon.width: 13
icon.height: 13
enabled: control.canGoUp
onClicked: control.goUp()
}
IconButton {
icon.name: FluentIcons.graph_Refresh
icon.width: 13
icon.height: 13
onClicked: control.refreshFolder()
}
TextBox {
id: addressBox
Layout.fillWidth: true
Layout.minimumWidth: 100
placeholderText: qsTr("Enter folder path")
selectByMouse: true
onAccepted: control.navigateTo(control.pathInputToUrl(text), true)
}
TextBox {
id: searchBox
Layout.preferredWidth: 190
Layout.minimumWidth: 140
text: control.searchText
placeholderText: qsTr("Search this folder")
selectByMouse: true
leading: Icon {
source: FluentIcons.graph_Search
color: control.SmoothUI.theme.res.textFillColorSecondary
width: 14
height: 14
}
trailing: IconButton {
visible: searchBox.text.length > 0
icon.name: FluentIcons.graph_Cancel
icon.width: 10
icon.height: 10
implicitWidth: 22
implicitHeight: 22
onClicked: {
searchBox.clear()
control.searchText = ""
searchBox.forceActiveFocus()
}
}
onTextEdited: control.searchText = text
}
QQC.ComboBox {
id: sortCombo
Layout.preferredWidth: 132
Layout.minimumWidth: 110
model: control.sortOptions
textRole: "label"
// explicitly from sortField instead of installing a binding it removes.
currentIndex: 0
onActivated: control.sortField = control.sortOptions[currentIndex].field
}
IconButton {
icon.name: control.sortReversed
? FluentIcons.graph_ChevronDown
: FluentIcons.graph_ChevronUp
icon.width: 12
icon.height: 12
onClicked: control.sortReversed = !control.sortReversed
QQC.ToolTip.visible: hovered
QQC.ToolTip.text: control.sortReversed
? qsTr("Descending")
: qsTr("Ascending")
}
}
RowLayout {
Layout.fillWidth: true
Layout.fillHeight: true
Layout.leftMargin: 14
Layout.rightMargin: 14
spacing: 10
Rectangle {
Layout.preferredWidth: 154
Layout.fillHeight: true
radius: Theme.panelRadius
color: control.SmoothUI.theme.res.layerFillColorDefault
border.width: 1
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
ListView {
id: placesList
anchors.fill: parent
anchors.margins: 6
spacing: 2
clip: true
model: [
{ label: qsTr("Home"), icon: FluentIcons.graph_Home, url: StandardPaths.writableLocation(StandardPaths.HomeLocation) },
{ label: qsTr("Desktop"), icon: FluentIcons.graph_ThisPC, url: StandardPaths.writableLocation(StandardPaths.DesktopLocation) },
{ label: qsTr("Documents"), icon: FluentIcons.graph_Document, url: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) },
{ label: qsTr("Downloads"), icon: FluentIcons.graph_Download, url: StandardPaths.writableLocation(StandardPaths.DownloadLocation) }
]
delegate: Item {
id: placeDelegate
required property var modelData
width: placesList.width
height: 38
visible: String(modelData.url).length > 0
Rectangle {
anchors.fill: parent
radius: control.SmoothUI.radius
color: placeMouse.containsMouse
? control.SmoothUI.theme.res.subtleFillColorSecondary
: Colors.transparent
}
RowLayout {
anchors.fill: parent
anchors.leftMargin: 10
anchors.rightMargin: 8
spacing: 10
Icon {
source: placeDelegate.modelData.icon
color: control.SmoothUI.theme.res.textFillColorSecondary
Layout.preferredWidth: 16
Layout.preferredHeight: 16
}
Text {
text: placeDelegate.modelData.label
color: control.SmoothUI.theme.res.textFillColorPrimary
font: Typography.body
elide: Text.ElideRight
Layout.fillWidth: true
}
}
MouseArea {
id: placeMouse
anchors.fill: parent
hoverEnabled: true
onClicked: control.navigateTo(placeDelegate.modelData.url, true)
}
}
}
}
Rectangle {
Layout.fillWidth: true
Layout.fillHeight: true
radius: Theme.panelRadius
color: control.SmoothUI.theme.res.cardBackgroundFillColorDefault
border.width: 1
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
ColumnLayout {
anchors.fill: parent
spacing: 0
RowLayout {
Layout.fillWidth: true
Layout.preferredHeight: 34
Layout.leftMargin: 42
Layout.rightMargin: 14
spacing: 12
Text {
text: qsTr("Name")
color: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.caption
Layout.fillWidth: true
}
Text {
text: qsTr("Date Modified")
color: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.caption
Layout.preferredWidth: 128
}
Text {
text: qsTr("Size")
color: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.caption
horizontalAlignment: Text.AlignRight
Layout.preferredWidth: 72
}
}
Rectangle {
Layout.fillWidth: true
Layout.preferredHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
ListView {
id: fileList
Layout.fillWidth: true
Layout.fillHeight: true
clip: true
focus: true
currentIndex: -1
boundsBehavior: Flickable.StopAtBounds
model: folderModel
keyNavigationEnabled: true
Keys.onReturnPressed: control.activateCurrentEntry()
Keys.onEnterPressed: control.activateCurrentEntry()
QQC.ScrollBar.vertical: QQC.ScrollBar {
policy: QQC.ScrollBar.AsNeeded
}
delegate: Item {
id: fileDelegate
required property int index
required property string fileName
required property url fileUrl
required property double fileSize
required property date fileModified
required property bool fileIsDir
width: fileList.width
height: 40
readonly property bool selected: control.isSelected(fileUrl)
Rectangle {
anchors.fill: parent
anchors.leftMargin: 4
anchors.rightMargin: 4
radius: control.SmoothUI.radius
color: fileDelegate.selected
? Colors.withOpacity(control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark), 0.18)
: fileMouse.containsMouse
? control.SmoothUI.theme.res.subtleFillColorSecondary
: Colors.transparent
}
RowLayout {
anchors.fill: parent
anchors.leftMargin: 12
anchors.rightMargin: 14
spacing: 12
Icon {
source: fileDelegate.fileIsDir ? FluentIcons.graph_FolderFill : FluentIcons.graph_Document
color: fileDelegate.fileIsDir
? control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark)
: control.SmoothUI.theme.res.textFillColorSecondary
Layout.preferredWidth: 18
Layout.preferredHeight: 18
}
Text {
text: fileDelegate.fileName
color: control.SmoothUI.theme.res.textFillColorPrimary
font: Typography.body
elide: Text.ElideRight
Layout.fillWidth: true
}
Text {
text: Qt.formatDateTime(fileDelegate.fileModified, "yyyy-MM-dd  HH:mm")
color: control.SmoothUI.theme.res.textFillColorTertiary
font: Typography.caption
Layout.preferredWidth: 128
}
Text {
text: fileDelegate.fileIsDir ? "" : control.formatSize(fileDelegate.fileSize)
color: control.SmoothUI.theme.res.textFillColorTertiary
font: Typography.caption
horizontalAlignment: Text.AlignRight
Layout.preferredWidth: 72
}
}
MouseArea {
id: fileMouse
anchors.fill: parent
hoverEnabled: true
acceptedButtons: Qt.LeftButton
onClicked: function(mouse) {
control.selectEntry(fileDelegate.fileUrl, fileDelegate.fileIsDir,
fileDelegate.index, mouse.modifiers)
fileList.forceActiveFocus()
}
onDoubleClicked: control.activateEntry(fileDelegate.fileUrl,
fileDelegate.fileIsDir,
fileDelegate.index)
}
}
Text {
anchors.centerIn: parent
visible: folderModel.status === FolderListModel.Ready && folderModel.count === 0
text: control.searchText.trim().length > 0
? qsTr("No files match \"%1\"").arg(control.searchText.trim())
: qsTr("This folder is empty")
color: control.SmoothUI.theme.res.textFillColorTertiary
font: Typography.body
}
QQC.BusyIndicator {
anchors.centerIn: parent
running: folderModel.status === FolderListModel.Loading
visible: running
}
}
}
}
}
Rectangle {
Layout.fillWidth: true
Layout.preferredHeight: 1
Layout.topMargin: 12
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
ColumnLayout {
Layout.fillWidth: true
Layout.leftMargin: 14
Layout.rightMargin: 14
Layout.topMargin: 10
Layout.bottomMargin: 14
spacing: 8
RowLayout {
Layout.fillWidth: true
visible: control.mode === "saveFile"
spacing: 10
Text {
text: qsTr("File name")
color: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.body
}
TextBox {
text: control.fileName
Layout.fillWidth: true
selectByMouse: true
onTextEdited: control.fileName = text
onAccepted: control.acceptSelection()
}
}
RowLayout {
Layout.fillWidth: true
spacing: 10
Text {
text: control.footerStatusText()
color: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.caption
elide: Text.ElideMiddle
Layout.fillWidth: true
}
QQC.ComboBox {
id: filterCombo
model: control.nameFilters
currentIndex: control.selectedFilterIndex
visible: control.mode !== "openFolder" && control.nameFilters.length > 0
Layout.preferredWidth: 220
onActivated: control.selectedFilterIndex = currentIndex
}
StandardButton {
text: qsTr("Cancel")
implicitWidth: 88
onClicked: control.rejectSelection()
}
FilledButton {
text: control.mode === "saveFile" ? qsTr("Save")
: control.mode === "openFolder" ? qsTr("Select") : qsTr("Open")
enabled: control.canAccept
implicitWidth: 88
onClicked: control.acceptSelection()
}
}
}
}
}
}
