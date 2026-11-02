/*!
\qmltype MultiSelectComboBox
\inqmlmodule SmoothUI.Controls
\brief A combo box allowing multiple item selection.
Provides a dropdown selection control where users can select
multiple items from a list, with placeholder text and
highlighted state support.
*/
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import SmoothUI.Controls
import QtQuick.Controls.impl as QQCImpl
import QtQuick.Templates as T
import SmoothUI.impl
T.ComboBox {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property string placeholderText: qsTr("Please select")
property bool highlighted: false
property string itemEnabledRole: ""
property alias selectedItems: selected_items
property alias visualModel: visual_model
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
font: Typography.body
editable: false
DelegateModel {
id: visual_model
model: control.model
groups: [
DelegateModelGroup {
id: selected_items
name: "selected"
}
]
delegate: control.delegate
}
delegate: ListTile {
id: control_item
width: ListView.view.width
text: control.textRole ? control.model instanceof Array ? model.modelData[control.textRole] : model[control.textRole] : model.modelData
highlighted: control.highlightedIndex === index
hoverEnabled: control.hoverEnabled
font: control.font
enabled: {
if (!control.itemEnabledRole) return true
var val = control.model instanceof Array
? model.modelData[control.itemEnabledRole]
: model[control.itemEnabledRole]
return val !== false
}
leading: CheckBox{
checkable: false
checked: control_item.DelegateModel.inSelected
enabled: control_item.enabled
onClicked: {
control_item.clicked()
}
}
spacing: 0
leftPadding: 6
rightPadding: 6
background: FocusItem{
radius: control.SmoothUI.radius
implicitHeight: Theme.controlHeight
implicitWidth: 100
target: control_item
Rectangle{
radius: control.SmoothUI.radius
anchors{
fill: parent
leftMargin: 6
rightMargin: 6
topMargin: 2
bottomMargin: 2
}
color: control_item.DelegateModel.inSelected ? control.SmoothUI.theme.res.subtleFillColorSecondary : Theme.uncheckedInputColor(control_item,true,true,control.SmoothUI.dark)
}
}
onClicked: {
if (!control_item.enabled) return
control_item.DelegateModel.inSelected = !control_item.DelegateModel.inSelected
}
}
indicator: Item{
width: 35
height: 35
x: control.mirrored ? control.padding : control.width - width - control.padding
y: (control.topPadding + (control.availableHeight - height) / 2) + (control.pressed ? 1 : 0)
Behavior on y {
NumberAnimation{ easing.type: Theme.animationCurve; duration: Theme.fastAnimationDuration }
}
Icon {
color: control.enabled ? control.SmoothUI.theme.res.textFillColorSecondary : control.SmoothUI.theme.res.textFillColorDisabled
source: FluentIcons.graph_ChevronDown
width: 12
height: 12
anchors.centerIn: parent
}
}
contentItem: T.TextField {
leftPadding: Theme.controlHorizontalPadding
autoScroll: false
enabled: false
readOnly: control.down
inputMethodHints: control.inputMethodHints
validator: control.validator
selectByMouse: false
color: {
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
placeholderText: list_view_chip.count === 0 ? control.placeholderText : ""
placeholderTextColor: control.SmoothUI.theme.res.textFillColorSecondary
font: Typography.body
renderType: Theme.textRender
selectionColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
verticalAlignment: Text.AlignVCenter
z: 999
QQCImpl.PlaceholderText {
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
Item{
anchors.fill: contentItem
ListView{
id: list_view_chip
width: Math.min(parent.width-10,contentItem.childrenRect.width)
height: contentItem.childrenRect.height
boundsBehavior: ListView.StopAtBounds
delegate: Chip{
property var __model: selectedItems.get(model.index).model
text: control.textRole ? control.model instanceof Array ? __model.modelData[control.textRole] : __model[control.textRole]: __model.modelData
onCloseClicked: {
selectedItems.get(model.index).inSelected = false
}
}
spacing: 5
clip: true
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 5
}
orientation: ListView.Horizontal
model: control.selectedItems.count
}
}
background: Item{
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
width: control.width
height: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, control.Window.height - topMargin - bottomMargin)
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
verticalPadding: 6
y: control.height
enter: Transition {
NumberAnimation { property: "height"; from: control.popup.height / 3; to: control.popup.height; easing.type: Theme.animationCurve; duration: Theme.fastAnimationDuration }
}
contentItem: ListView {
clip: true
implicitHeight: Math.min(contentHeight,control.SmoothUI.minimumHeight)
highlightMoveDuration: 0
model: visual_model
currentIndex: control.highlightedIndex
ScrollBar.vertical: ScrollBar {
visible: !popup.enter.running && policy !== ScrollBar.AlwaysOff && size < 1.0
}
boundsBehavior: ListView.StopAtBounds
}
background: Rectangle{
radius: Theme.popupRadius
border.width: 1
color: control.SmoothUI.theme.res.popupBackgroundColor
border.color: control.SmoothUI.theme.res.popupBorderColor
Shadow{
radius: Theme.popupRadius
}
}
}
}
