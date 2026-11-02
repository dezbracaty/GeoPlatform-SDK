import QtQuick
import QtQuick.Layouts
import SmoothUI.Controls
import SmoothUI.impl
import SmoothUIDock
import com.kdab.dockwidgets
import "qrc:/kddockwidgets/qtquick/views/qml/" as KDDW
Rectangle {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property QtObject groupCpp
readonly property QtObject titleBarCpp: groupCpp ? groupCpp.titleBar : null
readonly property int nonContentsHeight: (titleBar.item ? titleBar.item.heightWhenVisible : 0) + tabbar.implicitHeight + (2 * contentsMargin) + titleBarContentsMargin
property int contentsMargin: {
var dockArea = control.findParentDockingArea();
if (dockArea) {
return isMDI ? Math.max(dockArea.contentsMargin, 2) : dockArea.contentsMargin;
}
return isMDI ? 2 : 0;  // 回退值
}
property int titleBarContentsMargin: {
var dockArea = control.findParentDockingArea();
if (dockArea) {
return dockArea.titleBarContentsMargin;
}
return 0;  // 回退值
}    property int mouseResizeMargin: 8
readonly property bool isMDI: groupCpp && groupCpp.isMDI
readonly property bool resizeAllowed: control.isMDI && !_kddwHelpers.isDragging && _kddwDockRegistry && (!_kddwHelpers.groupViewInMDIResize || _kddwHelpers.groupViewInMDIResize === groupCpp)
property alias tabBarHeight: tabbar.height
readonly property bool hasCustomMouseEventRedirector: false
readonly property bool isFixedHeight: groupCpp && groupCpp.isFixedHeight
readonly property bool isFixedWidth: groupCpp && groupCpp.isFixedWidth
readonly property bool tabsAtTop: !groupCpp || !groupCpp.tabsAtBottom
property Component customTabBarComponent: null
function findParentDockingArea() {
var current = control.parent
var depth = 0
while (current && depth < 20) {
if (current.contentsMargin !== undefined &&
current.titleBarContentsMargin !== undefined) {
return current
}
current = current.parent
++depth
}
return null
}
Connections {
target: SmoothUIDock
function onCustomTabBarComponentChanged() {
control.refreshCustomTabBarComponent()
}
}
function refreshCustomTabBarComponent() {
customTabBarComponent = SmoothUIDock.customTabBarComponent()
}
Component.onCompleted: refreshCustomTabBarComponent()
anchors.fill: parent
radius: Theme.panelRadius
color: control.SmoothUI.theme.res.cardBackgroundColor
border {
color: control.SmoothUI.theme.res.surfaceStrokeColorDefault
width: Theme.borderWidth
}
onGroupCppChanged: {
if (groupCpp) {
groupCpp.setStackLayout(stackLayout);
}
}
onNonContentsHeightChanged: {
if (groupCpp)
groupCpp.geometryUpdated();
}
MouseArea {
anchors.fill: parent
KDDW.MDIResizeHandlerHelper {
anchors {
left: parent ? parent.left : undefined
top: parent ? parent.top : undefined
bottom: parent ? parent.bottom : undefined
}
width: resizeMargin
z: 100
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed && !control.isFixedWidth
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Left
}
KDDW.MDIResizeHandlerHelper {
anchors {
right: parent ? parent.right : undefined
top: parent ? parent.top : undefined
bottom: parent ? parent.bottom : undefined
}
width: resizeMargin
z: 100
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed && !control.isFixedWidth
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Right
}
KDDW.MDIResizeHandlerHelper {
anchors {
right: parent ? parent.right : undefined
top: parent ? parent.top : undefined
left: parent ? parent.left : undefined
}
height: resizeMargin
z: 100
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed && !control.isFixedHeight
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Top
}
KDDW.MDIResizeHandlerHelper {
anchors {
right: parent ? parent.right : undefined
left: parent ? parent.left : undefined
bottom: parent ?  parent.bottom : undefined
}
height: resizeMargin
z: 100
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed && !control.isFixedHeight
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Bottom
}
KDDW.MDIResizeHandlerHelper {
anchors {
right: parent ? parent.right : undefined
bottom: parent ? parent.bottom : undefined
}
height: width
width: resizeMargin
z: 101
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Bottom | KDDockWidgets.CursorPosition_Right
}
KDDW.MDIResizeHandlerHelper {
anchors {
left:  parent ? parent.left : undefined
top:  parent ? parent.top : undefined
}
height: width
width: resizeMargin
z: 101
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Top | KDDockWidgets.CursorPosition_Left
}
KDDW.MDIResizeHandlerHelper {
anchors {
right: parent ? parent.right : undefined
top: parent ? parent.top : undefined
}
height: width
width: resizeMargin
z: 101
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Top | KDDockWidgets.CursorPosition_Right
}
KDDW.MDIResizeHandlerHelper {
anchors {
left: parent ? parent.left : undefined
bottom: parent ? parent.bottom : undefined
}
height: width
width: resizeMargin
z: 101
groupCpp: control.groupCpp
resizeAllowed: control.resizeAllowed
resizeMargin: control.mouseResizeMargin
cursorPosition: KDDockWidgets.CursorPosition_Left | KDDockWidgets.CursorPosition_Bottom
}
}
Loader {
id: titleBar
readonly property QtObject titleBarCpp: control.titleBarCpp
source: groupCpp ? _kddw_widgetFactory.titleBarFilename() : ""
anchors {
top:  parent ? parent.top : undefined
left: parent ? parent.left : undefined
right: parent ? parent.right : undefined
topMargin: control.titleBarContentsMargin
leftMargin: control.titleBarContentsMargin
rightMargin: control.titleBarContentsMargin
}
}
Loader {
id: tabbar
readonly property QtObject groupCpp: control.groupCpp
readonly property bool hasCustomMouseEventRedirector: control.hasCustomMouseEventRedirector
source: groupCpp ? _kddw_widgetFactory.tabbarFilename() : ""
visible: control.customTabBarComponent === null
function topAnchor() {
if (control.tabsAtTop) {
return (titleBar && titleBar.visible) ? titleBar.bottom
: (parent ? parent.top : undefined);
} else {
return undefined;
}
}
anchors {
left: parent ? parent.left : undefined
right: parent ? parent.right : undefined
top: topAnchor()
bottom: control.tabsAtTop ? undefined : parent.bottom
leftMargin: 1
rightMargin: 1
}
}
Item {
id: stackLayout
function bottomAnchor() {
if (!parent)
return undefined;
if (control.tabsAtTop || !tabbar.visible)
return parent.bottom;
return tabbar.top;
}
anchors {
left: parent ? parent.left : undefined
right: parent ? parent.right : undefined
top: (parent && tabbar.visible && control.tabsAtTop) ? tabbar.bottom : ((titleBar && titleBar.visible) ? titleBar.bottom : parent ? parent.top : undefined);
bottom: bottomAnchor()
leftMargin: control.contentsMargin
rightMargin: control.contentsMargin
bottomMargin: control.contentsMargin
}
Loader {
id: customTabBarLoader
anchors.fill: parent
sourceComponent: control.customTabBarComponent
visible: control.customTabBarComponent !== null
z: 10
onLoaded: {
if (!item) {
return
}
item.groupCpp = Qt.binding(function() {
return control.groupCpp
})
item.tabBarModel = Qt.binding(function() {
return control.groupCpp && control.groupCpp.tabBar
? control.groupCpp.tabBar.dockWidgetModel
: 0
})
item.currentTabIndex = Qt.binding(function() {
return control.groupCpp ? control.groupCpp.currentIndex : -1
})
if (item.dragMouseArea && control.groupCpp && control.groupCpp.tabBar) {
control.groupCpp.tabBar.redirectMouseEvents(item.dragMouseArea)
}
}
}
}
}
