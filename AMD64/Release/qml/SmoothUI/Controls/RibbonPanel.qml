import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/**
* RibbonPanel - Ribbon 工具面板
*
* 包含一组相关工具按钮，底部显示面板标题
* 自动将按钮按大小分组布局
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var panelData: ({})
property string title: panelData.title || ""
property var items: panelData.items || []
property int largeButtonHeight: 66
property int smallButtonHeight: 20
property int panelSpacing: 2
property int titleHeight: 18
property int contentHeight: largeButtonHeight
implicitWidth: contentRow.implicitWidth + 16
implicitHeight: contentHeight + titleHeight + 6
property var largeItems: {
var result = []
for (var i = 0; i < items.length; i++) {
if (items[i].size === "large") {
result.push(items[i])
}
}
return result
}
property var smallItems: {
var result = []
for (var i = 0; i < items.length; i++) {
if (items[i].size !== "large") {
result.push(items[i])
}
}
return result
}
Column {
anchors.fill: parent
anchors.leftMargin: 6
anchors.rightMargin: 6
anchors.topMargin: 2
anchors.bottomMargin: 2
spacing: 0
Row {
id: contentRow
height: control.contentHeight
spacing: control.panelSpacing
Repeater {
model: control.largeItems
RibbonButton {
itemData: modelData
sizeMode: "large"
height: control.contentHeight
anchors.top: parent.top
}
}
Column {
id: smallButtonColumn
visible: control.smallItems.length > 0
height: control.contentHeight
spacing: 2
property int columnCount: Math.ceil(control.smallItems.length / 3)
Row {
spacing: 2
Repeater {
model: {
var result = []
for (var i = 0; i < control.smallItems.length; i += 3) {
if (i < control.smallItems.length) {
result.push(control.smallItems[i])
}
}
return result
}
RibbonButton {
itemData: modelData
sizeMode: "small"
height: control.smallButtonHeight
}
}
}
Row {
spacing: 2
Repeater {
model: {
var result = []
for (var i = 1; i < control.smallItems.length; i += 3) {
if (i < control.smallItems.length) {
result.push(control.smallItems[i])
}
}
return result
}
RibbonButton {
itemData: modelData
sizeMode: "small"
height: control.smallButtonHeight
}
}
}
Row {
spacing: 2
Repeater {
model: {
var result = []
for (var i = 2; i < control.smallItems.length; i += 3) {
if (i < control.smallItems.length) {
result.push(control.smallItems[i])
}
}
return result
}
RibbonButton {
itemData: modelData
sizeMode: "small"
height: control.smallButtonHeight
}
}
}
}
}
Item {
width: parent.width
height: control.titleHeight
Label {
anchors.centerIn: parent
text: control.title
font: Typography.caption
color: control.SmoothUI.theme.res.textFillColorSecondary
}
}
}
Rectangle {
anchors.right: parent.right
anchors.top: parent.top
anchors.bottom: parent.bottom
anchors.topMargin: 8
anchors.bottomMargin: 8
width: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
