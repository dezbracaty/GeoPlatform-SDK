import QtQuick
import SmoothUI.Controls
import SmoothUI.impl
import "qrc:/kddockwidgets/qtquick/views/qml/" as KDDW
Rectangle {
id: control
readonly property QtObject floatingWindowCpp: parent
readonly property QtObject titleBarCpp: floatingWindowCpp ? floatingWindowCpp.titleBar : null
readonly property QtObject dropAreaCpp: floatingWindowCpp ? floatingWindowCpp.dropArea : null
readonly property int titleBarHeight: titleBar.heightWhenVisible
property int margins: 4
SmoothUI.theme: Theme.of(control)
SmoothUI.dark: Theme.dark
SmoothUI.primaryColor: Theme.primaryColor
property var accentColor: SmoothUI.theme.accentColor
property var primaryColor: accentColor?.defaultBrushFor(control.SmoothUI.dark)??"#00000000"
anchors.fill: parent
color: control.SmoothUI.theme.res.cardBackgroundColor
radius: Theme.panelRadius
border {
color: control.SmoothUI.theme.res.surfaceStrokeColorDefault
width: Theme.borderWidth
}
onTitleBarHeightChanged: {
if (floatingWindowCpp)
floatingWindowCpp.geometryUpdated();
}
Loader {
id: titleBar
readonly property QtObject titleBarCpp: control.titleBarCpp
readonly property int heightWhenVisible: item.heightWhenVisible
source: _kddw_widgetFactory.titleBarFilename()
SmoothUI.dark: control.SmoothUI.dark
anchors {
top:  parent ? parent.top : undefined
left: parent ? parent.left : undefined
right: parent ? parent.right : undefined
margins: control.margins
}
}
KDDW.DropArea {
id: dropArea
dropAreaCpp: control.dropAreaCpp
anchors {
left: parent ? parent.left : undefined
right: parent ? parent.right : undefined
top: titleBar.bottom
bottom: parent ? parent.bottom : undefined
leftMargin: control.margins
rightMargin: control.margins
bottomMargin: control.margins
}
onHeightChanged: {
}
}
onDropAreaCppChanged: {
if (dropAreaCpp) {
dropAreaCpp.parent = dropArea;
dropAreaCpp.anchors.fill = dropArea;
}
}
onHeightChanged: {
}
onWidthChanged: {
}
}
