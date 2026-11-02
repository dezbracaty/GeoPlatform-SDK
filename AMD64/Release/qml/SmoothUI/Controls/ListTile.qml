/*!
\qmltype ListTile
\inqmlmodule SmoothUI.Controls
\brief A list item tile with leading, content, and trailing areas.
Extends ItemDelegate to provide a structured list item layout
with optional leading icon/image, content text, and trailing
action areas.
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.impl
T.ItemDelegate {
id: control
SmoothUI.theme: Theme.of(control)
property Component leading
property Component trailing
property Component container: comp_container
property alias leadingItem: loader_leading.item
property alias trailingItem: loader_trailing.item
property alias containerItem: loader_container.item
property int radius: control.SmoothUI.radius
property color textColor: {
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
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding,
implicitIndicatorHeight + topPadding + bottomPadding)
leftPadding: Theme.controlHorizontalPadding
rightPadding: Theme.controlHorizontalPadding
spacing: Theme.contentSpacing
font: Typography.body
focusPolicy: Qt.TabFocus
Component{
id: comp_container
Label{
text: control.text
font: control.font
color: control.textColor
elide: Label.ElideRight
}
}
contentItem: RowLayout{
spacing: 0
AutoLoader{
id: loader_leading
sourceComponent: leading
}
Item{
implicitHeight: 1
implicitWidth: visible ? control.spacing : 0
visible: loader_leading.status === Loader.Ready
}
AutoLoader{
id: loader_container
sourceComponent: control.container
Layout.fillWidth: true
}
Item{
implicitHeight: 1
implicitWidth: visible ? control.spacing : 0
visible: loader_trailing.status === Loader.Ready
}
AutoLoader{
id: loader_trailing
sourceComponent: trailing
}
}
background: FocusItem{
radius: control.radius
implicitHeight: Theme.controlHeight
implicitWidth: 100
target: control
Rectangle{
radius: control.radius
anchors.fill: parent
color: control.highlighted ? control.SmoothUI.theme.res.subtleFillColorSecondary : Theme.uncheckedInputColor(control,true,true,control.SmoothUI.dark)
}
}
}
