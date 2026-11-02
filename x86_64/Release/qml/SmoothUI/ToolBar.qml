/*!
\qmltype ToolBar
\inqmlmodule SmoothUI
\brief A Fluent-styled toolbar container.
Wraps \l T.ToolBar with SmoothUI theme integration.
Provides a horizontal bar for grouping action controls.
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import SmoothUI.impl
import SmoothUI.Controls
T.ToolBar {
id: control
property string groupName: ""
property var toolbarModel: []
property int buttonSize: Theme.toolbarButtonSize
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
padding: 4
spacing: 4
background: Item {
implicitHeight: control.buttonSize + control.padding * 2
}
contentItem: RowLayout {
spacing: control.spacing
Repeater {
model: control.toolbarModel
delegate: Loader {
id: itemLoader
property var itemData: modelData
sourceComponent: {
if (itemData.separator) {
return separatorComponent;
} else {
return buttonComponent;
}
}
Component {
id: buttonComponent
ToolBarButton {
menuItem: itemLoader.itemData
buttonSize: control.buttonSize
}
}
Component {
id: separatorComponent
ToolBarSeparator {
orientation: Qt.Vertical
}
}
}
}
}
Connections {
target: MenuData
function onEnvironmentChanged(newEnvironment) {
console.log("ToolBar: Environment changed to", newEnvironment, "- refreshing toolbar")
control.refreshToolbar()
}
}
function refreshToolbar() {
if (groupName.length > 0) {
var group = MenuData.getGroup(groupName);
toolbarModel = group ? group.items : [];
} else {
toolbarModel = [];
}
}
Component.onCompleted: {
refreshToolbar()
}
}
