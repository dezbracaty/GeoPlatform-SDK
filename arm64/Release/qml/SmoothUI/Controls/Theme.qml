pragma Singleton
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
/*!
\qmltype Theme
\inqmlmodule SmoothUI.Controls
\brief Singleton providing the current Fluent Design theme context and resolution
*/
Objects {
id: control
readonly property int controlHeight: 36
readonly property int compactControlHeight: 32
readonly property int actionHeight: 40
readonly property int iconButtonSize: 36
readonly property int toolbarButtonSize: 40
readonly property int controlRadius: control.SmoothUI.radius
readonly property int panelRadius: 10
readonly property int popupRadius: 8
readonly property int dialogRadius: 12
readonly property int controlPadding: 6
readonly property int controlHorizontalPadding: 12
readonly property int contentSpacing: 8
readonly property int space4: 4
readonly property int space8: 8
readonly property int space12: 12
readonly property int space16: 16
readonly property int space24: 24
readonly property int space32: 32
readonly property int popupPadding: 12
readonly property int dialogPadding: 16
readonly property int borderWidth: 1
readonly property int focusBorderWidth: 2
readonly property int bodyFontSize: 14
readonly property int captionFontSize: 12
readonly property int panelTitleFontSize: 16
readonly property int pageTitleFontSize: 22
function shadowOpacityFor(isDark, baseOpacity) {
const value = Math.max(0, Math.min(1, baseOpacity === undefined ? 0.16 : baseOpacity))
return isDark ? Math.min(0.72, value * 1.7) : value
}
property int darkMode: SmoothUI.System
readonly property bool dark: {
if(darkMode === SmoothUI.Light){
return false
}else if(darkMode === SmoothUI.Dark){
return true
}else{
return R.systemDark
}
}
property int textRender: TextEdit.NativeRendering
property int tooltipDelay: 800
property int fasterAnimationDuration: 83
property int fastAnimationDuration: 167
property int mediumAnimationDuration: 250
property int slowAnimationDuration: 358
property int animationCurve: Easing.OutCubic
property var primaryColor: Colors.blue
property var accentColor: ofAccentColor(primaryColor)
property ColorResource res: dark ? darkResource : lightResource
property ColorResource darkResource: ColorResource{
popupBorderColor: "#414955"
popupBackgroundColor: "#22262D"
micaBackgroundColor: solidBackgroundFillColorBase
scaffoldBackgroundColor: layerOnAcrylicFillColorDefault
acrylicBackgroundColor: "#22262D"
inactiveBackgroundColor: "#181B20"
textFillColorPrimary: "#F3F5F8"
textFillColorSecondary: "#B5BFCE"
textFillColorTertiary: "#85909F"
textFillColorDisabled: "#5dffffff"
textFillColorInverse: "#e4000000"
accentTextFillColorDisabled: "#5dffffff"
textOnAccentFillColorSelectedText: "#FFffffff"
textOnAccentFillColorPrimary: "#FF000000"
textOnAccentFillColorSecondary: "#80000000"
textOnAccentFillColorDisabled: "#87ffffff"
controlFillColorDefault: "#2A3039"
controlFillColorSecondary: "#343C48"
controlFillColorTertiary: "#2B333E"
controlFillColorDisabled: "#0bffffff"
controlFillColorTransparent: "#00ffffff"
controlFillColorInputActive: "#22262D"
controlStrongFillColorDefault: "#8bffffff"
controlStrongFillColorDisabled: "#3fffffff"
controlSolidFillColorDefault: "#2A3039"
subtleFillColorTransparent: "#00ffffff"
subtleFillColorSecondary: "#0fffffff"
subtleFillColorTertiary: "#0affffff"
subtleFillColorDisabled: "#00ffffff"
controlAltFillColorTransparent: "#00ffffff"
controlAltFillColorSecondary: "#19000000"
controlAltFillColorTertiary: "#0bffffff"
controlAltFillColorQuarternary: "#12ffffff"
controlAltFillColorDisabled: "#00ffffff"
controlOnImageFillColorDefault: "#b31c1c1c"
controlOnImageFillColorSecondary: "#FF1a1a1a"
controlOnImageFillColorTertiary: "#FF131313"
controlOnImageFillColorDisabled: "#FF1e1e1e"
accentFillColorDisabled: "#28ffffff"
controlStrokeColorDefault: "#414955"
controlStrokeColorSecondary: "#343C48"
controlStrokeColorOnAccentDefault: "#14ffffff"
controlStrokeColorOnAccentSecondary: "#23000000"
controlStrokeColorOnAccentTertiary: "#37000000"
controlStrokeColorOnAccentDisabled: "#33000000"
controlStrokeColorForStrongFillWhenOnImage: "#6b000000"
cardStrokeColorDefault: "#414955"
cardStrokeColorDefaultSolid: "#414955"
controlStrongStrokeColorDefault: "#8bffffff"
controlStrongStrokeColorDisabled: "#28ffffff"
surfaceStrokeColorDefault: "#414955"
surfaceStrokeColorFlyout: "#414955"
surfaceStrokeColorInverse: "#0f000000"
dividerStrokeColorDefault: "#343C48"
focusStrokeColorOuter: control.accentColor.defaultBrushFor(true)
focusStrokeColorInner: "#181B20"
cardBackgroundColor: "#22262D"
cardBackgroundFillColorDefault: "#22262D"
cardBackgroundFillColorSecondary: "#2A3039"
smokeFillColorDefault: "#4d000000"
layerFillColorDefault: "#4c3a3a3a"
layerFillColorAlt: "#0dffffff"
layerOnAcrylicFillColorDefault: "#09ffffff"
layerOnAccentAcrylicFillColorDefault: "#09ffffff"
layerOnMicaBaseAltFillColorDefault: "#733a3a3a"
layerOnMicaBaseAltFillColorSecondary: "#0fffffff"
layerOnMicaBaseAltFillColorTertiary: "#FF2c2c2c"
layerOnMicaBaseAltFillColorTransparent: "#00ffffff"
solidBackgroundFillColorBase: "#181B20"
solidBackgroundFillColorSecondary: "#2A3039"
solidBackgroundFillColorTertiary: "#343C48"
solidBackgroundFillColorQuarternary: "#22262D"
solidBackgroundFillColorTransparent: "#00202020"
solidBackgroundFillColorBaseAlt: "#14171B"
systemFillColorSuccess: "#73D3A0"
systemFillColorCaution: "#F1C267"
systemFillColorCritical: "#FF9B9B"
systemFillColorNeutral: "#8bffffff"
systemFillColorSolidNeutral: "#FF9d9d9d"
systemFillColorAttentionBackground: "#08ffffff"
systemFillColorSuccessBackground: Qt.tint(cardBackgroundColor, Colors.withOpacity(systemFillColorSuccess, 0.06))
systemFillColorCautionBackground: Qt.tint(cardBackgroundColor, Colors.withOpacity(systemFillColorCaution, 0.06))
systemFillColorCriticalBackground: Qt.tint(cardBackgroundColor, Colors.withOpacity(systemFillColorCritical, 0.05))
systemFillColorNeutralBackground: "#08ffffff"
systemFillColorSolidAttentionBackground: "#FF2e2e2e"
systemFillColorSolidNeutralBackground: "#FF2e2e2e"
shadowColor: "#000000"
}
property ColorResource lightResource: ColorResource{
popupBorderColor: "#D9DEE7"
popupBackgroundColor: "#FFFFFF"
micaBackgroundColor: solidBackgroundFillColorBase
scaffoldBackgroundColor: layerOnAcrylicFillColorDefault
acrylicBackgroundColor: "#FFFFFF"
inactiveBackgroundColor: "#F4F6F8"
textFillColorPrimary: "#20242A"
textFillColorSecondary: "#606975"
textFillColorTertiary: "#8A94A3"
textFillColorDisabled: "#5c000000"
textFillColorInverse: "#FFffffff"
accentTextFillColorDisabled: "#5c000000"
textOnAccentFillColorSelectedText: "#FFffffff"
textOnAccentFillColorPrimary: "#FFffffff"
textOnAccentFillColorSecondary: "#b3ffffff"
textOnAccentFillColorDisabled: "#FFffffff"
controlFillColorDefault: "#FFFFFF"
controlFillColorSecondary: "#F1F4F8"
controlFillColorTertiary: "#E7ECF2"
controlFillColorDisabled: "#4df9f9f9"
controlFillColorTransparent: "#00ffffff"
controlFillColorInputActive: "#FFFFFF"
controlStrongFillColorDefault: "#72000000"
controlStrongFillColorDisabled: "#51000000"
controlSolidFillColorDefault: "#FFffffff"
subtleFillColorTransparent: "#00ffffff"
subtleFillColorSecondary: "#09000000"
subtleFillColorTertiary: "#06000000"
subtleFillColorDisabled: "#00ffffff"
controlAltFillColorTransparent: "#00ffffff"
controlAltFillColorSecondary: "#06000000"
controlAltFillColorTertiary: "#0f000000"
controlAltFillColorQuarternary: "#18000000"
controlAltFillColorDisabled: "#00ffffff"
controlOnImageFillColorDefault: "#c9ffffff"
controlOnImageFillColorSecondary: "#FFf3f3f3"
controlOnImageFillColorTertiary: "#FFebebeb"
controlOnImageFillColorDisabled: "#00ffffff"
accentFillColorDisabled: "#37000000"
controlStrokeColorDefault: "#D9DEE7"
controlStrokeColorSecondary: "#C8CFDA"
controlStrokeColorOnAccentDefault: "#14ffffff"
controlStrokeColorOnAccentSecondary: "#66000000"
controlStrokeColorOnAccentTertiary: "#37000000"
controlStrokeColorOnAccentDisabled: "#0f000000"
controlStrokeColorForStrongFillWhenOnImage: "#59ffffff"
cardStrokeColorDefault: "#D9DEE7"
cardStrokeColorDefaultSolid: "#D9DEE7"
controlStrongStrokeColorDefault: "#72000000"
controlStrongStrokeColorDisabled: "#37000000"
surfaceStrokeColorDefault: "#D9DEE7"
surfaceStrokeColorFlyout: "#D9DEE7"
surfaceStrokeColorInverse: "#15ffffff"
dividerStrokeColorDefault: "#E7EAF0"
focusStrokeColorOuter: control.accentColor.defaultBrushFor(false)
focusStrokeColorInner: "#FFFFFF"
cardBackgroundColor: "#FFFFFF"
cardBackgroundFillColorDefault: "#FFFFFF"
cardBackgroundFillColorSecondary: "#F7F9FC"
smokeFillColorDefault: "#4d000000"
layerFillColorDefault: "#80ffffff"
layerFillColorAlt: "#FFffffff"
layerOnAcrylicFillColorDefault: "#40ffffff"
layerOnAccentAcrylicFillColorDefault: "#40ffffff"
layerOnMicaBaseAltFillColorDefault: "#b3ffffff"
layerOnMicaBaseAltFillColorSecondary: "#0a000000"
layerOnMicaBaseAltFillColorTertiary: "#FFf9f9f9"
layerOnMicaBaseAltFillColorTransparent: "#00000000"
solidBackgroundFillColorBase: "#F4F6F8"
solidBackgroundFillColorSecondary: "#F7F9FC"
solidBackgroundFillColorTertiary: "#EEF1F5"
solidBackgroundFillColorQuarternary: "#FFFFFF"
solidBackgroundFillColorTransparent: "#00f3f3f3"
solidBackgroundFillColorBaseAlt: "#E7EAF0"
systemFillColorSuccess: "#168B50"
systemFillColorCaution: "#9D6300"
systemFillColorCritical: "#C43131"
systemFillColorNeutral: "#72000000"
systemFillColorSolidNeutral: "#FF8a8a8a"
systemFillColorAttentionBackground: "#80f6f6f6"
systemFillColorSuccessBackground: Qt.tint(cardBackgroundColor, Colors.withOpacity(systemFillColorSuccess, 0.06))
systemFillColorCautionBackground: Qt.tint(cardBackgroundColor, Colors.withOpacity(systemFillColorCaution, 0.06))
systemFillColorCriticalBackground: Qt.tint(cardBackgroundColor, Colors.withOpacity(systemFillColorCritical, 0.05))
systemFillColorNeutralBackground: "#06000000"
systemFillColorSolidAttentionBackground: "#FFf7f7f7"
systemFillColorSolidNeutralBackground: "#FFf3f3f3"
shadowColor: "#000000"
}
function buttonColor(button,transparentWhenNone = false,isDark = null){
if(isDark === null){
isDark = Theme.dark
}
var res = ofDark(isDark)
if(!button.enabled){
return res.controlFillColorDisabled
}
if(button.pressed){
return res.controlFillColorTertiary
}
if(button.hovered){
return res.controlFillColorSecondary
}
return transparentWhenNone ? res.subtleFillColorTransparent : res.controlFillColorDefault
}
function uncheckedInputColor(button,transparentWhenNone = false,transparentWhenDisabled = false,isDark = null){
if(isDark === null){
isDark = Theme.dark
}
var res = ofDark(isDark)
if(!button.enabled){
if(transparentWhenDisabled){
return res.subtleFillColorTransparent
}
return res.controlAltFillColorDisabled
}
if(button.pressed){
return res.subtleFillColorTertiary
}
if(button.hovered){
return res.subtleFillColorSecondary
}
return transparentWhenNone ? res.subtleFillColorTransparent : res.controlAltFillColorSecondary
}
function checkedInputColor(button,accentColor,isDark = null){
if(isDark === null){
isDark = Theme.dark
}
var res = ofDark(isDark)
if(!button.enabled){
return res.accentFillColorDisabled
}
if(button.pressed){
return accentColor.tertiaryBrushFor(isDark)
}
if(button.hovered){
return accentColor.secondaryBrushFor(isDark)
}
return accentColor.defaultBrushFor(isDark)
}
function of(control){
var accent = ofAccentColor(control.SmoothUI.primaryColor)
return {res:ofDark(control.SmoothUI.dark),accentColor: accent}
}
function ofAccentColor(color){
var accent
var primaryColor
if(color){
primaryColor = color
}else{
primaryColor = Theme.primaryColor
}
if(primaryColor instanceof AccentColor){
accent = color
}else{
var primaryColorStr = String(primaryColor)
switch(primaryColorStr){
case "Colors.yellow":
accent = Colors.yellow
break
case "Colors.orange":
accent = Colors.orange
break
case "Colors.red":
accent = Colors.red
break
case "Colors.magenta":
accent = Colors.magenta
break
case "Colors.purple":
accent = Colors.purple
break
case "Colors.blue":
accent = Colors.blue
break
case "Colors.teal":
accent = Colors.teal
break
case "Colors.green":
accent = Colors.green
break
default:
accent = accent_color.createObject(control,{normal:primaryColorStr})
break
}
}
return accent
}
function ofDark(isDark):ColorResource{
return isDark ? darkResource : lightResource
}
Component{
id: accent_color
AccentColor{}
}
}
