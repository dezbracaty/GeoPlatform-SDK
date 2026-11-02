/*!
\qmltype IconLabel
\inqmlmodule SmoothUI.Controls
\brief Displays an icon alongside text with configurable layout.
Provides a flexible icon + text label layout supporting
multiple display modes (icon-only, text-only, icon beside text),
mirroring for RTL layouts, and text elision.
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.impl
Item {
id: control
SmoothUI.theme: Theme.of(control)
property int spacing: 0
property bool mirrored: false
property int alignment: Qt.AlignVCenter | Qt.AlignHCenter
property int display: Button.TextBesideIcon
property string text
property alias icon : d.icon
property font font: Typography.body
property string iconFamily: FluentIcons.fontLoader.name
property color color: enabled ? control.SmoothUI.theme.res.textFillColorPrimary : control.SmoothUI.theme.res.textFillColorDisabled
property real topPadding : 0
property real leftPadding : 0
property real rightPadding : 0
property real bottomPadding : 0
property real elideWidth: 0
implicitWidth: Math.ceil(internal.fullContentWidth) + control.leftPadding + control.rightPadding
implicitHeight: loader_content.height
Action{
id: d
icon.width: control.font.pixelSize
icon.height: control.font.pixelSize
icon.color: control.color
}
QtObject {
id: internal
readonly property bool hasIcon: control.icon.source.toString() !== "" || control.icon.name !== ""
readonly property bool iconInLayout: internal.hasIcon && control.display !== Button.TextOnly
readonly property bool textInLayout: control.display !== Button.IconOnly
readonly property real iconWidth: control.icon.width
property real textWidth: 0
readonly property real fullContentWidth: {
if (control.display === Button.IconOnly)
return internal.iconInLayout ? internal.iconWidth : 0
if (control.display === Button.TextOnly)
return internal.textWidth
if (control.display === Button.TextUnderIcon) {
var w = internal.textWidth
if (internal.iconInLayout && internal.iconWidth > w)
w = internal.iconWidth
return w
}
w = internal.textWidth
if (internal.iconInLayout) {
w += internal.iconWidth
if (control.text !== "")
w += control.spacing
}
return w
}
}
TextMetrics {
id: tm_text
text: control.text
font: control.font
elideWidth: Math.max(control.elideWidth, 0) + 1
elide: Text.ElideRight
onAdvanceWidthChanged: internal.textWidth = tm_text.advanceWidth
Component.onCompleted: internal.textWidth = tm_text.advanceWidth
}
AutoLoader{
id: loader_content
anchors{
verticalCenter: (control.alignment & Qt.AlignVCenter) ? control.verticalCenter : undefined
horizontalCenter: (control.alignment & Qt.AlignHCenter) ? control.horizontalCenter : undefined
}
sourceComponent: {
if(display === Button.TextUnderIcon){
if(control.mirrored){
return comp_column_reverse
}
return comp_column
}
return comp_row
}
}
Component{
id: comp_icon
Icon{
color: control.icon.color
source: {
if(control.icon.source.toString()!==""){
return control.icon.source
}
return control.icon.name
}
width: {
if(source === ""){
return 0
}
return control.icon.width
}
height: {
if(source === ""){
return 0
}
return control.icon.height
}
family: control.iconFamily
}
}
Component{
id: comp_row
Item{
width: childrenRect.width + control.leftPadding + control.rightPadding
height: childrenRect.height + control.topPadding + control.bottomPadding
x: control.leftPadding
y: control.topPadding
Row{
layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
spacing: label_text.text === ""  ? 0 : control.spacing
AutoLoader{
sourceComponent: comp_icon
visible: control.display !== Button.TextOnly
anchors.verticalCenter: parent.verticalCenter
}
Label{
id: label_text
text: control.elideWidth > 0 ? tm_text.elidedText : control.text
font: control.font
color: control.color
visible: control.display !== Button.IconOnly
anchors.verticalCenter: parent.verticalCenter
}
}
}
}
Component{
id: comp_column
Item{
width: childrenRect.width + control.leftPadding + control.rightPadding
height: childrenRect.height + control.topPadding + control.bottomPadding
x: control.leftPadding
y: control.topPadding
Column{
spacing: label_text.text === ""  ? 0 : control.spacing
AutoLoader{
sourceComponent: comp_icon
anchors{
horizontalCenter: parent.horizontalCenter
}
}
Label{
id: label_text
text: control.elideWidth > 0 ? tm_text.elidedText : control.text
font: control.font
color: control.color
anchors.horizontalCenter: parent.horizontalCenter
}
}
}
}
Component{
id: comp_column_reverse
Item{
width: childrenRect.width + control.leftPadding + control.rightPadding
height: childrenRect.height + control.topPadding + control.bottomPadding
x: control.leftPadding
y: control.topPadding
Column{
spacing: label_text.text === ""  ? 0 : control.spacing
Label{
id: label_text
text: control.elideWidth > 0 ? tm_text.elidedText : control.text
font: control.font
color: control.color
anchors{
horizontalCenter: parent.horizontalCenter
}
}
AutoLoader{
sourceComponent: comp_icon
anchors{
horizontalCenter: parent.horizontalCenter
}
}
}
}
}
}
