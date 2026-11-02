/*!
\qmltype AccentColor
\inqmlmodule SmoothUI.Controls
\brief Manages accent color shades with dark/light variants.
Provides a chain of accent color variations (normal → dark → darker → darkest
and light → lighter → lightest) following Fluent Design color ramp principles.
Each shade falls back to an opacity-based interpolation of the parent shade.
*/
import QtQuick
import SmoothUI.impl
Objects {
id: control
property var hoverLight: null
property var pressedLight: null
property var hoverDark: null
property var pressedDark: null
required property var normal
QtObject{
id: d
property var darkest
property var darker
property var dark
property var light
property var lighter
property var lightest
}
function darkest(val){
if(arguments.length === 0){
if(d.darkest){
return d.darkest
}
return Colors.withOpacity(control.darker(),0.7)
}else{
d.darkest = val
}
}
function darker(val){
if(arguments.length === 0){
if(d.darker){
return d.darker
}
return Colors.withOpacity(control.dark(),0.8)
}else{
d.darker = val
}
}
function dark(val){
if(arguments.length === 0){
if(d.dark){
return d.dark
}
return Colors.withOpacity(control.normal,0.9)
}else{
d.dark = val
}
}
function light(val){
if(arguments.length === 0){
if(d.light){
return d.light
}
return Colors.withOpacity(control.normal,0.9)
}else{
d.light = val
}
}
function lighter(val){
if(arguments.length === 0){
if(d.lighter){
return d.lighter
}
return Colors.withOpacity(control.light(),0.8)
}else{
d.lighter = val
}
}
function lightest(val){
if(arguments.length === 0){
if(d.lightest){
return d.lightest
}
return Colors.withOpacity(control.lighter(),0.7)
}else{
d.lightest = val
}
}
function defaultBrushFor(isDark=null){
if(isDark === null || isDark === undefined){
isDark = Theme.dark
}
if(isDark){
return lighter()
}else{
return dark()
}
}
function secondaryBrushFor(isDark){
if(isDark === null || isDark === undefined) isDark = Theme.dark
const brush = isDark ? hoverDark : hoverLight
return brush !== null && brush !== undefined ? brush : Colors.withOpacity(defaultBrushFor(isDark),0.8)
}
function tertiaryBrushFor(isDark){
if(isDark === null || isDark === undefined) isDark = Theme.dark
const brush = isDark ? pressedDark : pressedLight
return brush !== null && brush !== undefined ? brush : Colors.withOpacity(defaultBrushFor(isDark),0.7)
}
}
