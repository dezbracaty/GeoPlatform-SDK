/*!
\qmltype NavigationView
\inqmlmodule SmoothUI.Controls
\brief A comprehensive navigation view with sidebar and top bar.
Provides a full-featured navigation container supporting multiple
display modes (Auto, Open, Compact, Minimal, Top), configurable
sidebar width, logo, auto-suggest box, and page routing.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.impl
Rectangle {
id: control
SmoothUI.theme: Theme.of(control)
/// \value NavigationViewType.Auto Automatically choose based on width
/// \value NavigationViewType.Compact Compact icon-only sidebar
/// \value NavigationViewType.Top Top navigation bar
property int displayMode: NavigationViewType.Auto
property int sideBarWidth: 320
property int appBarHeight: 48
property int titleBarTopMargin: 0
property int sideItemHeight: 40
property int topBarHeight: 50
property string title
property var logo
property list<QtObject> items
property list<QtObject> footerItems
property Component appBar: comp_appbar
property Component logoDelegate: comp_logo
property Component sideItemDelegate: comp_side_item_delegate
property Item autoSuggestBox
property Component autoSuggestBoxReplacement: comp_search_icon
property Component leading
property Component trailing
property Component menuBar  // 标题栏菜单栏组件，自动跟在标题后面，使用布局定位
property alias leadingItem: loader_leading.item
property alias trailingItem: loader_trailing.item
property bool sideBarShadow: true
property PageRouter router
property int tileFocusPolicy: Qt.TabFocus
property font tileFont: Typography.body
property alias routerView: stackview_panne
property int framePadding: 0
readonly property var goBackButton: layout_appbar.item?.goBackButton ?? null
readonly property var menuButton: layout_appbar.item?.menuButton ?? null
readonly property var sideBarView: d.isTop ? listview_navi_top : listview_navi
readonly property var sideBarFooterView: d.isTop ? listview_navi_top_footer : listview_navi_footer
function guideState() {
return { pane: d.sideMenuVisible, menu: menu_pane_items.visible,
menuData: d.menuDatas.slice(0), menuParent: menu_pane_items.parent,
menuX: menu_pane_items.x, menuY: menu_pane_items.y,
scrollY: navigationScroll.contentY, topX: listview_navi_top.contentX,
footerX: listview_navi_top_footer.contentX }
}
function beginGuide() {
var state = guideState()
menu_pane_items.close()
d.sideMenuVisible = false
return state
}
function restoreGuideState(state) {
menu_pane_items.close()
d.sideMenuVisible = state.pane
d.menuDatas = state.menuData
navigationScroll.contentY = state.scrollY
listview_navi_top.contentX = state.topX
listview_navi_top_footer.contentX = state.footerX
if (state.menu) {
menu_pane_items.parent = state.menuParent
menu_pane_items.x = state.menuX
menu_pane_items.y = state.menuY
menu_pane_items.open()
}
}
function guideSummary() {
return { pane: d.sideMenuVisible, menu: menu_pane_items.visible,
displayMode: displayMode, path: routerView.currentItem ? routerView.currentItem.path : "",
scrollY: navigationScroll.contentY, topX: listview_navi_top.contentX,
footerX: listview_navi_top_footer.contentX }
}
readonly property bool guideNavigationReady: d.isTop
? layout_topbar.visible && layout_topbar.width > 0 && layout_topbar.height >= topBarHeight - 1
: layout_sidebar.visible && layout_sidebar.width >= sideBarWidth - 1
function prepareGuideNavigation() {
if (!d.isTop) {
d.sideMenuVisible = true
navigationScroll.contentY = 0
}
}
/**
* AppBar 背景配置属性
*
* 动态绑定到 AppBarBackground singleton，当页面切换时自动更新。
*
* 页面使用方式：
* 在页面中声明 appBarBackground 属性，NavigationView 会自动检测并应用：
*
* ContentPage {
*     property var appBarBackground: ({
*         type: "gradient",
*         colors: ["#667eea", "#764ba2"],
*         direction: "vertical"
*     })
* }
*/
property var appBarBackground: AppBarBackground.getConfig()
/**
* SideBar 背景配置属性
*
* 动态绑定到 SideBarBackground singleton，当页面切换时自动更新。
*
* 页面使用方式：
* 在页面中声明 sideBarBackground 属性，NavigationView 会自动检测并应用：
*
* ContentPage {
*     property var sideBarBackground: ({
*         type: "gradient",
*         colors: ["#1E3A6E", "#2B579A"],
*         direction: "vertical"
*     })
* }
*
* 如果页面不声明 sideBarBackground，则使用主题默认背景。
*/
property var sideBarBackground: SideBarBackground.getConfig()
/**
* SideBar 文字样式配置属性
*
* 动态绑定到 SideBarTextStyle singleton，当页面切换时自动更新。
*
* 页面使用方式：
* 在页面中声明 sideBarTextStyle 属性，NavigationView 会自动检测并应用：
*
* ContentPage {
*     property var sideBarTextStyle: ({
*         normalColor: "#333333",
*         selectedColor: "#0066CC",
*         disabledColor: "#999999"
*     })
* }
*
* 如果页面不声明 sideBarTextStyle，则使用主题默认颜色。
*/
property var sideBarTextStyle: SideBarTextStyle.getConfig()
signal tap(var item)
signal rightTap(var item)
signal sourceItemsChanged(var sourceItems)
color: Colors.transparent
Component.onCompleted: {
AppBarBackground.resetToDefault()
control.appBarBackground = AppBarBackground.getConfig()
SideBarBackground.resetToDefault()
control.sideBarBackground = SideBarBackground.getConfig()
SideBarTextStyle.resetToDefault()
control.sideBarTextStyle = SideBarTextStyle.getConfig()
d.displayMode = Qt.binding(() => {
if(displayMode !== NavigationViewType.Auto){
return displayMode
}
if(width <= 640){
return NavigationViewType.Minimal
}else if(width >= 1008){
return NavigationViewType.Open
}else{
return NavigationViewType.Compact
}
})
d.items = Qt.binding(() => {
const stack = []
for(var i=0;i<items.length;i++){
const item = items[i]
stack.push(item)
}
stack.reverse()
const result = []
let index = 0
while (stack.length > 0) {
const current = stack.pop()
current.__index = index
result.push(current)
index++
if (current instanceof PaneItemExpander) {
const children = []
for(let j=0;j<current.children.length;j++){
current.children[j].__parent = current
children.push(current.children[j])
}
children.reverse()
for(let k=0;k<children.length;k++){
stack.push(children[k])
}
}
}
for(let i=0;i<footerItems.length;i++){
const footerItem = footerItems[i]
footerItem.__footer = true
footerItem.__index = index
result.push(footerItem)
index++
}
return result
})
d.topItems = Qt.binding(() => {
const result = []
for(let i=0;i<items.length;i++){
const item = items[i]
if(item.visible !== true){
continue
}
result.push(item)
}
for(let i=0;i<footerItems.length;i++){
const footerItem = footerItems[i]
if(footerItem.visible !== true){
continue
}
result.push(footerItem)
}
return result
})
menu_pane_items.removeItem(menu_pane_items.itemAt(0))
}
Component{
id: comp_logo
Image{
width: control.logo ? 18 : 0
height: width
source: control.logo ? control.logo : ""
}
}
Component{
id: comp_search_icon
Icon{
source: FluentIcons.graph_Search
width: 18
height: 18
}
}
Component{
id: comp_side_item_delegate
Label{
text: model.title
elide: Label.ElideRight
font: control.tileFont
color: defaultTextColor
}
}
Component{
id: comp_appbar
Item{
readonly property alias goBackButton: button_back
readonly property alias menuButton: button_menu
Rectangle {
anchors.fill: parent
visible: !appBarBackground
color: control.SmoothUI.theme.res.cardBackgroundColor
z: 0
}
Rectangle {
id: appbar_background_solid
anchors.fill: parent
visible: appBarBackground && appBarBackground.type === "color"
color: appBarBackground && appBarBackground.color ? appBarBackground.color : control.SmoothUI.theme.res.cardBackgroundColor
z: 0
}
Loader {
id: appbar_gradient_loader
anchors.fill: parent
z: 0
active: appBarBackground && appBarBackground.type === "gradient" && appBarBackground.colors && appBarBackground.colors.length === 2
sourceComponent: {
if (!appBarBackground || appBarBackground.type !== "gradient") return null
if (appBarBackground.direction === "horizontal") {
return appbarGradientHorizontalComponent
}
return appbarGradientVerticalComponent
}
property var gradientColors: appBarBackground ? (appBarBackground.colors || ["#2B579A", "#1E3A6E"]) : ["#2B579A", "#1E3A6E"]
}
Component {
id: appbarGradientVerticalComponent
Rectangle {
gradient: Gradient {
orientation: Gradient.Vertical
GradientStop { position: 0.0; color: appbar_gradient_loader.gradientColors[0] || "#2B579A" }
GradientStop { position: 1.0; color: appbar_gradient_loader.gradientColors[1] || "#1E3A6E" }
}
}
}
Component {
id: appbarGradientHorizontalComponent
Rectangle {
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: appbar_gradient_loader.gradientColors[0] || "#2B579A" }
GradientStop { position: 1.0; color: appbar_gradient_loader.gradientColors[1] || "#1E3A6E" }
}
}
}
Loader {
id: appbar_multi_gradient_loader
anchors.fill: parent
z: 0
active: appBarBackground && appBarBackground.type === "gradient" && appBarBackground.colors && appBarBackground.colors.length > 2
sourceComponent: {
if (!appBarBackground || appBarBackground.type !== "gradient" || !appBarBackground.colors) return null
if (appBarBackground.colors.length === 3) {
return appBarBackground.direction === "horizontal" ? appbarThreeStopHorizontalComponent : appbarThreeStopVerticalComponent
} else if (appBarBackground.colors.length >= 4) {
return appBarBackground.direction === "horizontal" ? appbarFourStopHorizontalComponent : appbarFourStopVerticalComponent
}
return null
}
property var gradientColors: appBarBackground ? appBarBackground.colors : []
}
Component {
id: appbarThreeStopVerticalComponent
Rectangle {
gradient: Gradient {
orientation: Gradient.Vertical
GradientStop { position: 0.0; color: appbar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.5; color: appbar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 1.0; color: appbar_multi_gradient_loader.gradientColors[2] }
}
}
}
Component {
id: appbarThreeStopHorizontalComponent
Rectangle {
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: appbar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.5; color: appbar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 1.0; color: appbar_multi_gradient_loader.gradientColors[2] }
}
}
}
Component {
id: appbarFourStopVerticalComponent
Rectangle {
gradient: Gradient {
orientation: Gradient.Vertical
GradientStop { position: 0.0; color: appbar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.33; color: appbar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 0.66; color: appbar_multi_gradient_loader.gradientColors[2] }
GradientStop { position: 1.0; color: appbar_multi_gradient_loader.gradientColors[3] }
}
}
}
Component {
id: appbarFourStopHorizontalComponent
Rectangle {
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: appbar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.33; color: appbar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 0.66; color: appbar_multi_gradient_loader.gradientColors[2] }
GradientStop { position: 1.0; color: appbar_multi_gradient_loader.gradientColors[3] }
}
}
}
RowLayout{
spacing: 0
height: Math.min(48, control.appBarHeight)
anchors{
left: parent.left
leftMargin: 4
top: parent.top
topMargin: control.titleBarTopMargin
}
IconButton{
id: button_back
Layout.alignment: Qt.AlignVCenter
icon.width: 12
icon.height: 12
implicitWidth: 40
implicitHeight: 36
enabled: stackview_panne.depth > 1
onClicked: {
stackview_panne.pop()
}
icon.name: FluentIcons.graph_ChromeBack
Component.onCompleted: {
d.setHitTestVisible(this)
}
}
IconButton{
id: button_menu
Layout.alignment: Qt.AlignVCenter
visible: d.isMinimal
implicitWidth: 40
implicitHeight: 36
icon.width: 15
icon.height: 15
Layout.rightMargin: 6
onClicked: {
d.sideMenuVisible = !d.sideMenuVisible
}
icon.name: FluentIcons.graph_GlobalNavButton
Component.onCompleted: {
d.setHitTestVisible(this)
}
}
Row{
Layout.fillHeight: true
Layout.leftMargin: 4
spacing: 6
AutoLoader{
anchors{
verticalCenter: parent.verticalCenter
}
sourceComponent: logoDelegate
}
Label{
text: control.title
anchors{
verticalCenter: parent.verticalCenter
}
font: Typography.bodyStrong
}
}
Loader {
id: loader_menubar
Layout.alignment: Qt.AlignVCenter
Layout.leftMargin: 10
sourceComponent: control.menuBar
onLoaded: {
if (item) {
d.setHitTestVisible(item)
}
}
}
}
}
}
Item{
id: d
visible: false
property int lastIndex : 0
property bool showSideBarBorder: d.sideMenuEnabled && d.sideMenuVisible && !d.isTop
property var items
property var topItems
property var topCacheItems: []
property int displayMode: control.displayMode
property bool sideMenuEnabled: d.displayMode === NavigationViewType.Minimal ||  d.displayMode === NavigationViewType.Compact
property bool sideMenuVisible: false
property bool isCompact: d.displayMode === NavigationViewType.Compact
property bool isMinimal: d.displayMode === NavigationViewType.Minimal
property bool isTop: d.displayMode === NavigationViewType.Top
property var menuDatas: []
function setHitTestVisible(id){
if(Window.window instanceof FramelessWindow){
Window.window.setHitTestVisible(id)
}
}
function showPaneItems(modelData,target,x=0,y=0){
const datas = []
for(let i=0;i<modelData.children.length;i++){
const item = modelData.children[i]
if(item.visible !== true){
continue
}
datas.push(item)
}
if(datas.length === 0){
return
}
d.menuDatas = datas
menu_pane_items.popup(target,x,y)
}
onDisplayModeChanged: {
sideMenuVisible = false
}
onItemsChanged: {
control.sourceItemsChanged(d.items)
}
}
Item{
id: layout_topbar
width: parent.width
anchors.top: layout_appbar.bottom
height: d.isTop ? control.topBarHeight : 0
visible: Number(height) !== 0
clip: true
Behavior on height{
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
Component{
id: comp_navi_top_header
Item{
implicitWidth: text_title.width + 10
Label{
id: text_title
text: modelData.title
font: Typography.bodyStrong
anchors{
right: parent.right
verticalCenter: parent.verticalCenter
}
}
}
}
Component{
id: comp_navi_top_separator
Rectangle{
implicitWidth: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
Component{
id: comp_navi_top_item
Item{
enabled: modelData.enabled
id: item_layout_top
property bool isCurrentIndex: {
if(modelData.__footer){
return listview_navi_top_footer.currentIndex === index
}else{
return listview_navi_top.currentIndex === index
}
}
property bool isHighlight: {
if(modelData.__footer){
return isCurrentIndex
}
if(index === listview_navi_top.currentIndex){
return true
}
return false
}
height: control.topBarHeight
width: (currentListView === listview_navi_top && modelData.__footer) ? 0 : item_icon_button.width + 10
IconButton{
id: item_icon_button
text: modelData.title
anchors.centerIn: parent
horizontalPadding: 12
height: 40
spacing: 6
icon.color: {
if(modelData.iconColor){
return modelData.iconColor
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
property var source: {
if(modelData.icon.source.toString()!==""){
return modelData.icon.source
}
return modelData.icon.name
}
SmoothUI.iconFamily: modelData.iconFamily
icon.name: source
icon.width: {
if(source === ""){
return 0
}
return modelData.icon.width
}
icon.height: {
if(source === ""){
return 0
}
return modelData.icon.height
}
display: modelData.__footer ? Button.IconOnly : Button.TextBesideIcon
onClicked: {
if (modelData.canTap && modelData.canTap() === false) {
return
}
if(modelData.__footer){
listview_navi_top.currentIndex = d.topItems.length - footerItems.length + index
}else{
listview_navi_top.currentIndex = index
}
modelData.tap()
control.tap(modelData)
if(modelData instanceof PaneItemExpander){
modelData.__expanded = !modelData.__expanded
d.showPaneItems(modelData,item_layout_top,0,item_layout_top.height)
}else{
d.sideMenuVisible = false
}
}
TapHandler {
acceptedButtons: Qt.RightButton
acceptedDevices: PointerDevice.Mouse
onTapped: tapEvent => {
modelData.rightTap()
control.rightTap(modelData)
}
}
TapHandler {
acceptedDevices: PointerDevice.TouchScreen
onLongPressed: {
modelData.rightTap()
control.rightTap(modelData)
}
}
}
AutoLoader{
property var model: modelData
anchors{
top: parent.top
topMargin: 8
right: parent.right
}
sourceComponent: {
if(modelData instanceof PaneItem){
if(!d.isTop){
return undefined
}
if(modelData.count === 0){
return undefined
}
if(modelData.infoBadge){
return modelData.infoBadge
}
return comp_info_badge
}else{
return undefined
}
}
}
InfoBadge{
dot: true
anchors{
right: parent.right
top: parent.top
rightMargin: 8
topMargin: 12
}
visible: {
if(modelData instanceof PaneItem){
if(modelData.count !== 0 && d.isTop){
return true
}
return false
}else{
for(let i=0;i<modelData.children.length;i++){
const item = modelData.children[i]
if((item instanceof PaneItem || item instanceof PaneItemExpander) && item.count !==0){
return true
}
}
return false
}
}
}
HighlightRectangle{
target: listview_navi_top
highlight: isHighlight
orientation: Qt.Horizontal
highlightSize: 18
bottomMargin: 6
}
}
}
RowLayout{
id: layout_top_row
anchors.fill: parent
Item{
id: layout_navi_top
Layout.fillHeight: true
Layout.fillWidth: true
ListView{
id: listview_navi_top
property int enterLastIndex : 0
property int popLastIndex : 0
height: parent.height
width: contentWidth
model: d.topItems
boundsBehavior: ListView.StopAtBounds
orientation: ListView.Horizontal
delegate: Item{
property bool hide: (x+item_top_loader.width-layout_navi_top.width+layout_item_more.width)>0
property var currentListView: ListView.view
property var modelData : model.modelData
property int index: model.index
height: ListView.view.height
width: item_top_loader.width
visible: !hide
onHideChanged: {
if(hide){
d.topCacheItems.push(this)
}else{
const pos = d.topCacheItems.indexOf(this)
if (pos > -1) {
d.topCacheItems.splice(pos, 1)
}
}
d.topCacheItems = [...d.topCacheItems]
}
clip: true
AutoLoader{
id: item_top_loader
property bool hide: parent.hide
property var modelData : parent.modelData
property int index: parent.index
property var currentListView: parent.currentListView
height: parent.height
sourceComponent: {
if(!d.isTop){
return undefined
}
if(!modelData.visible){
return undefined
}
if(modelData instanceof PaneItem || modelData instanceof PaneItemExpander){
return comp_navi_top_item
}else if(modelData instanceof PaneItemHeader){
return comp_navi_top_header
}else if(modelData instanceof PaneItemSeparator){
return comp_navi_top_separator
}
return undefined
}
}
}
}
Item{
id: layout_item_more
height: listview_navi_top.height
width: 50
clip: true
visible: d.topCacheItems.length !== 0
x: Math.min(layout_navi_top.width-50,listview_navi_top.width)
IconButton{
id: btn_more
icon.width: 20
icon.height: 20
icon.name: FluentIcons.graph_More
anchors.centerIn: parent
onClicked: {
let datas = d.topCacheItems.map((item) => { return item.modelData })
datas = datas.filter(
(item) => {
if(item instanceof PaneItem || item instanceof PaneItemExpander){
if(item.__footer){
return false
}
return true
}
return false
})
d.menuDatas = datas.reverse()
menu_pane_items.popup(layout_item_more,0,layout_item_more.height)
}
}
}
}
Item{
Layout.fillHeight: true
Layout.topMargin: 2
Layout.bottomMargin: 2
Layout.rightMargin: 4
Layout.preferredWidth: childrenRect.width
visible: {
if(control.autoSuggestBox){
return true
}
return false
}
Item{
id: layout_top_autosuggestbox
visible: !d.isCompact || d.sideMenuVisible
anchors.centerIn: parent
width: 200
height: childrenRect.height
function updateAutoSuggestBox(){
if(control.autoSuggestBox && d.displayMode === NavigationViewType.Top){
control.autoSuggestBox.parent = layout_top_autosuggestbox
control.autoSuggestBox.anchors.left = control.autoSuggestBox.parent.left
control.autoSuggestBox.anchors.right = control.autoSuggestBox.parent.right
}
}
Component.onCompleted: {
layout_top_autosuggestbox.updateAutoSuggestBox()
}
Connections{
target: d
function onDisplayModeChanged() {
layout_top_autosuggestbox.updateAutoSuggestBox()
}
}
}
}
ListView{
id: listview_navi_top_footer
Layout.fillHeight: true
implicitWidth: contentWidth
model: footerItems
boundsBehavior: ListView.StopAtBounds
orientation: ListView.Horizontal
currentIndex: {
if(d.topItems){
const footerIndex = listview_navi_top.currentIndex - (d.topItems.length-footerItems.length)
if(footerIndex>=0){
return footerIndex
}
return -1
}
return -1
}
delegate: AutoLoader{
property var modelData : model.modelData
property int index: model.index
property var currentListView: ListView.view
height: ListView.view.height
sourceComponent: {
if(!d.isTop){
return undefined
}
if(!modelData.visible){
return undefined
}
if(modelData instanceof PaneItem || modelData instanceof PaneItemExpander){
return comp_navi_top_item
}else if(modelData instanceof PaneItemHeader){
return comp_navi_top_header
}else if(modelData instanceof PaneItemSeparator){
return comp_navi_top_separator
}
return undefined
}
}
}
}
}
Component{
id: comp_info_badge
InfoBadge{
count: model.count
}
}
Frame{
id: layout_panne
padding: control.framePadding
anchors{
left: parent.left
right: parent.right
top: d.isTop ? layout_topbar.bottom : layout_appbar.bottom
bottom: parent.bottom
leftMargin: {
if(d.isMinimal || d.isTop){
return 0
}
if(d.isCompact){
return 50
}
return sideBarWidth
}
}
Behavior on anchors.leftMargin {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
PageRouterView{
id: stackview_panne
anchors.fill: parent
router: control.router
clip: true
onCurrentItemChanged: {
if(d.items){
let index = d.items.findIndex((element) => element.key === currentItem.path)
if(listview_navi.currentIndex !== index){
listview_navi.currentIndex = index
}
let data = d.items[index]
while(data.__parent){
if(!data.__parent.__expanded){
return 0
}
data = data.__parent
}
index = d.topItems.findIndex((element) => element === data)
if(listview_navi_top.currentIndex !== index){
listview_navi_top.currentIndex = index
}
}
// 页面加载是异步的，需要延迟检测
Qt.callLater(function() {
applyPageBackground()
})
}
}
}
function applyPageBackground() {
var currentItem = stackview_panne.currentItem
if (!currentItem) return
// - singleton 页面：currentItem.singletonItem.item
var pageItem = null
if (currentItem.singleton && currentItem.singletonItem) {
pageItem = currentItem.singletonItem.item
} else if (currentItem.item) {
pageItem = currentItem.item
}
if (!pageItem) {
page_background_timer.start()
return
}
if (pageItem.hasOwnProperty("appBarBackground")) {
AppBarBackground.applyConfig(pageItem.appBarBackground)
} else {
AppBarBackground.resetToDefault()
}
control.appBarBackground = AppBarBackground.getConfig()
if (pageItem.hasOwnProperty("sideBarBackground")) {
SideBarBackground.applyConfig(pageItem.sideBarBackground)
} else {
SideBarBackground.resetToDefault()
}
control.sideBarBackground = SideBarBackground.getConfig()
if (pageItem.hasOwnProperty("sideBarTextStyle")) {
SideBarTextStyle.applyConfig(pageItem.sideBarTextStyle)
} else {
SideBarTextStyle.resetToDefault()
}
control.sideBarTextStyle = SideBarTextStyle.getConfig()
}
Timer {
id: page_background_timer
interval: 50
repeat: false
onTriggered: applyPageBackground()
}
MouseArea{
anchors.fill: parent
visible: d.sideMenuEnabled && d.sideMenuVisible && !d.isTop
hoverEnabled: true
onWheel: {}
onClicked: {
d.sideMenuVisible = false
}
}
Shadow{
id: shadow_side
anchors.fill: layout_sidebar
visible: control.sideBarShadow && d.showSideBarBorder
radius: Theme.panelRadius
}
Pane{
id: layout_sidebar
clip: true
padding: 0
width: {
if(d.isTop){
return 0
}
if(d.sideMenuVisible){
return sideBarWidth
}
if(d.isMinimal){
return 0
}
if(d.isCompact){
return 50
}
return sideBarWidth
}
anchors{
top: parent.top
bottom: parent.bottom
}
Behavior on width{
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
visible: {
if(d.isTop){
return false
}
if(d.sideMenuVisible){
return true
}
if(d.isMinimal){
return false
}
return true
}
background: Item {
Rectangle {
anchors.fill: parent
border.width: d.showSideBarBorder ? 1 : 0
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
radius: d.showSideBarBorder ? Theme.panelRadius : 0
color: "transparent"
z: 100
}
Rectangle {
id: sidebar_background_default
anchors.fill: parent
radius: d.showSideBarBorder ? Theme.panelRadius : 0
visible: !sideBarBackground && d.sideMenuVisible
color: control.SmoothUI.theme.res.micaBackgroundColor
z: 0
}
Rectangle {
id: sidebar_background_transparent
anchors.fill: parent
radius: d.showSideBarBorder ? Theme.panelRadius : 0
visible: sideBarBackground && sideBarBackground.type === "transparent"
color: "transparent"
z: 0
}
Rectangle {
id: sidebar_background_solid
anchors.fill: parent
radius: d.showSideBarBorder ? Theme.panelRadius : 0
visible: sideBarBackground && sideBarBackground.type === "color"
color: sideBarBackground && sideBarBackground.color ? sideBarBackground.color : control.SmoothUI.theme.res.cardBackgroundColor
z: 0
}
Loader {
id: sidebar_gradient_loader
anchors.fill: parent
z: 0
active: sideBarBackground && sideBarBackground.type === "gradient" && sideBarBackground.colors && sideBarBackground.colors.length === 2
sourceComponent: {
if (!sideBarBackground || sideBarBackground.type !== "gradient") return null
if (sideBarBackground.direction === "horizontal") {
return sidebarGradientHorizontalComponent
}
return sidebarGradientVerticalComponent
}
property var gradientColors: sideBarBackground ? (sideBarBackground.colors || ["#F3F3F3", "#E8E8E8"]) : ["#F3F3F3", "#E8E8E8"]
property real bgRadius: d.showSideBarBorder ? Theme.panelRadius : 0
}
Component {
id: sidebarGradientVerticalComponent
Rectangle {
radius: sidebar_gradient_loader.bgRadius
gradient: Gradient {
orientation: Gradient.Vertical
GradientStop { position: 0.0; color: sidebar_gradient_loader.gradientColors[0] || "#F3F3F3" }
GradientStop { position: 1.0; color: sidebar_gradient_loader.gradientColors[1] || "#E8E8E8" }
}
}
}
Component {
id: sidebarGradientHorizontalComponent
Rectangle {
radius: sidebar_gradient_loader.bgRadius
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: sidebar_gradient_loader.gradientColors[0] || "#F3F3F3" }
GradientStop { position: 1.0; color: sidebar_gradient_loader.gradientColors[1] || "#E8E8E8" }
}
}
}
Loader {
id: sidebar_multi_gradient_loader
anchors.fill: parent
z: 0
active: sideBarBackground && sideBarBackground.type === "gradient" && sideBarBackground.colors && sideBarBackground.colors.length > 2
sourceComponent: {
if (!sideBarBackground || sideBarBackground.type !== "gradient" || !sideBarBackground.colors) return null
if (sideBarBackground.colors.length === 3) {
return sideBarBackground.direction === "horizontal" ? sidebarThreeStopHorizontalComponent : sidebarThreeStopVerticalComponent
} else if (sideBarBackground.colors.length >= 4) {
return sideBarBackground.direction === "horizontal" ? sidebarFourStopHorizontalComponent : sidebarFourStopVerticalComponent
}
return null
}
property var gradientColors: sideBarBackground ? sideBarBackground.colors : []
property real bgRadius: d.showSideBarBorder ? Theme.panelRadius : 0
}
Component {
id: sidebarThreeStopVerticalComponent
Rectangle {
radius: sidebar_multi_gradient_loader.bgRadius
gradient: Gradient {
orientation: Gradient.Vertical
GradientStop { position: 0.0; color: sidebar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.5; color: sidebar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 1.0; color: sidebar_multi_gradient_loader.gradientColors[2] }
}
}
}
Component {
id: sidebarThreeStopHorizontalComponent
Rectangle {
radius: sidebar_multi_gradient_loader.bgRadius
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: sidebar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.5; color: sidebar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 1.0; color: sidebar_multi_gradient_loader.gradientColors[2] }
}
}
}
Component {
id: sidebarFourStopVerticalComponent
Rectangle {
radius: sidebar_multi_gradient_loader.bgRadius
gradient: Gradient {
orientation: Gradient.Vertical
GradientStop { position: 0.0; color: sidebar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.33; color: sidebar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 0.66; color: sidebar_multi_gradient_loader.gradientColors[2] }
GradientStop { position: 1.0; color: sidebar_multi_gradient_loader.gradientColors[3] }
}
}
}
Component {
id: sidebarFourStopHorizontalComponent
Rectangle {
radius: sidebar_multi_gradient_loader.bgRadius
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: sidebar_multi_gradient_loader.gradientColors[0] }
GradientStop { position: 0.33; color: sidebar_multi_gradient_loader.gradientColors[1] }
GradientStop { position: 0.66; color: sidebar_multi_gradient_loader.gradientColors[2] }
GradientStop { position: 1.0; color: sidebar_multi_gradient_loader.gradientColors[3] }
}
}
}
}
Component{
id: comp_navi_header
Item{
visible: {
let data = modelData
while(data.__parent){
if(!data.__parent.__expanded){
return false
}
data = data.__parent
}
return !(d.isCompact&&!d.sideMenuVisible)
}
implicitHeight: visible ? 30 : 0
Label{
text: modelData.title
font: Typography.bodyStrong
anchors{
bottom: parent.bottom
left: parent.left
leftMargin: 14
}
}
}
}
Component{
id: comp_navi_separator
Rectangle{
implicitHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
Component{
id: comp_navi_item
Item{
enabled: modelData.enabled
implicitHeight: {
if(modelData instanceof PaneItem){
if(modelData.__footer === true && currentListView === listview_navi){
return 0
}
}
if(d.isCompact && !d.sideMenuVisible){
if(deep !== 0){
return 0
}else{
return control.sideItemHeight
}
}
let data = modelData
while(data.__parent){
if(!data.__parent.__expanded){
return 0
}
data = data.__parent
}
return control.sideItemHeight
}
property int deep: {
let data = modelData
let deep = 0
while(data.__parent){
deep = deep + 1
data = data.__parent
}
return deep
}
property bool isCurrentIndex: {
if(modelData.__footer){
return listview_navi_footer.currentIndex === index
}else{
return listview_navi.currentIndex === index
}
}
property int offsetX: deep * 32 + 12
property bool isHighlight: {
if(!d.isCompact || d.sideMenuVisible || modelData.__footer){
return isCurrentIndex
}
if(modelData.__index === listview_navi.currentIndex){
return true
}
if(modelData instanceof PaneItemExpander){
const stack = []
for(let i=0;i<modelData.children.length;i++){
stack.push(modelData.children[i])
}
while (stack.length > 0) {
const current = stack.pop()
if(current.__index === listview_navi.currentIndex){
return true
}
if (current instanceof PaneItemExpander) {
const children = []
for(let j=0;j<current.children.length;j++){
children.push(current.children[j])
}
for(let k=0;k<children.length;k++){
stack.push(children[k])
}
}
}
}
return false
}
property bool isShown: Number(implicitHeight) === control.sideItemHeight
visible: isShown
opacity: isShown
Behavior on implicitHeight{
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
Behavior on opacity {
NumberAnimation { duration: Theme.fastAnimationDuration; easing.type: Theme.animationCurve }
}
Component{
id: comp_trailing
Icon{
source: FluentIcons.graph_ChevronUp
width: 12
height: 12
rotation: modelData.__expanded ? 0 : -180
Behavior on rotation {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
Component{
id: comp_tile
ListTile{
id: item_list_tile
text: modelData.title
spacing: modelData.iconSpacing
highlighted: isCurrentIndex
leftPadding: offsetX
font: control.tileFont
focusPolicy: control.tileFocusPolicy
textColor: {
if(!item_list_tile.enabled){
if(control.sideBarTextStyle && control.sideBarTextStyle.type === "custom"){
return control.sideBarTextStyle.disabledColor
}
return item_list_tile.SmoothUI.theme.res.textFillColorDisabled
}
if(item_list_tile.highlighted){
if(control.sideBarTextStyle && control.sideBarTextStyle.type === "custom"){
return control.sideBarTextStyle.selectedColor
}
return item_list_tile.SmoothUI.theme.res.textFillColorSecondary
}
if(item_list_tile.hovered){
if(control.sideBarTextStyle && control.sideBarTextStyle.type === "custom"){
return control.sideBarTextStyle.hoverColor
}
return item_list_tile.SmoothUI.theme.res.textFillColorTertiary
}
if(control.sideBarTextStyle && control.sideBarTextStyle.type === "custom"){
return control.sideBarTextStyle.normalColor
}
return item_list_tile.SmoothUI.theme.res.textFillColorPrimary
}
leading: Icon{
color: {
if(modelData.iconColor){
return modelData.iconColor
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
source: {
if(modelData.icon.source.toString()!==""){
return modelData.icon.source
}
return modelData.icon.name
}
family: modelData.iconFamily
width: {
if(source === ""){
return 0
}
return modelData.icon.width
}
height: {
if(source === ""){
return 0
}
return modelData.icon.height
}
}
trailing: {
if(modelData instanceof PaneItemExpander){
if(d.isCompact && !d.sideMenuVisible){
return null
}
return comp_trailing
}
return null
}
container: AutoLoader{
property var model: modelData
property color defaultTextColor: item_list_tile.textColor
sourceComponent: control.sideItemDelegate
onLoaded: {
if(item.hasOwnProperty("model")){
item.model = modelData
}
if(item.hasOwnProperty("defaultTextColor")){
item.defaultTextColor = defaultTextColor
}
}
}
ToolTip{
text: modelData.title
visible: parent.hovered && d.isCompact && !d.sideMenuVisible
}
anchors{
fill: parent
leftMargin: 4
rightMargin: 4
topMargin: 2
bottomMargin: 2
}
TapHandler {
acceptedButtons: Qt.RightButton
acceptedDevices: PointerDevice.Mouse
onTapped: tapEvent => {
modelData.rightTap()
control.rightTap(modelData)
}
}
TapHandler {
acceptedDevices: PointerDevice.TouchScreen
onLongPressed: {
modelData.rightTap()
control.rightTap(modelData)
}
}
onClicked: {
if (modelData.canTap && modelData.canTap() === false) {
return
}
if(modelData.__footer){
listview_navi.currentIndex = d.items.length - footerItems.length + index
}else{
listview_navi.currentIndex = index
}
modelData.tap()
control.tap(modelData)
if(modelData instanceof PaneItemExpander){
modelData.__expanded = !modelData.__expanded
if(d.isCompact && !d.sideMenuVisible){
d.showPaneItems(modelData,item_list_tile,item_list_tile.width+4,0)
}
}else{
d.sideMenuVisible = false
}
}
AutoLoader{
property var model: modelData
anchors{
verticalCenter: parent.verticalCenter
right: parent.right
rightMargin: 8
}
sourceComponent: {
if(modelData instanceof PaneItem){
if(modelData.count === 0){
return undefined
}
if(d.isCompact && !d.sideMenuVisible){
return undefined
}
if(modelData.infoBadge){
return modelData.infoBadge
}
return comp_info_badge
}else{
return undefined
}
}
}
InfoBadge{
dot: true
anchors{
right: parent.right
top: parent.top
rightMargin: 5
topMargin: 5
}
visible: {
if(modelData instanceof PaneItem){
if(modelData.count !== 0 && d.isCompact && !d.sideMenuVisible){
return true
}
return false
}else{
for(let i=0;i<modelData.children.length;i++){
const item = modelData.children[i]
if((item instanceof PaneItem || item instanceof PaneItemExpander) && item.count !==0){
return true
}
}
return false
}
}
}
HighlightRectangle{
target: listview_navi
leftMargin: offsetX - 8
highlight: isHighlight
}
}
}
AutoLoader{
anchors.fill: parent
sourceComponent: isShown ? comp_tile : undefined
}
}
}
ColumnLayout{
anchors{
fill: parent
topMargin: appBarHeight
}
Item{
visible: d.isCompact
Layout.fillWidth: true
Layout.leftMargin: 4
Layout.rightMargin: 4
implicitHeight: 36
IconButton{
height: parent.height
width: 42
icon.width: 16
icon.height: 16
onClicked: {
d.sideMenuVisible = !d.sideMenuVisible
}
icon.name: FluentIcons.graph_GlobalNavButton
}
}
AutoLoader{
id: loader_leading
Layout.fillWidth: true
Layout.preferredHeight: childrenRect.height
sourceComponent: control.leading
visible: !(d.isCompact && !d.sideMenuVisible && status === Loader.Ready)
}
Item{
Layout.fillWidth: true
Layout.leftMargin: 4
Layout.rightMargin: 4
implicitHeight: childrenRect.height
visible: {
if(control.autoSuggestBox){
return true
}
return false
}
Item{
id: layout_autosuggestbox
anchors{
left: parent.left
right: parent.right
leftMargin: 10
rightMargin: 10
}
visible: !d.isCompact || d.sideMenuVisible
function updateAutoSuggestBox(){
if(control.autoSuggestBox && d.displayMode !== NavigationViewType.Top){
control.autoSuggestBox.parent = layout_autosuggestbox
control.autoSuggestBox.anchors.left = control.autoSuggestBox.parent.left
control.autoSuggestBox.anchors.right = control.autoSuggestBox.parent.right
}
}
Component.onCompleted: {
layout_autosuggestbox.updateAutoSuggestBox()
}
Connections{
target: d
function onDisplayModeChanged() {
layout_autosuggestbox.updateAutoSuggestBox()
}
}
}
IconButton{
height: 36
width: 42
icon.width: 15
icon.height: 15
visible: d.isCompact && !d.sideMenuVisible
onClicked: {
d.sideMenuVisible = true
}
AutoLoader{
anchors.centerIn: parent
sourceComponent: control.autoSuggestBoxReplacement
}
}
}
Flickable{
id: navigationScroll
Layout.fillHeight: true
Layout.fillWidth: true
boundsBehavior: ListView.StopAtBounds
contentHeight: listview_navi.contentHeight
ScrollBar.vertical: ScrollBar {}
clip: true
ListView{
id: listview_navi
property int enterLastIndex : 0
property int popLastIndex : 0
model: d.items
anchors.fill: parent
interactive: false
boundsBehavior: ListView.StopAtBounds
delegate: AutoLoader{
property var modelData : model.modelData
property int index: model.index
property var currentListView: ListView.view
width: ListView.view.width
sourceComponent: {
if(d.isTop){
return undefined
}
if(!modelData.visible){
return undefined
}
if(modelData instanceof PaneItem || modelData instanceof PaneItemExpander){
return comp_navi_item
}else if(modelData instanceof PaneItemHeader){
return comp_navi_header
}else if(modelData instanceof PaneItemSeparator){
return comp_navi_separator
}
return undefined
}
}
onCurrentIndexChanged: {
let data = d.items[currentIndex]
if(data){
while(data.__parent){
if(!data.__parent.__expanded){
data.__parent.__expanded = true
}
data = data.__parent
}
}
}
}
}
Rectangle{
Layout.fillWidth: true
implicitHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
visible: listview_navi_footer.count !== 0
}
AutoLoader{
id: loader_trailing
Layout.fillWidth: true
Layout.preferredHeight: childrenRect.height
sourceComponent: control.trailing
visible: !(d.isCompact && !d.sideMenuVisible && status === Loader.Ready)
}
ListView{
id: listview_navi_footer
model: footerItems
clip: true
boundsBehavior: ListView.StopAtBounds
delegate: AutoLoader{
property var modelData : model.modelData
property int index: model.index
property var currentListView: ListView.view
width: ListView.view.width
sourceComponent: {
if(d.isTop){
return undefined
}
if(!modelData.visible){
return undefined
}
if(modelData instanceof PaneItem || modelData instanceof PaneItemExpander){
return comp_navi_item
}else if(modelData instanceof PaneItemHeader){
return comp_navi_header
}else if(modelData instanceof PaneItemSeparator){
return comp_navi_separator
}
return undefined
}
}
implicitHeight: contentHeight
Layout.fillWidth: true
currentIndex: {
if(d.items){
const footerIndex = listview_navi.currentIndex - (d.items.length - footerItems.length)
if(footerIndex>=0){
return footerIndex
}
return -1
}
return -1
}
}
}
}
AutoLoader{
id: layout_appbar
width: parent.width
height: control.appBarHeight
sourceComponent: control.appBar
}
Component{
id: comp_panne
AutoLoader{
id: loader_panne
property var url
property var argument
source: visible ? url : null
}
}
NavigationMenu{
id: menu_pane_items
MenuItem{}
Instantiator{
model: d.menuDatas
delegate: QtObject{
property var modelData : model.modelData
property var parent: menu_pane_items
property bool isExpander: modelData instanceof PaneItemExpander
property var value
}
onObjectAdded:
(index, object) => {
if(!object.modelData.visible){
return
}
if(object.isExpander){
var comp = Qt.createComponent("NavigationMenu.qml")
if (comp.status === Component.Ready) {
const menu = comp.createObject(object.parent.contentItem,{modelData:object.modelData,view:control})
object.value = menu
menu_pane_items.insertMenu(index,menu)
}
}else{
comp = Qt.createComponent("NavigationMenuItem.qml")
if (comp.status === Component.Ready) {
const item = comp.createObject(object.parent.contentItem,{modelData:object.modelData,view:control})
object.value = item
menu_pane_items.insertItem(index,item)
}
}
}
onObjectRemoved:
(index, object) => {
if(object.isExpander){
menu_pane_items.removeMenu(object.value)
}else{
menu_pane_items.removeItem(object.value)
}
}
}
}
function go(url,argument={}){
if(stackview_panne.currentItem){
if(stackview_panne.currentItem.url === url){
return
}
}
stackview_panne.push(comp_panne,{url:url,argument:argument})
}
}
