import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import QtQuick.Layouts
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype SegmentedButton
\inqmlmodule SmoothUI.Controls
\brief A button within a segmented control group
*/
T.TabButton {
id: control
SmoothUI.iconFamily: FluentIcons.fontLoader.name
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property bool highlighted: false
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
width: implicitWidth
font: Typography.body
SmoothUI.textColor: {
if(control.highlighted){
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
mirrored: control.mirrored
display: control.display
icon: control.icon
text: control.text
font: control.font
color: control.SmoothUI.textColor
iconFamily: control.SmoothUI.iconFamily
}
background: FocusItem{
implicitWidth: 120
implicitHeight: Theme.controlHeight
radius: control.SmoothUI.radius
target: control
ControlBackground {
id: control_background
anchors.fill: parent
radius: control.SmoothUI.radius
target: control
accentColor: control.accentColor
highlighted: control.highlighted
visible: control.checked
}
Rectangle{
radius: control.SmoothUI.radius
anchors{
fill: parent
margins: 2
}
visible: !control.checked
color: {
if(!control.enabled){
return Theme.buttonColor(control,false,control.SmoothUI.dark)
}else{
return Theme.uncheckedInputColor(control,true,false,control.SmoothUI.dark)
}
}
}
}
}
