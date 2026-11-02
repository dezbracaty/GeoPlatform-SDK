/*!
\qmltype MenuBar
\inqmlmodule SmoothUI
\brief A Fluent-styled menu bar for top-level menus.
Wraps \l T.MenuBar with SmoothUI theme integration.
Arranges MenuBarItem delegates horizontally with spacing.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI
import SmoothUI.Controls
import SmoothUI.impl
T.MenuBar {
id: control
property string groupName: "Menu"
property var menusModel: []
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
delegate: MenuBarItem { }
spacing: 8
contentItem: Row {
spacing: control.spacing
Repeater {  // workaround for https://bugreports.qt.io/browse/QTBUG-68464
model: control.contentModel
}
}
background: Item {
implicitHeight: 40
}
Connections {
target: MenuData
function onEnvironmentChanged(newEnvironment) {
control.refreshMenus()
}
}
function refreshMenus() {
var group = MenuData.getGroup(groupName)
menusModel = []
menusModel = group ? group.items : []
}
Component.onCompleted: {
refreshMenus()
}
Instantiator {
property var isMenu: false
model: control.menusModel
delegate:
Menu {
id: menuitem
title: modelData.text
property string topLevelIconSource: modelData.iconSource || ""
property string topLevelDisplayMode: modelData.displayMode || "TextOnly"
isMenu:
{
return modelData.isMenu
}
Instantiator {
model: modelData.items
delegate: QtObject {
Component.onCompleted: {
if (modelData.separator) {
let newSeparator = menuSeparatorDelegate.createObject(menuitem.contentItem);
menuitem.addItem(newSeparator);
} else if (modelData.isMenu) {
let newMenu = menuDelegate.createObject(menuitem.contentItem, {
title: modelData.text,
iconSource: FluentIcons[modelData.iconSource],
subMenuModel: modelData.items,
});
menuitem.addMenu(newMenu);
} else {
let newItem = menuItemDelegate.createObject(menuitem.contentItem, {
text: modelData.text,
localIconSource: FluentIcons[modelData.iconSource] ? FluentIcons[modelData.iconSource] : "",
tmenu: modelData
});
menuitem.addItem(newItem);
}
}
}
Component {
id: menuDelegate
Menu {
}
}
Component {
id: menuItemDelegate
MenuItem {
}
}
Component {
id: menuSeparatorDelegate
MenuSeparator {
}
}
}
}
onObjectAdded: (index, object) =>
{
if( object.isMenu)
control.addMenu(object)
}
onObjectRemoved: (index, object) =>
{
if( object.isMenu)
control.removeMenu(object)
}
}
}