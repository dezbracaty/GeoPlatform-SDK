/*!
\qmltype RadioButton
\inqmlmodule SmoothUI
\brief A Fluent-styled radio button with animated indicator.
Wraps \l T.RadioButton with SmoothUI theme integration.
Provides a circular radio button with accent color,
animated border transition, and checked state styling.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.RadioButton {
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
font: Typography.body
focusPolicy: Qt.TabFocus
indicator: Rectangle {
x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
y: control.topPadding + (control.availableHeight - height) / 2
implicitWidth: 20
implicitHeight: 20
radius: width / 2
color: {
if(control.checked){
return control.SmoothUI.theme.res.textOnAccentFillColorPrimary
}else{
if(!control.enabled){
return control.SmoothUI.theme.res.controlAltFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.controlAltFillColorQuarternary
}
if(control.hovered){
return control.SmoothUI.theme.res.controlAltFillColorTertiary
}
return control.SmoothUI.theme.res.controlAltFillColorSecondary
}
}
border.width: {
if(control.checked){
if(control.enabled){
if(control.hovered && !control.pressed){
return 3.4
}
return 5.0
}else{
return 4.0
}
}else{
if(control.pressed){
return 4.5
}
return 1
}
}
border.color: {
if(control.checked){
if (typeof Theme.checkedInputColor === "function" && control.accentColor) {
return Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
}
return "transparent"
}else{
if(!control.enabled){
return control.SmoothUI.theme ? control.SmoothUI.theme.res.textFillColorDisabled : "transparent"
}
if(control.pressed){
return control.accentColor ? control.accentColor.defaultBrushFor(control.SmoothUI.dark) : "transparent"
}
return control.SmoothUI.theme ? control.SmoothUI.theme.res.textFillColorTertiary : "transparent"
}
}
Behavior on border.width {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
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
