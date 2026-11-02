import QtQuick
import QtQuick.Controls
import SmoothUI.impl
import SmoothUI.Controls
import "qrc:/kddockwidgets/qtquick/views/qml/" as KDDW
KDDW.TitleBarBase {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.iconFamily: FluentIcons.fontLoader.name
readonly property QtObject floatButton: floatButton
readonly property QtObject closeButton: closeButton
color: control.SmoothUI.theme.res.micaBackgroundColor
heightWhenVisible: Theme.controlHeight
radius: control.SmoothUI.radius
Label {
id: title
text: control.title
font: Typography.bodyStrong
elide: Text.ElideRight
anchors {
left: parent ? parent.left : undefined
leftMargin: Theme.space12
right: titleActions.left
rightMargin: Theme.space8
verticalCenter: parent.verticalCenter
}
}
Row {
id: titleActions
anchors {
verticalCenter: parent ? parent.verticalCenter : undefined
right: parent ? parent.right : undefined
topMargin: 5
bottomMargin: 5
rightMargin: 2
}
IconButton {
id: minimizeButton
implicitWidth: control.heightWhenVisible
implicitHeight: control.heightWhenVisible
padding: 0
radius: 0
visible: control.minimizeButtonVisible
icon.name: FluentIcons.graph_ChromeMinimize
icon.width: 12
icon.height: 12
flat: true
onClicked: control.minimizeButtonClicked()
}
IconButton{
id: floatButton
property bool hover: hovered
implicitWidth: control.heightWhenVisible
implicitHeight: control.heightWhenVisible
radius: 0
icon.width: 12
visible: control.floatButtonVisible
icon.height: 12
icon.name: FluentIcons.graph_TaskViewSettings
ToolTip.visible: hovered
ToolTip.text: qsTr("Float")
ToolTip.delay: Theme.tooltipDelay
backgroundColor: {
if(floatButton.down){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(floatButton.hover){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
onClicked: {
control.floatButtonClicked();
}
}
IconButton{
id: maximizeButton
radius: 0
property bool hover: hovered
implicitWidth: control.heightWhenVisible
implicitHeight: control.heightWhenVisible
padding: 0
icon.width: 12
visible: control.maximizeButtonVisible
icon.height: 12
icon.name: control.maximizeUsesRestoreIcon ? FluentIcons.graph_ChromeRestore : FluentIcons.graph_ChromeMaximize
ToolTip.visible: hovered
ToolTip.text: control.maximizeUsesRestoreIcon ? qsTr("Restore") : qsTr("Maximized")
ToolTip.delay: Theme.tooltipDelay
backgroundColor: {
if(maximizeButton.down){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(maximizeButton.hover){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
onClicked: {
control.maximizeButtonClicked()
}
}
IconButton{
id: closeButton
implicitWidth: control.heightWhenVisible
implicitHeight: control.heightWhenVisible
radius: 0
icon.width: 10
icon.height: 10
enabled: control.closeButtonEnabled
icon.name: FluentIcons.graph_ChromeClose
SmoothUI.textColor: closeButton.hovered ? Colors.white : control.SmoothUI.theme.res.textFillColorPrimary
ToolTip.visible: hovered
ToolTip.text: qsTr("Close")
ToolTip.delay: Theme.tooltipDelay
backgroundColor: {
if(closeButton.pressed){
return Colors.red.dark()
}
if(closeButton.hovered){
return Colors.red.light()
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
onClicked: {
control.closeButtonClicked();
}
}
}
}
