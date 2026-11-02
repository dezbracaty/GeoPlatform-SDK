/*!
\qmltype SpinBox
\inqmlmodule SmoothUI
\brief A Fluent-styled spin box with increment/decrement buttons.
Wraps \l T.SpinBox with SmoothUI theme integration.
Provides numeric input with up/down arrow indicators,
highlighted state, and accent-colored selection.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.SpinBox {
id: control
SmoothUI.theme: Theme.of(control)
font: Typography.body
property var accentColor: SmoothUI.theme.accentColor
property bool highlighted: false
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentItem.implicitWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
up.implicitIndicatorHeight, down.implicitIndicatorHeight)
leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))
validator: IntValidator {
locale: control.locale.name
bottom: Math.min(control.from, control.to)
top: Math.max(control.from, control.to)
}
contentItem: T.TextField {
z: 2
text: control.displayText
clip: width < implicitWidth
padding: Theme.controlPadding
color: {
if(!control.enabled){
return control.SmoothUI.theme ? control.SmoothUI.theme.res.textFillColorDisabled : "gray"
}
return control.SmoothUI.theme ? control.SmoothUI.theme.res.textFillColorPrimary : "black"
}
selectionColor: control.accentColor ? control.accentColor.defaultBrushFor(control.SmoothUI.dark) : "steelblue"
selectedTextColor: typeof Colors.basedOnLuminance === "function" ? Colors.basedOnLuminance(selectionColor) : "white"
horizontalAlignment: Qt.AlignHCenter
verticalAlignment: Qt.AlignVCenter
font: control.font
renderType: Theme.textRender
readOnly: !control.editable
validator: control.validator
inputMethodHints: control.inputMethodHints
}
up.indicator: Item {
x: control.mirrored ? 0 : control.width - width
height: control.height
implicitWidth: 34
implicitHeight: Theme.controlHeight
Rectangle{
width: 30
height: 20
anchors{
verticalCenter: parent.verticalCenter
right: parent.right
rightMargin: 4
}
radius: control.SmoothUI.radius
color: {
if(!enabled){
return control.SmoothUI.theme.res.controlFillColorDisabled
}
if(control.up.pressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(control.up.hovered){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
Icon{
source: FluentIcons.graph_ChevronRight
width: 12
height: 12
anchors.centerIn: parent
color: enabled ? control.SmoothUI.theme.res.textFillColorPrimary : control.SmoothUI.theme.res.textFillColorDisabled
}
}
}
down.indicator: Item {
x: control.mirrored ? parent.width - width : 0
height: control.height
implicitWidth: 34
implicitHeight: Theme.controlHeight
Rectangle{
width: 30
height: 20
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 4
}
radius: control.SmoothUI.radius
color: {
if(!enabled){
return control.SmoothUI.theme.res.controlFillColorDisabled
}
if(control.down.pressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(control.down.hovered){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
Icon{
source: FluentIcons.graph_ChevronLeft
width: 12
height: 12
anchors.centerIn: parent
color: enabled ? control.SmoothUI.theme.res.textFillColorPrimary : control.SmoothUI.theme.res.textFillColorDisabled
}
}
}
background: Item{
implicitHeight: Theme.controlHeight
implicitWidth: 140
InputBackground {
anchors.fill: parent
target: control
radius: control.SmoothUI.radius
activeColor: control.accentColor ? control.accentColor.defaultBrushFor(control.SmoothUI.dark) : "steelblue"
}
}
}
