/*!
\qmltype MenuBarItem
\inqmlmodule SmoothUI
\brief A Fluent-styled menu bar item with icon and label.
Wraps \l T.MenuBarItem with SmoothUI theme integration.
Displays an icon and centered text with hover/press state backgrounds.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.MenuBarItem {
id: control
SmoothUI.iconFamily: FluentIcons.fontLoader.name
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
spacing: Theme.contentSpacing
padding: Theme.controlPadding
horizontalPadding: Theme.controlHorizontalPadding
icon.width: 16
icon.height: 16
icon.color: control.SmoothUI.textColor
font: Typography.body
icon.source: {
// console.log("MenuBarItem - menu:", control.menu)
if (control.menu) {
// console.log("MenuBarItem - topLevelDisplayMode:", control.menu.topLevelDisplayMode)
if (control.menu.topLevelIconSource) {
var iconSource = FluentIcons[control.menu.topLevelIconSource]
return iconSource || ""
}
}
return ""
}
display: {
if (control.menu && control.menu.topLevelDisplayMode) {
var displayMode = control.menu.topLevelDisplayMode
if (displayMode === "IconOnly") {
return Button.IconOnly
} else if (displayMode === "TextBesideIcon") {
return Button.TextBesideIcon
}
}
return Button.TextOnly
}
SmoothUI.textColor: {
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textFillColorSecondary
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
contentItem: IconLabel {
spacing: control.spacing
mirrored: control.mirrored
display: control.display
alignment: Qt.AlignHCenter | Qt.AlignVCenter
icon: control.icon
text: control.text
font: control.font
color: control.SmoothUI.textColor
iconFamily: control.SmoothUI.iconFamily
}
background: Item{
implicitHeight: Theme.controlHeight
implicitWidth: Theme.controlHeight
x: 1
y: 1
width: control.width - 2
height: control.height - 2
Rectangle{
radius: control.SmoothUI.radius
anchors.fill: parent
anchors.margins: 3
color: control.highlighted ? control.SmoothUI.theme.res.subtleFillColorSecondary : Theme.uncheckedInputColor(control,true,true,control.SmoothUI.dark)
}
}
}
