import QtQuick
import QtQuick.Templates as T
import SmoothUI.impl
/*!
\qmltype StandardButton
\inqmlmodule SmoothUI.Controls
\brief The standard Fluent UI button with multiple appearance modes
*/
T.Button {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.iconFamily: FluentIcons.fontLoader.name
property bool iconMirrored: control.mirrored
property var accentColor: SmoothUI.theme.accentColor
property bool forceHighlighted: highlighted
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
padding: Theme.controlPadding
horizontalPadding: Theme.controlHorizontalPadding
spacing: Theme.contentSpacing
icon.width: 16
icon.height: 16
icon.color: control.SmoothUI.textColor
focusPolicy: Qt.TabFocus
font: Typography.body
SmoothUI.textColor: {
if(control.forceHighlighted){
if(!control.enabled){
return control.SmoothUI.theme.res.textOnAccentFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textOnAccentFillColorSecondary
}
if(control.hovered){
return control.SmoothUI.theme.res.textOnAccentFillColorPrimary
}
return control.SmoothUI.theme.res.textOnAccentFillColorPrimary
}else{
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
}
contentItem: IconLabel {
spacing: control.spacing
mirrored: control.iconMirrored
display: control.display
icon: control.icon
text: control.text
font: control.font
color: control.SmoothUI.textColor
iconFamily: control.SmoothUI.iconFamily
elideWidth: {
var w = width - (leftPadding + rightPadding)
if (display === T.AbstractButton.TextBesideIcon) {
var hasIcon = icon.source.toString() !== "" || icon.name !== ""
if (hasIcon) {
w -= (icon.width + spacing)
}
}
return Math.ceil(w) + 1
}
}
background: FocusItem{
implicitHeight: Theme.controlHeight
implicitWidth: Theme.controlHeight
radius: control.SmoothUI.radius
target: control
ControlBackground {
id: control_background
anchors.fill: parent
radius: control.SmoothUI.radius
target: control
highlighted: control.forceHighlighted
visible: !control.flat || control.down || control.checked || control.forceHighlighted
}
}
}
