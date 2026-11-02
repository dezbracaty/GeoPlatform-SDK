/*!
\qmltype RangeSlider
\inqmlmodule SmoothUI
\brief A Fluent-styled dual-handle range slider.
Wraps \l T.RangeSlider with SmoothUI theme integration.
Provides two draggable handles for selecting a value range
with an accent-colored range highlight.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.RangeSlider {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
first.implicitHandleWidth + leftPadding + rightPadding,
second.implicitHandleWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
first.implicitHandleHeight + topPadding + bottomPadding,
second.implicitHandleHeight + topPadding + bottomPadding)
focusPolicy: Qt.TabFocus
padding: 6
first.handle: Rectangle {
x: control.leftPadding + (control.horizontal ? control.first.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * (control.availableHeight - height))
implicitWidth: 22
implicitHeight: 22
radius: width * 0.5
border.width: 1
border.color: control.SmoothUI.theme.res.popupBorderColor
color: control.SmoothUI.theme.res.controlSolidFillColorDefault
Shadow{
radius: width * 0.5
}
Rectangle{
property real diameter: !control.enabled ? 10 : control.first.pressed ? 8 : control.first.hovered ? 14 : 10
width: diameter
height: diameter
anchors.centerIn: parent
radius: width * 0.5
color: {
if(!control.enabled){
return control.SmoothUI.theme.res.accentFillColorDisabled
}
if(control.first.pressed){
return control.accentColor.tertiaryBrushFor(control.SmoothUI.dark)
}
if(control.first.hovered){
return control.accentColor.secondaryBrushFor(control.SmoothUI.dark)
}
return control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
Behavior on diameter {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
second.handle: Rectangle {
x: control.leftPadding + (control.horizontal ? control.second.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * (control.availableHeight - height))
implicitWidth: 22
implicitHeight: 22
border.width: 1
border.color: control.SmoothUI.theme.res.popupBorderColor
radius: width * 0.5
color: control.SmoothUI.theme.res.controlSolidFillColorDefault
Shadow{
radius: width * 0.5
}
Rectangle{
property real diameter: !control.enabled ? 10 : control.second.pressed ? 8 : control.second.hovered ? 14 : 10
width: diameter
height: diameter
anchors.centerIn: parent
radius: diameter * 0.5
color: {
if(!control.enabled){
return control.SmoothUI.theme.res.accentFillColorDisabled
}
if(control.second.pressed){
return control.accentColor.tertiaryBrushFor(control.SmoothUI.dark)
}
if(control.second.hovered){
return control.accentColor.secondaryBrushFor(control.SmoothUI.dark)
}
return control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
Behavior on diameter {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
background: Item {
x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
implicitWidth: control.horizontal ? 200 : 6
implicitHeight: control.horizontal ? 6 : 200
width: control.horizontal ? control.availableWidth : implicitWidth
height: control.horizontal ? implicitHeight : control.availableHeight
FocusItem{
target: control
anchors.margins: -10
}
Rectangle{
implicitWidth: control.horizontal ? 200 : 4
implicitHeight: control.horizontal ? 4 : 200
width: control.horizontal ? control.availableWidth : implicitWidth
height: control.horizontal ? implicitHeight : control.availableHeight
anchors.centerIn: parent
radius: 2
color: {
if(!control.enabled){
return control.SmoothUI.theme.res.controlStrongFillColorDisabled
}
return control.SmoothUI.theme.res.controlStrongFillColorDefault
}
}
Rectangle {
x: control.horizontal ? control.first.position * parent.width + 3 : 0
y: control.horizontal ? 0 : control.second.visualPosition * parent.height + 3
width: control.horizontal ? control.second.position * parent.width - control.first.position * parent.width - 6 : 6
height: control.horizontal ? 6 : control.second.position * parent.height - control.first.position * parent.height - 6
color: Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
}
}
}
