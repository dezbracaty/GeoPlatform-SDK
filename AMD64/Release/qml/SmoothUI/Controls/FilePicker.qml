pragma Singleton
import QtQuick
import QtQuick.Dialogs as Dialogs
QtObject {
id: control
readonly property bool busy: _activeRequest !== null
property bool useNativeDialogs: false
property int _nextRequestId: 0
property var _pendingRequests: []
property var _activeRequest: null
signal accepted(int requestId, var urls)
signal rejected(int requestId)
signal viewStateChanged(int requestId, var state)
function openFile(options) {
return enqueueRequest("openFile", options)
}
function openFiles(options) {
return enqueueRequest("openFiles", options)
}
function saveFile(options) {
return enqueueRequest("saveFile", options)
}
function openFolder(options) {
return enqueueRequest("openFolder", options)
}
function enqueueRequest(kind, options) {
var requestId = ++_nextRequestId
_pendingRequests.push({
requestId: requestId,
kind: kind,
options: options || {}
})
if (!busy) Qt.callLater(showNextRequest)
return requestId
}
function showNextRequest() {
if (busy || _pendingRequests.length === 0) return
_activeRequest = _pendingRequests.shift()
var options = _activeRequest.options
var useNativeDialog = options.useNativeDialog !== undefined
? options.useNativeDialog : control.useNativeDialogs
if (!useNativeDialog) {
browserDialog.configure(_activeRequest.kind, options)
browserDialog.open()
return
}
if (_activeRequest.kind === "openFolder") {
folderDialog.title = options.title || qsTr("Select Folder")
folderDialog.parentWindow = options.parentWindow || null
if (options.currentFolder !== undefined) {
folderDialog.currentFolder = options.currentFolder
}
folderDialog.open()
return
}
fileDialog.title = options.title || qsTr("Select File")
fileDialog.parentWindow = options.parentWindow || null
fileDialog.nameFilters = options.nameFilters || [qsTr("All Files (*)")]
if (options.currentFolder !== undefined) {
fileDialog.currentFolder = options.currentFolder
}
if (options.currentFile !== undefined) {
fileDialog.currentFile = options.currentFile
}
switch (_activeRequest.kind) {
case "openFiles":
fileDialog.fileMode = Dialogs.FileDialog.OpenFiles
break
case "saveFile":
fileDialog.fileMode = Dialogs.FileDialog.SaveFile
break
default:
fileDialog.fileMode = Dialogs.FileDialog.OpenFile
break
}
fileDialog.open()
}
function finishAccepted(urls, state) {
if (!busy) return
var requestId = _activeRequest.requestId
if (state) viewStateChanged(requestId, state)
_activeRequest = null
accepted(requestId, urls)
Qt.callLater(showNextRequest)
}
function finishRejected(state) {
if (!busy) return
var requestId = _activeRequest.requestId
if (state) viewStateChanged(requestId, state)
_activeRequest = null
rejected(requestId)
Qt.callLater(showNextRequest)
}
property Dialogs.FileDialog fileDialog: Dialogs.FileDialog {
modality: Qt.WindowModal
onAccepted: control.finishAccepted(selectedFiles, {currentFolder: currentFolder})
onRejected: control.finishRejected({currentFolder: currentFolder})
}
property Dialogs.FolderDialog folderDialog: Dialogs.FolderDialog {
modality: Qt.WindowModal
onAccepted: control.finishAccepted([selectedFolder], {currentFolder: currentFolder})
onRejected: control.finishRejected({currentFolder: currentFolder})
}
property FileBrowserDialog browserDialog: FileBrowserDialog {
onAccepted: function(urls) { control.finishAccepted(urls, viewState()) }
onRejected: control.finishRejected(viewState())
}
}
