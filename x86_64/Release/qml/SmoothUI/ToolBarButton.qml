import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
IconButton {
id: control
property var menuItem: null
property bool hasMenu: menuItem ? menuItem.isMenu : false
property string iconName: menuItem ? menuItem.iconSource : ""
property string tooltipText: menuItem ? menuItem.text : ""
property string actionCode: menuItem ? menuItem.actionCode : ""
property bool showDropdownArrow: hasMenu
property int buttonSize: Theme.toolbarButtonSize
implicitWidth: showDropdownArrow ? buttonSize + dropdownArrow.width + 4 : buttonSize
implicitHeight: buttonSize
icon.source: iconName ? FluentIcons["graph_" + iconName] ?? "" : ""
icon.width: 18
icon.height: 18
enabled: menuItem ? menuItem.enabled : true
ToolTip.visible: hovered && tooltipText.length > 0
ToolTip.text: tooltipText
ToolTip.delay: 500
Icon {
id: dropdownArrow
visible: control.showDropdownArrow
anchors.right: parent.right
anchors.rightMargin: 2
anchors.verticalCenter: parent.verticalCenter
source: FluentIcons.graph_ChevronDown
width: 10
height: 10
color: control.SmoothUI.textColor
}
Menu {
id: dropdownMenu
visible: false
y: control.height + 2
subMenuModel: {
if (control.menuItem && control.menuItem.isMenu) {
return control.menuItem.items;
}
return [];
}
}
onClicked: {
if (hasMenu) {
dropdownMenu.popup(0, control.height + 2);
} else if (menuItem) {
menuItem.onTriggered();
}
}
}
