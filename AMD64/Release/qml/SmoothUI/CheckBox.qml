/*!
\qmltype CheckBox
\inqmlmodule SmoothUI
\brief A Fluent-styled check box control with theme integration.
Wraps \l T.CheckBox with SmoothUI theme support, providing
accent-colored checked states and tristate (indeterminate) support.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.CheckBox {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
padding: Theme.controlPadding
spacing: Theme.contentSpacing
focusPolicy: Qt.TabFocus
font: Typography.body
indicator: Item {
x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
y: control.topPadding + (control.availableHeight - height) / 2
implicitWidth: 18
implicitHeight: 18
Rectangle {
anchors.centerIn: parent
anchors.fill: parent
radius: 4
color: {
if(control.checked || control.checkState === Qt.PartiallyChecked){
if (typeof Theme.checkedInputColor === "function" && control.accentColor) {
return Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
}
return "transparent"
}
if (typeof Theme.uncheckedInputColor === "function") {
return Theme.uncheckedInputColor(control,false,false,control.SmoothUI.dark)
}
return "transparent"
}
border.width: 1
border.color: {
if(!control.enabled || control.pressed){
return control.SmoothUI.theme ? control.SmoothUI.theme.res.controlStrongStrokeColorDisabled : "transparent"
}
if(control.checked || control.checkState === Qt.PartiallyChecked){
if (typeof Theme.checkedInputColor === "function" && control.accentColor) {
return Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
}
return "transparent"
}else{
return control.SmoothUI.theme ? control.SmoothUI.theme.res.controlStrongStrokeColorDefault : "transparent"
}
}
}
Icon{
source: FluentIcons.graph_CheckMark
width: 14
height: 14
anchors.centerIn: parent
color: control.SmoothUI.theme.res.textOnAccentFillColorPrimary
visible: control.checkState === Qt.Checked
}
Icon{
source: FluentIcons.graph_CheckboxIndeterminate
width: 14
height: 14
anchors.centerIn: parent
color: control.SmoothUI.theme.res.textOnAccentFillColorPrimary
visible: control.checkState === Qt.PartiallyChecked
}
}
contentItem: Label {
leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
text: control.text
font: control.font
verticalAlignment: Qt.AlignVCenter
}
background: FocusItem{
implicitHeight: Theme.controlHeight
target: control
}
}
