import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.impl
/*!
\qmltype Tour
\inqmlmodule SmoothUI.Controls
\brief A guided tour/coachmark overlay for feature introduction
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property var steps: []
property int offset: 5
property int offsetX: 0
property int offsetY: 0
property int index: 0
property int radius: control.SmoothUI.radius
property Component indicator: com_indicator
property string finishText: qsTr("Finish")
property string nextText: qsTr("Next")
property string previousText: qsTr("Previous")
property color backgroundColor: control.SmoothUI.theme.res.cardBackgroundColor
property color maskColor: control.SmoothUI.dark ? Qt.rgba(0, 0, 0, 0.4) : Qt.rgba(0, 0, 0, 0.3)
property var popupItem: null
property Item popupParent: Overlay.overlay
property bool blockTargetInteraction: false
property bool keyboardNavigation: false
property bool busy: false
property string statusText: ""
readonly property var currentStep: index >= 0 && index < steps.length ? steps[index] : null
readonly property rect targetRect: _targetRect
readonly property rect highlightRect: popupItem ? popupItem.highlightRect : Qt.rect(0, 0, 0, 0)
readonly property rect cardRect: popupItem ? popupItem.cardRect : Qt.rect(0, 0, 0, 0)
readonly property bool targetValid: targetRect.width > 0 && targetRect.height > 0
property rect _targetRect: Qt.rect(0, 0, 0, 0)
readonly property string lastCloseReason: _lastCloseReason
property string _lastCloseReason: ""
signal closed()
function intersect(a, b) {
var x = Math.max(a.x, b.x), y = Math.max(a.y, b.y)
return Qt.rect(x, y, Math.max(0, Math.min(a.x + a.width, b.x + b.width) - x),
Math.max(0, Math.min(a.y + a.height, b.y + b.height) - y))
}
function refreshTarget() {
var rectangle = Qt.rect(0, 0, 0, 0)
var target = popupItem && popupParent && !busy && currentStep && currentStep.target ? currentStep.target() : null
if (popupItem && popupParent && target && target.visible && target.width > 0 && target.height > 0
&& target.Window.window === popupParent.Window.window) {
rectangle = target.mapToItem(popupParent, 0, 0, target.width, target.height)
for (var ancestor = target.parent; ancestor; ancestor = ancestor.parent) {
if (!ancestor.visible) {
rectangle = Qt.rect(0, 0, 0, 0)
break
}
if (ancestor.clip)
rectangle = intersect(rectangle, ancestor.mapToItem(popupParent, 0, 0,
ancestor.width, ancestor.height))
}
rectangle = intersect(rectangle, Qt.rect(0, 0, popupParent.width, popupParent.height))
}
_targetRect = rectangle
}
function open() {
if (popupItem || !popupParent || steps.length === 0)
return false
index = -1
index = 0
popupItem = comp_popup.createObject(popupParent)
if (!popupItem)
return false
_lastCloseReason = ""
refreshTarget()
return true
}
function close(reason) {
if (!popupItem)
return
_lastCloseReason = reason || "programmatic"
var item = popupItem
popupItem = null
_targetRect = Qt.rect(0, 0, 0, 0)
item.destroy()
closed()
}
function next() {
index = Math.min(index + 1, steps.length - 1)
}
function previous() { index = Math.max(index - 1, 0) }
function advance() {
if (!popupItem || busy) return
if (currentStep && currentStep.onNextListener)
currentStep.onNextListener(control)
else if (index === steps.length - 1 || (currentStep && currentStep.isLast === true))
close("complete")
else
next()
}
function focusGuide() { if (popupItem) popupItem.forceActiveFocus() }
onIndexChanged: refreshTarget()
onBusyChanged: refreshTarget()
Component.onDestruction: close("interrupted")
Component {
id: com_indicator
PageIndicator {
count: total
currentIndex: current
interactive: true
}
}
Component {
id: comp_popup
FocusScope {
id: popup
objectName: control.objectName + ".overlay"
anchors.fill: parent
z: 10000
focus: true
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
readonly property rect highlightRect: canvas.targetWidth > 0 && canvas.targetHeight > 0
? Qt.rect(canvas.targetX, canvas.targetY, canvas.targetWidth, canvas.targetHeight)
: Qt.rect(0, 0, 0, 0)
readonly property rect cardRect: Qt.rect(card.x, card.y, card.width, card.height)
function focusCardControl(forward) {
var origin = popup.Window.window.activeFocusItem || closeButton
var candidate = origin.nextItemInFocusChain(forward)
for (var n = 0; candidate && candidate !== origin && n < 1024; ++n) {
var ancestor = candidate
while (ancestor && ancestor !== card) ancestor = ancestor.parent
if (ancestor === card && candidate.visible && candidate.enabled && candidate.activeFocusOnTab) {
candidate.forceActiveFocus(forward ? Qt.TabFocusReason : Qt.BacktabFocusReason)
return
}
candidate = candidate.nextItemInFocusChain(forward)
}
closeButton.forceActiveFocus()
}
Component.onCompleted: forceActiveFocus()
Component.onDestruction: {
if (control.popupItem === popup) {
control._lastCloseReason = "interrupted"
control.popupItem = null
control._targetRect = Qt.rect(0, 0, 0, 0)
control.closed()
}
}
Keys.priority: Keys.AfterItem
Keys.onShortcutOverride: function(event) {
if (control.blockTargetInteraction || event.key === Qt.Key_Escape)
event.accepted = true
}
Keys.onPressed: function(event) {
if (control.keyboardNavigation && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
event.accepted = true
if (!event.isAutoRepeat && (event.modifiers === Qt.NoModifier
|| (event.key === Qt.Key_Enter && event.modifiers === Qt.KeypadModifier)))
control.advance()
} else if (event.key === Qt.Key_Escape) {
control.close("dismissed")
event.accepted = true
} else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
popup.focusCardControl(event.key !== Qt.Key_Backtab && !(event.modifiers & Qt.ShiftModifier))
event.accepted = true
} else if (control.blockTargetInteraction) {
event.accepted = true
}
}
Keys.onReleased: function(event) {
if (control.blockTargetInteraction || (control.keyboardNavigation
&& (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)))
event.accepted = true
}
Connections {
target: popup.Window.window
function onAfterAnimating() { control.refreshTarget() }
function onVisibleChanged() {
if (!popup.Window.window || !popup.Window.window.visible)
control.close("interrupted")
}
}
MouseArea {
anchors.fill: parent
enabled: control.blockTargetInteraction
hoverEnabled: true
acceptedButtons: Qt.AllButtons
preventStealing: true
onWheel: function(wheel) { wheel.accepted = true }
}
MouseArea {
x: 0; y: 0; width: parent.width
height: Math.max(0, canvas.targetY)
enabled: !control.blockTargetInteraction
hoverEnabled: true
acceptedButtons: Qt.AllButtons
onWheel: function(wheel) { wheel.accepted = true }
}
MouseArea {
x: 0; y: Math.max(0, canvas.targetY)
width: Math.max(0, canvas.targetX)
height: Math.max(0, canvas.targetHeight)
enabled: !control.blockTargetInteraction
hoverEnabled: true
acceptedButtons: Qt.AllButtons
onWheel: function(wheel) { wheel.accepted = true }
}
MouseArea {
x: Math.max(0, canvas.targetX + canvas.targetWidth); y: Math.max(0, canvas.targetY)
width: Math.max(0, parent.width - x)
height: Math.max(0, canvas.targetHeight)
enabled: !control.blockTargetInteraction
hoverEnabled: true
acceptedButtons: Qt.AllButtons
onWheel: function(wheel) { wheel.accepted = true }
}
MouseArea {
x: 0; y: Math.max(0, canvas.targetY + canvas.targetHeight)
width: parent.width
height: Math.max(0, parent.height - y)
enabled: !control.blockTargetInteraction
hoverEnabled: true
acceptedButtons: Qt.AllButtons
onWheel: function(wheel) { wheel.accepted = true }
}
TourBackgroundImpl {
id: canvas
anchors.fill: parent
radius: control.radius
color: control.maskColor
readonly property rect bounds: control.targetValid
? control.intersect(Qt.rect(control.targetRect.x - control.offset - control.offsetX,
control.targetRect.y - control.offset - control.offsetY,
control.targetRect.width + 2 * (control.offset + control.offsetX),
control.targetRect.height + 2 * (control.offset + control.offsetY)),
Qt.rect(0, 0, width, height)) : Qt.rect(0, 0, 0, 0)
targetX: bounds.x; targetY: bounds.y
targetWidth: bounds.width; targetHeight: bounds.height
}
Rectangle {
id: card
objectName: control.objectName + ".card"
z: 1
radius: Theme.popupRadius
color: control.backgroundColor
width: Math.max(1, Math.min(500, popup.width - 32))
height: Math.min(content.implicitHeight + 30, Math.max(1, popup.height - 32))
readonly property int placement: {
if (control.targetValid) {
if (control.targetRect.y + control.targetRect.height + height + 31 <= popup.height) return 0
if (control.targetRect.y - height - 15 >= 16) return 1
if (control.targetRect.x - width - 15 >= 16) return 2
if (control.targetRect.x + control.targetRect.width + width + 31 <= popup.width) return 3
}
return 4
}
x: {
var proposed = control.targetRect.x + control.targetRect.width / 2 - width / 2
if (placement === 2) proposed = control.targetRect.x - width - 15
if (placement === 3) proposed = control.targetRect.x + control.targetRect.width + 15
if (placement === 4) proposed = popup.width - width - 16
return Math.max(16, Math.min(popup.width - width - 16, proposed))
}
y: {
if (placement === 0) return Math.max(16, control.targetRect.y + control.targetRect.height + 15)
if (placement === 1) return control.targetRect.y - height - 15
if (placement === 2 || placement === 3)
return Math.max(16, Math.min(popup.height - height - 16,
control.targetRect.y + control.targetRect.height / 2 - height / 2))
return Math.max(16, popup.height - height - 16)
}
Shadow { radius: card.radius }
ColumnLayout {
id: content
anchors.fill: parent
anchors.margins: 15
spacing: 12
RowLayout {
Layout.fillWidth: true
Label {
Layout.fillWidth: true
text: control.currentStep ? control.currentStep.title : ""
font: Typography.bodyStrong
wrapMode: Text.Wrap
}
IconButton {
id: closeButton
Keys.forwardTo: control.keyboardNavigation ? [popup] : []
objectName: control.objectName + ".close"
width: 26; height: 26
icon.name: FluentIcons.graph_ChromeClose
icon.width: 12; icon.height: 12
onClicked: control.close("dismissed")
}
}
ScrollView {
id: descriptionScroll
Layout.fillWidth: true
contentWidth: availableWidth
Layout.preferredHeight: Math.min(text_desc.implicitHeight, Math.max(40, popup.height - 210))
clip: true
ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
Label {
id: text_desc
objectName: control.objectName + ".description"
width: descriptionScroll.availableWidth
font: Typography.body
wrapMode: Text.Wrap
text: control.statusText || (control.currentStep ? control.currentStep.description : "")
}
}
RowLayout {
Layout.fillWidth: true
AutoLoader {
readonly property int total: control.steps.length
readonly property int current: control.index
readonly property int count: control.steps.length
readonly property int currentIndex: control.index
Layout.fillWidth: true
sourceComponent: control.indicator
}
Button {
Keys.forwardTo: control.keyboardNavigation ? [popup] : []
objectName: control.objectName + ".previous"
text: control.previousText
visible: control.index > 0
enabled: !control.busy
onClicked: {
if (control.currentStep && control.currentStep.onPreviousListener)
control.currentStep.onPreviousListener(control)
else
control.previous()
}
}
StandardButton {
id: button_next
Keys.forwardTo: control.keyboardNavigation ? [popup] : []
objectName: control.objectName + ".next"
readonly property bool isLast: control.index === control.steps.length - 1
|| (control.currentStep && control.currentStep.isLast === true)
text: isLast ? control.finishText : control.nextText
accentColor: control.accentColor
highlighted: true
enabled: !control.busy
onClicked: control.advance()
}
}
}
}
Icon {
visible: control.targetValid && (card.y >= control.targetRect.y + control.targetRect.height
|| card.y + card.height <= control.targetRect.y)
source: card.y < control.targetRect.y ? FluentIcons.graph_FlickUp : FluentIcons.graph_FlickDown
color: control.backgroundColor
x: Math.max(card.x, Math.min(card.x + card.width - 20,
control.targetRect.x + control.targetRect.width / 2 - 10))
y: card.y < control.targetRect.y ? card.y + card.height - 4 : card.y - 12
}
}
}
}
