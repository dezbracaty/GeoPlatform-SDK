import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/**
* RibbonButton - Ribbon 工具栏按钮
*
* 支持两种尺寸：
* - large: 大图标 + 文字（垂直排列）
* - small: 小图标 + 文字（水平排列）
*/
Control {
id: control
SmoothUI.theme: Theme.of(control)
property var itemData: ({})
property string sizeMode: itemData.size || "small"
property int largeIconSize: 24
property int smallIconSize: 14
property bool hasMenu: itemData.items !== undefined && itemData.items.length > 0
signal clicked()
signal menuItemClicked(var item)
implicitWidth: sizeMode === "large" ? 48 : Math.max(70, contentRow.implicitWidth + 8)
implicitHeight: sizeMode === "large" ? 66 : 20
property bool isHovered: mouseArea.containsMouse
property bool isPressed: mouseArea.pressed
background: Rectangle {
radius: 3
color: {
if (control.isPressed) {
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if (control.isHovered) {
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return "transparent"
}
Behavior on color {
ColorAnimation { duration: Theme.fastAnimationDuration }
}
}
contentItem: Item {
ColumnLayout {
anchors.fill: parent
anchors.margins: 2
spacing: 2
visible: control.sizeMode === "large"
Item { Layout.fillHeight: true }
Icon {
Layout.alignment: Qt.AlignHCenter
width: control.largeIconSize
height: control.largeIconSize
source: control.itemData.iconSource ? FluentIcons["graph_" + control.itemData.iconSource] || FluentIcons.graph_Placeholder : FluentIcons.graph_Placeholder
color: control.SmoothUI.theme.res.textFillColorPrimary
}
RowLayout {
Layout.alignment: Qt.AlignHCenter
spacing: 2
Label {
text: control.itemData.text || ""
font.pixelSize: 11
color: control.SmoothUI.theme.res.textFillColorPrimary
}
Icon {
visible: control.hasMenu
width: 8
height: 8
source: FluentIcons.graph_ChevronDown
color: control.SmoothUI.theme.res.textFillColorSecondary
}
}
Item { Layout.fillHeight: true }
}
RowLayout {
id: contentRow
anchors.fill: parent
anchors.leftMargin: 4
anchors.rightMargin: 4
spacing: 4
visible: control.sizeMode === "small"
Icon {
width: control.smallIconSize
height: control.smallIconSize
source: control.itemData.iconSource ? FluentIcons["graph_" + control.itemData.iconSource] || FluentIcons.graph_Placeholder : FluentIcons.graph_Placeholder
color: control.SmoothUI.theme.res.textFillColorPrimary
}
Label {
text: control.itemData.text || ""
font.pixelSize: 11
color: control.SmoothUI.theme.res.textFillColorPrimary
Layout.fillWidth: true
}
Icon {
visible: control.hasMenu
width: 8
height: 8
source: FluentIcons.graph_ChevronDown
color: control.SmoothUI.theme.res.textFillColorSecondary
}
}
}
MouseArea {
id: mouseArea
anchors.fill: parent
hoverEnabled: true
onClicked: {
if (control.hasMenu) {
dropdownMenu.open()
} else {
control.clicked()
if (control.itemData.actionCode) {
MenuData.onMenuActionTriggered(control.itemData)
}
}
}
}
DropDownPopup {
id: dropdownMenu
y: control.height
Repeater {
model: control.itemData.items || []
delegate: NavigationMenuItem {
required property var modelData
required property int index
text: modelData.text || ""
icon.name: modelData.iconSource ? FluentIcons["graph_" + modelData.iconSource] || FluentIcons.graph_Placeholder : ""
enabled: modelData.enabled !== false
onClicked: {
control.menuItemClicked(modelData)
if (modelData.actionCode) {
MenuData.onMenuActionTriggered(modelData)
}
dropdownMenu.close()
}
}
}
}
}
