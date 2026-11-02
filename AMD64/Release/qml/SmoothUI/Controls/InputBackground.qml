/*!
\qmltype InputBackground
\inqmlmodule SmoothUI.Controls
\brief Renders the state-driven background for text input controls.
Provides themed background fill for text input fields with
accent-colored focus indicator and state-dependent colors
for enabled/disabled/hovered/focused states.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
property int radius: target ? target.SmoothUI.radius : Theme.controlRadius
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property var target
property var activeColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
property color color: {
if(!target.enabled){
return control.SmoothUI.theme.res.controlFillColorDisabled
}
if(target.activeFocus){
return control.SmoothUI.theme.res.controlFillColorInputActive
}
if(target.pressed){
return control.SmoothUI.theme.res.controlFillColorTertiary
}
if(target.hovered){
return control.SmoothUI.theme.res.controlFillColorSecondary
}
return control.SmoothUI.theme.res.controlFillColorDefault
}
Rectangle{
radius: control.radius
anchors.fill: parent
color: control.color
}
Connections{
target: Theme
function onDarkChanged(){
canvas.update()
}
}
Connections{
target: control.target
function onActiveFocusChanged(){
canvas.update()
}
}
InputBackgroundImpl{
id: canvas
targetActiveFocus: control.target.activeFocus
radius: control.radius
offsetY: 0
defaultColor: !control.target.enabled ? control.SmoothUI.theme.res.controlStrongStrokeColorDisabled
: control.target.activeFocus ? control.activeColor
: control.target.hovered ? control.SmoothUI.theme.res.controlStrongStrokeColorDefault
: control.SmoothUI.theme.res.controlStrokeColorDefault
endColor: defaultColor
borderWidth: Theme.borderWidth
gradientHeight: 1
anchors.fill: parent
onHeightChanged: {
canvas.update()
}
onWidthChanged: {
canvas.update()
}
}
}
