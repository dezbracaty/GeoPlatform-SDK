/*!
\qmltype IconButton
\inqmlmodule SmoothUI.Controls
\brief A button that displays only an icon with label support.
Provides a compact icon button with optional text label,
accent color support, and configurable background color
for icon-only display modes.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
StandardButton {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
horizontalPadding: padding
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
property int radius: control.SmoothUI.radius
property color backgroundColor: {
if(control.forceHighlighted){
return Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
}
if(!control.enabled){
return Theme.buttonColor(control,false,control.SmoothUI.dark)
}
return Theme.uncheckedInputColor(control,true,false,control.SmoothUI.dark)
}
background: FocusItem{
implicitHeight: Theme.iconButtonSize
implicitWidth: Theme.iconButtonSize
radius: control.radius
target: control
Rectangle{
radius: control.radius
anchors.fill: parent
color: control.backgroundColor
}
}
}
