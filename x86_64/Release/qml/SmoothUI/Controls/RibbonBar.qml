import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/**
* RibbonBar - Ribbon 工具栏
*
* 类似 AutoCAD 的 Ribbon 界面，包含：
* - Tab 栏：切换不同功能组
* - Panel 区：显示当前 Tab 的工具面板
*
* 使用方式：
* RibbonBar {
*     ribbonConfig: "Ribbon"  // 从 MenuData 加载配置
* }
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property string ribbonConfig: "Ribbon"
property int currentTabIndex: 0
property var tabs: []
property var currentPanels: []
property int tabBarHeight: 28
property int panelAreaHeight: 92
implicitWidth: 800
implicitHeight: tabBarHeight + panelAreaHeight + 1
Component.onCompleted: {
loadRibbonConfig()
}
function loadRibbonConfig() {
var ribbonGroup = MenuData.getGroup(ribbonConfig)
if (ribbonGroup && ribbonGroup.tabs) {
tabs = ribbonGroup.tabs
if (tabs.length > 0) {
loadTabPanels(0)
}
} else {
// 使用默认配置
console.log("RibbonBar: Using default tabs configuration")
tabs = [
{ id: "RibbonHome", title: "首页", icon: "Home" },
{ id: "RibbonInsert", title: "插入", icon: "Add" },
{ id: "RibbonAnnotate", title: "标注", icon: "Font" },
{ id: "RibbonView", title: "视图", icon: "View" }
]
loadTabPanels(0)
}
}
function loadTabPanels(index) {
if (index < 0 || index >= tabs.length) return
currentTabIndex = index
var tabId = tabs[index].id
var tabGroup = MenuData.getGroup(tabId)
if (tabGroup && tabGroup.panels) {
currentPanels = tabGroup.panels
} else {
currentPanels = getDefaultPanels(tabId)
}
}
function getDefaultPanels(tabId) {
var defaultPanels = {
"RibbonHome": [
{
title: "绘图",
items: [
{ text: "直线", iconSource: "Pencil", size: "large", actionCode: "draw.line" },
{ text: "多段线", iconSource: "Draw", size: "large", actionCode: "draw.polyline" },
{ text: "圆", iconSource: "RadioBtnOn", size: "small", actionCode: "draw.circle" },
{ text: "圆弧", iconSource: "Dial5", size: "small", actionCode: "draw.arc" },
{ text: "矩形", iconSource: "Checkbox", size: "small", actionCode: "draw.rectangle" }
]
},
{
title: "修改",
items: [
{ text: "移动", iconSource: "Move", size: "large", actionCode: "modify.move" },
{ text: "复制", iconSource: "Copy", size: "large", actionCode: "modify.copy" },
{ text: "旋转", iconSource: "Rotate", size: "small", actionCode: "modify.rotate" },
{ text: "镜像", iconSource: "Switch", size: "small", actionCode: "modify.mirror" },
{ text: "缩放", iconSource: "ZoomIn", size: "small", actionCode: "modify.scale" },
{ text: "修剪", iconSource: "Trim", size: "small", actionCode: "modify.trim" }
]
},
{
title: "标注",
items: [
{ text: "线性", iconSource: "Ruler", size: "large", actionCode: "annotate.linear" },
{ text: "文字", iconSource: "Font", size: "large", actionCode: "annotate.text" },
{ text: "对齐", iconSource: "AlignLeft", size: "small", actionCode: "annotate.aligned" },
{ text: "角度", iconSource: "Dial1", size: "small", actionCode: "annotate.angular" },
{ text: "半径", iconSource: "CircleRing", size: "small", actionCode: "annotate.radius" }
]
},
{
title: "图层",
items: [
{ text: "图层属性", iconSource: "Library", size: "large", actionCode: "layer.properties" },
{ text: "新建", iconSource: "Add", size: "small", actionCode: "layer.new" },
{ text: "删除", iconSource: "Delete", size: "small", actionCode: "layer.delete" },
{ text: "冻结", iconSource: "Lock", size: "small", actionCode: "layer.freeze" }
]
},
{
title: "块",
items: [
{ text: "创建", iconSource: "Add", size: "large", actionCode: "block.create" },
{ text: "插入", iconSource: "Download", size: "large", actionCode: "block.insert" },
{ text: "编辑", iconSource: "Edit", size: "small", actionCode: "block.edit" }
]
},
{
title: "工具",
items: [
{ text: "测量", iconSource: "Ruler", size: "large", actionCode: "tools.measure" },
{ text: "计算器", iconSource: "Calculator", size: "small", actionCode: "tools.calculator" },
{ text: "查询", iconSource: "Search", size: "small", actionCode: "tools.inquiry" }
]
}
],
"RibbonInsert": [
{
title: "块",
items: [
{ text: "插入", iconSource: "Download", size: "large", actionCode: "insert.block" },
{ text: "定义属性", iconSource: "Tag", size: "small", actionCode: "insert.defineAttribute" }
]
},
{
title: "参照",
items: [
{ text: "附着", iconSource: "Attach", size: "large", actionCode: "insert.attach" },
{ text: "裁剪", iconSource: "Crop", size: "small", actionCode: "insert.clip" }
]
},
{
title: "导入",
items: [
{ text: "PDF", iconSource: "PDF", size: "large", actionCode: "import.pdf" },
{ text: "图像", iconSource: "Photo", size: "small", actionCode: "import.image" }
]
}
],
"RibbonAnnotate": [
{
title: "标注",
items: [
{ text: "线性", iconSource: "Ruler", size: "large", actionCode: "dim.linear" },
{ text: "对齐", iconSource: "AlignLeft", size: "large", actionCode: "dim.aligned" },
{ text: "角度", iconSource: "Dial1", size: "small", actionCode: "dim.angular" },
{ text: "半径", iconSource: "CircleRing", size: "small", actionCode: "dim.radius" },
{ text: "直径", iconSource: "RadioBtnOn", size: "small", actionCode: "dim.diameter" }
]
},
{
title: "文字",
items: [
{ text: "多行文字", iconSource: "Font", size: "large", actionCode: "text.mtext" },
{ text: "单行文字", iconSource: "Bold", size: "small", actionCode: "text.dtext" },
{ text: "文字样式", iconSource: "FontSize", size: "small", actionCode: "text.style" }
]
},
{
title: "表格",
items: [
{ text: "表格", iconSource: "GridView", size: "large", actionCode: "table.insert" },
{ text: "表格样式", iconSource: "List", size: "small", actionCode: "table.style" }
]
}
],
"RibbonView": [
{
title: "视图",
items: [
{ text: "平移", iconSource: "PanMode", size: "large", actionCode: "view.pan" },
{ text: "缩放", iconSource: "ZoomIn", size: "large", actionCode: "view.zoom" },
{ text: "全部", iconSource: "FitPage", size: "small", actionCode: "view.zoomAll" },
{ text: "窗口", iconSource: "SelectAll", size: "small", actionCode: "view.zoomWindow" }
]
},
{
title: "外观",
items: [
{ text: "二维线框", iconSource: "ViewAll", size: "large", actionCode: "visual.2dwireframe" },
{ text: "着色", iconSource: "Color", size: "small", actionCode: "visual.shaded" },
{ text: "真实", iconSource: "Lightbulb", size: "small", actionCode: "visual.realistic" }
]
},
{
title: "坐标",
items: [
{ text: "UCS", iconSource: "Globe", size: "large", actionCode: "ucs.manage" },
{ text: "世界", iconSource: "World", size: "small", actionCode: "ucs.world" }
]
}
]
}
return defaultPanels[tabId] || []
}
ColumnLayout {
anchors.fill: parent
spacing: 0
Rectangle {
Layout.fillWidth: true
Layout.preferredHeight: control.tabBarHeight
color: control.SmoothUI.theme.res.solidBackgroundFillColorTertiary
RowLayout {
anchors.fill: parent
anchors.leftMargin: 8
anchors.rightMargin: 8
spacing: 0
Repeater {
model: control.tabs
delegate: Item {
implicitWidth: tabLabel.implicitWidth + 24
implicitHeight: control.tabBarHeight
property bool isSelected: control.currentTabIndex === index
property bool isHovered: tabMouseArea.containsMouse
Rectangle {
anchors.fill: parent
anchors.topMargin: 2
radius: control.SmoothUI.radius
color: {
if (isSelected) {
return control.SmoothUI.theme.res.layerFillColorDefault
}
if (isHovered) {
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return "transparent"
}
Rectangle {
visible: isSelected
anchors.bottom: parent.bottom
anchors.horizontalCenter: parent.horizontalCenter
width: parent.width * 0.6
height: 3
radius: 1.5
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
}
Label {
id: tabLabel
anchors.centerIn: parent
text: modelData.title || ""
font: Typography.body
color: isSelected
? control.SmoothUI.theme.res.textFillColorPrimary
: control.SmoothUI.theme.res.textFillColorSecondary
}
MouseArea {
id: tabMouseArea
anchors.fill: parent
hoverEnabled: true
onClicked: control.loadTabPanels(index)
}
}
}
Item { Layout.fillWidth: true }
}
}
Rectangle {
Layout.fillWidth: true
Layout.preferredHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
Rectangle {
Layout.fillWidth: true
Layout.preferredHeight: control.panelAreaHeight
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
ScrollView {
anchors.fill: parent
anchors.leftMargin: 4
anchors.rightMargin: 4
contentWidth: panelRow.width
clip: true
ScrollBar.horizontal.policy: ScrollBar.AsNeeded
ScrollBar.vertical.policy: ScrollBar.AlwaysOff
RowLayout {
id: panelRow
height: parent.height
spacing: 0
Repeater {
model: control.currentPanels
RibbonPanel {
panelData: modelData
Layout.fillHeight: true
}
}
}
}
}
}
}
