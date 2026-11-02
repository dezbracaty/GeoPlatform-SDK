import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.impl
import SmoothUI.Controls
/*!
\qmltype Statistic
\inqmlmodule SmoothUI.Controls
\brief Displays a statistical value with label and trend
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property real value: 0
property string title: ""
property Component titleItem
property var prefix
property Component prefixItem
property var suffix
property Component suffixItem
property int precision: -1
property string decimalSeparator: "."
property string groupSeparator: ","
property var formatter: null
property font titleFont: Typography.body
property font valueFont: Typography.title
property color titleColor: control.SmoothUI.theme.res.textFillColorSecondary
property color valueColor: control.SmoothUI.theme.res.textFillColorPrimary
property color prefixColor: control.SmoothUI.theme.res.textFillColorSecondary
property color suffixColor: control.SmoothUI.theme.res.textFillColorSecondary
property bool loading: false
property int spacing: 4
property int contentSpacing: 4
readonly property string formattedValue: {
if (control.formatter && typeof control.formatter === "function") {
return control.formatter(control.value)
}
return Tools.formatNumber(control.value, control.precision, control.decimalSeparator, control.groupSeparator)
}
implicitWidth: layout_column.implicitWidth
implicitHeight: layout_column.implicitHeight
Column {
id: layout_column
spacing: control.spacing
width: control.width
Loader {
id: loader_title
width: parent.width
active: control.title !== "" || control.titleItem
sourceComponent: control.titleItem || comp_title
}
Row {
id: row_content
spacing: control.contentSpacing
visible: !control.loading
Loader {
id: loader_prefix
active: (control.prefix !== undefined && control.prefix !== null) || control.prefixItem
sourceComponent: control.prefixItem || comp_prefix
}
Label {
id: label_value
font: control.valueFont
color: control.valueColor
text: control.formattedValue
}
Loader {
id: loader_suffix
active: (control.suffix !== undefined && control.suffix !== null) || control.suffixItem
sourceComponent: control.suffixItem || comp_suffix
}
}
Loader {
id: loader_shimmer
active: control.loading
sourceComponent: comp_shimmer
}
}
Component {
id: comp_title
Label {
font: control.titleFont
color: control.titleColor
text: control.title
}
}
Component {
id: comp_prefix
Label {
font: control.valueFont
color: control.prefixColor
text: control.prefix !== undefined ? String(control.prefix) : ""
}
}
Component {
id: comp_suffix
Label {
font: control.valueFont
color: control.suffixColor
text: control.suffix !== undefined ? String(control.suffix) : ""
}
}
Component {
id: comp_shimmer
Row {
spacing: control.contentSpacing
Item { width: control.title !== "" ? 60 : 0; height: 14 }
Rectangle {
width: 120
height: 30
radius: control.SmoothUI.radius
color: control.SmoothUI.theme.res.controlFillColorDefault
Shimmer {
anchors.fill: parent
baseColor: parent.color
}
}
}
}
}
