/*!
\qmltype Menu
\inqmlmodule SmoothUI
\brief A Fluent-styled popup menu with animated height reveal.
Wraps \l T.Menu with SmoothUI theme integration.
Provides a styled dropdown menu with rounded corners, shadow,
and a smooth vertical scale animation on open/close.
*/
import QtQuick
import QtQuick.Window
import QtQuick.Templates as T
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
T.Menu {
id: control
SmoothUI.theme: Theme.of(control)
property var iconSource: ""
property var isMenu
property var subMenuModel: []
property var view
SmoothUI.radius: Theme.popupRadius
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
margins: 0
verticalPadding: 3
horizontalPadding: 3
overlap: 10
focus: false
delegate: MenuItem {}
contentItem: Item {
implicitHeight: list_content.height
clip: enter.running ? true : false
Rectangle {
id: layout_container
property var window: Window.window
width: parent.width
height: parent.height
radius: control.SmoothUI.radius
border.width: 1
color: control.SmoothUI.theme.res.popupBackgroundColor
border.color: control.SmoothUI.theme.res.popupBorderColor
Shadow {
radius: control.SmoothUI.radius
}
ListView {
id: list_content
width: parent.width
height: Math.min(contentHeight, control.SmoothUI.minimumHeight)
model: control.contentModel
interactive: Window.window ? contentHeight + control.topPadding + control.bottomPadding > control.height : false
clip: true
anchors.verticalCenter: parent.verticalCenter
currentIndex: control.currentIndex
ScrollBar.vertical: ScrollBar {}
boundsBehavior: ListView.StopAtBounds
}
}
}
property real __heightScale: 1
height: __heightScale * implicitHeight
enter: Transition {
NumberAnimation { property: "__heightScale"; from: 0.33; to: 1; easing.type: Easing.OutCubic; duration: 250 }
}
background: Item{
implicitWidth: 200
implicitHeight: 0
}
T.Overlay.modal: Rectangle {
Behavior on opacity {
NumberAnimation {
duration: 83
}
}
}
T.Overlay.modeless: Rectangle {
Behavior on opacity {
NumberAnimation {
duration: 83
}
}
}
Instantiator {
model: {
return subMenuModel;
}
delegate: QtObject {
property var subMenuModel: modelData
property var parent: control
property var value
//     console.log(title,"Instantiator onCompleted",modelData.text)//ClearHistory1
}
onObjectAdded: (index, object) => {
if (object.subMenuModel.separator) {
var component = Qt.createComponent("MenuSeparator.qml");
if (component.status === Component.Ready) {
var separator = component.createObject(object.parent.contentItem);
object.value = separator;
control.insertItem(index, separator);
}
} else if (object.subMenuModel.isMenu) {
component = Qt.createComponent("Menu.qml");
if (component.status === Component.Ready) {
var menu = component.createObject(object.parent.contentItem, {
subMenuModel: object.subMenuModel.items,
view: control.view,
title: object.subMenuModel.text
});
object.value = menu;
control.insertMenu(index, menu);
}
} else {
component = Qt.createComponent("MenuItem.qml");
if (component.status === Component.Ready) {
var item = component.createObject(object.parent.contentItem, {
subMenuModel: object.subMenuModel,
view: control.view,
text: object.subMenuModel.text
});
object.value = item;
control.insertItem(index, item);
}
}
}
onObjectRemoved: (index, object) => {
if (object.isExpander) {
control.removeMenu(object.value);
} else {
control.removeItem(object.value);
}
}
}
}
