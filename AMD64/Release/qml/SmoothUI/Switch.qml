/*!
\qmltype Switch
\inqmlmodule SmoothUI
\brief A Fluent-styled toggle switch with animated handle.
Wraps \l T.Switch with SmoothUI theme integration.
Provides an accent-colored switch indicator with animated
handle position and width transitions.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Switch {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
padding: Theme.space8
spacing: Theme.contentSpacing
font: Typography.body
focusPolicy: Qt.TabFocus
indicator: Rectangle {
id: indicator
width: 40
height: 20
x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
y: control.topPadding + (control.availableHeight - height) / 2
radius: height / 2
color: {
if(control.checked){
return Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
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
border.width: 1
border.color: {
if(control.checked){
return Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
}else{
if(!control.enabled){
return control.SmoothUI.theme.res.controlStrongFillColorDisabled
}
return control.SmoothUI.theme.res.controlStrongFillColorDefault
}
}
Rectangle {
id: handle
readonly property int offset: 4
x: Math.max(offset, Math.min(parent.width - offset - width,control.visualPosition * parent.width - (width / 2)))
y: (parent.height - height) / 2
width: {
if(control.pressed){
return 17
}
return 14
}
height: 14
scale: {
if(!control.enabled){
return 0.857
}
if(control.hovered){
return 1.0
}
return 0.857
}
radius: width / 2
color: {
if(control.checked){
if(!control.enabled){
return control.SmoothUI.theme.res.textOnAccentFillColorDisabled
}
return Colors.white
}else{
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
return control.SmoothUI.theme.res.textFillColorSecondary
}
}
Behavior on x {
enabled: !control.pressed
NumberAnimation {
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
Behavior on width{
enabled: control.pressed
NumberAnimation {
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
Behavior on scale {
NumberAnimation {
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
contentItem: Label {
leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
text: control.text
font: control.font
elide: Text.ElideRight
verticalAlignment: Text.AlignVCenter
}
background: FocusItem{
target: control
}
}
