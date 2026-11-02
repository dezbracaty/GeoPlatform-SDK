/*!
\qmltype ComboBox
\inqmlmodule SmoothUI
\brief A Fluent-styled combo box control with editable support.
Wraps \l T.ComboBox with SmoothUI theme integration.
Supports both editable and read-only modes with a styled
dropdown popup.
*/
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ComboBox {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property bool highlighted: false
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
font: Typography.body
selectTextByMouse: true
SmoothUI.textColor: {
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textFillColorSecondary
}
if(control.flat && control.hovered){
return control.SmoothUI.theme.res.textFillColorTertiary
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
delegate: ListTile {
id: control_menu_item
required property var model
required property int index
width: ListView.view.width
text: control.textRole ? control.model instanceof Array ? model.modelData[control.textRole] : model[control.textRole] : model.modelData
highlighted: control.highlightedIndex === index
hoverEnabled: control.hoverEnabled
font: control.font
leftPadding: 18
background: FocusItem{
radius: control.SmoothUI.radius
implicitHeight: Theme.controlHeight
implicitWidth: 100
target: control_menu_item
Rectangle{
width: 3
height: 18
radius: 1.5
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 6
}
visible: control.currentIndex === index
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
Rectangle{
radius: control.SmoothUI.radius
anchors{
fill: parent
leftMargin: 6
rightMargin: 6
}
color: control_menu_item.highlighted ? control.SmoothUI.theme.res.subtleFillColorSecondary : Theme.uncheckedInputColor(control_menu_item,true,true,control.SmoothUI.dark)
}
}
onClicked: {
const selectedIndex = control_menu_item.index
control.currentIndex = selectedIndex
popup.close()
control.activated(selectedIndex)
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
text: control.editable ? control.editText : control.displayText
enabled: control.editable
autoScroll: control.editable
readOnly: control.down
inputMethodHints: control.inputMethodHints
validator: control.validator
selectByMouse: control.selectTextByMouse
color: control.editable || text.length === 0 ? control.SmoothUI.textColor : "transparent"
font: control.font
renderType: Theme.textRender
selectionColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
selectedTextColor: Colors.basedOnLuminance(selectionColor)
verticalAlignment: Text.AlignVCenter
z: 999
Text {
anchors.fill: parent
anchors.leftMargin: parent.leftPadding
anchors.rightMargin: parent.rightPadding
anchors.topMargin: parent.topPadding
anchors.bottomMargin: parent.bottomPadding
visible: !control.editable && text.length > 0
enabled: false
Accessible.ignored: true
LayoutMirroring.enabled: false
text: control.displayText
font: parent.font
color: control.SmoothUI.textColor
renderType: parent.renderType
verticalAlignment: parent.verticalAlignment
horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
elide: control.mirrored ? Text.ElideLeft : Text.ElideRight
}
}
background: Item{
implicitWidth: 120
implicitHeight: Theme.controlHeight
InputBackground {
anchors.fill: parent
target: control
radius: control.SmoothUI.radius
activeColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
visible: control.editable
}
ControlBackground{
anchors.fill: parent
target: control
radius: control.SmoothUI.radius
visible: !control.editable
}
}
popup: T.Popup {
property int popupHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, control.Window.height - topMargin - bottomMargin)
topMargin: 8
bottomMargin: 8
width: control.width
height: popupHeight
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
verticalPadding: 6
contentItem: ListView {
implicitHeight: Math.min(contentHeight,control.SmoothUI.minimumHeight)
highlightMoveDuration: 0
model: control.model
clip: true
delegate: control.delegate
currentIndex: control.highlightedIndex
highlightFollowsCurrentItem: false
ScrollBar.vertical: ScrollBar {
visible: !popup.enter.running && policy !== ScrollBar.AlwaysOff && size < 1.0
}
boundsBehavior: ListView.StopAtBounds
}
y: control.editable ? control.height
: -0.25 * Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentItem.height + topPadding + bottomPadding)
enter: Transition {
NumberAnimation {
property: "height"
from: control.popup.popupHeight / 3
to: control.popup.popupHeight
easing.type: Theme.animationCurve
duration: Theme.mediumAnimationDuration
}
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
