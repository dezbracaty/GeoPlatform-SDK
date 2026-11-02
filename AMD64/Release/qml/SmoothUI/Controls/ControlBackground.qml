/*!
\qmltype ControlBackground
\inqmlmodule SmoothUI.Controls
\brief Renders interaction-state-aware backgrounds for controls.
Provides state-driven background fill colors based on the target
control's enabled, pressed, hovered, and highlighted states.
Follows Fluent Design's control fill color conventions.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
SmoothUI.theme: Theme.of(control)
property int radius: target ? target.SmoothUI.radius : Theme.controlRadius
property bool highlighted: false
property var accentColor: SmoothUI.theme.accentColor
property var target
property color color: {
if(control.highlighted){
if(!control.accentColor){
return "#00000000"
}
if(!target.enabled){
return control.SmoothUI.theme.res.accentFillColorDisabled
}
if(target.pressed){
return control.accentColor.tertiaryBrushFor(control.SmoothUI.dark)
}
if(target.hovered){
return control.accentColor.secondaryBrushFor(control.SmoothUI.dark)
}
return control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}else{
return Theme.buttonColor(target,false,control.SmoothUI.dark)
}
}
Rectangle{
radius: control.radius
anchors.fill: parent
color: control.color
}
onHighlightedChanged: {
canvas.update()
}
ControlBackgroundImpl{
id: canvas
anchors.fill: parent
radius: control.radius
defaultColor: {
if (!target.enabled) {
return control.highlighted ? control.SmoothUI.theme.res.controlStrokeColorOnAccentDisabled
: control.SmoothUI.theme.res.controlStrongStrokeColorDisabled
}
return control.highlighted ? control.SmoothUI.theme.res.controlStrokeColorOnAccentDefault
: control.SmoothUI.theme.res.controlStrokeColorDefault
}
secondaryColor: defaultColor
endColor: defaultColor
borderWidth: Theme.borderWidth
onHeightChanged: {
canvas.update()
}
onWidthChanged: {
canvas.update()
}
}
Connections{
target: Theme
function onDarkChanged(){
canvas.update()
}
}
Connections{
target: control.target
function onPressedChanged(){
canvas.update()
}
}
}
