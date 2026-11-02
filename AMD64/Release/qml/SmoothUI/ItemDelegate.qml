/*!
\qmltype ItemDelegate
\inqmlmodule SmoothUI
\brief A Fluent-styled item delegate with icon and text support.
Wraps \l T.ItemDelegate with SmoothUI theme integration.
Provides icon-label content display with highlight and
interactive states.
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ItemDelegate {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.iconFamily: FluentIcons.fontLoader.name
property bool iconMirrored: control.mirrored
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
padding: Theme.controlPadding
horizontalPadding: Theme.controlHorizontalPadding
spacing: Theme.contentSpacing
icon.width: 16
icon.height: 16
icon.color: control.SmoothUI.textColor
focusPolicy: Qt.TabFocus
font: Typography.body
SmoothUI.textColor: {
if(control.highlighted){
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textFillColorSecondary
}
if(control.hovered){
return control.SmoothUI.theme.res.textFillColorPrimary
}
return control.SmoothUI.theme.res.textFillColorPrimary
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
alignment: Qt.AlignLeft | Qt.AlignVCenter
icon: control.icon
text: control.text
font: control.font
color: control.SmoothUI.textColor
iconFamily: control.SmoothUI.iconFamily
}
background: FocusItem{
radius: control.SmoothUI.radius
implicitHeight: Theme.controlHeight
implicitWidth: Theme.controlHeight
target: control
Rectangle{
radius: control.SmoothUI.radius
anchors.fill: parent
color: control.highlighted ? control.SmoothUI.theme.res.subtleFillColorSecondary : Theme.uncheckedInputColor(control,true,true,control.SmoothUI.dark)
}
}
}
