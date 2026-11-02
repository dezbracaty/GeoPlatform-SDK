/*!
\qmltype TabButton
\inqmlmodule SmoothUI
\brief A Fluent-styled tab button with icon and label.
Wraps \l T.TabButton with SmoothUI theme integration.
Displays icon and text with state-dependent color
for checked/hovered/pressed/disabled interactions.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import QtQuick.Layouts
import SmoothUI.Controls
import SmoothUI.impl
T.TabButton {
id: control
SmoothUI.iconFamily: FluentIcons.fontLoader.name
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
SmoothUI.textColor: {
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textFillColorSecondary
}
if(control.hovered || control.checked){
return control.SmoothUI.theme.res.textFillColorPrimary
}
return control.SmoothUI.theme.res.textFillColorTertiary
}
spacing: Theme.contentSpacing
focusPolicy: Qt.TabFocus
width: implicitWidth
font: Typography.bodyStrong
icon.color: control.SmoothUI.textColor
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
radius: control.SmoothUI.radius
target: control
}
}
