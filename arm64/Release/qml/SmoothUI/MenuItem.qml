/*!
\qmltype MenuItem
\inqmlmodule SmoothUI
\brief A Fluent-styled menu item with icon, checkable indicator, and submenu arrow.
Wraps \l T.MenuItem with SmoothUI theme integration.
Supports checkable items with checkmark indicator and
submenu items with chevron arrow.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.MenuItem {
property var subMenuModel
property var view
id: control
SmoothUI.iconFamily: FluentIcons.fontLoader.name
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property var localIconSource: ""
property TMenuItem tmenu : null
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
padding: Theme.controlPadding
leftPadding: Theme.controlHorizontalPadding
rightPadding: Theme.controlHorizontalPadding
spacing: Theme.contentSpacing
icon.width: 16
icon.height: 16
icon.color: control.SmoothUI.textColor
icon.source: localIconSource
font: Typography.body
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
readonly property real arrowPadding: control.subMenu && control.arrow ? control.arrow.width + control.spacing : 0
readonly property real indicatorPadding: control.checkable && control.indicator ? control.indicator.width + control.spacing : 0
leftPadding: !control.mirrored ? indicatorPadding : arrowPadding
rightPadding: control.mirrored ? indicatorPadding : arrowPadding
spacing: control.spacing
mirrored: control.mirrored
display: control.display
alignment: Qt.AlignLeft | Qt.AlignVCenter
icon: control.icon
text: control.text
font: control.font
color: control.SmoothUI.textColor
iconFamily: control.SmoothUI.iconFamily
}
indicator: Icon {
x: control.mirrored ? control.width - width - control.rightPadding : control.leftPadding
y: control.topPadding + (control.availableHeight - height) / 2
visible: control.checkable
source: FluentIcons.graph_CheckMark
color: control.checked ? control.accentColor.defaultBrushFor(control.SmoothUI.dark) : control.SmoothUI.textColor
width: 16
height: 16
}
arrow: Icon {
x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
y: control.topPadding + (control.availableHeight - height) / 2
visible: control.subMenu
source: control.subMenu ? FluentIcons.graph_ChevronRight : ""
color: control.SmoothUI.textColor
width: 16
height: 16
}
background: Item{
implicitWidth: 100
implicitHeight: Theme.controlHeight
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
onTriggered: () => {
if(tmenu)
tmenu.onTriggered();
}
}
