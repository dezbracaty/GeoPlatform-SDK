/*!
\qmltype PaneItemExpander
\inqmlmodule SmoothUI.Controls
\brief An expandable section header in a navigation pane.
Provides a group header with tap/right-tap interaction, icon,
and title for expandable navigation sections.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
Objects {
id: control
signal tap
signal rightTap()
property var canTap
property string title
property int iconSpacing: 14
property alias icon: d.icon
property var iconColor: undefined
property var key
property string iconFamily: FluentIcons.fontLoader.name
property bool visible: true
property bool enabled: true
property bool __expanded: false
property var __parent
property var __index
property Action __action: Action{
id: d
icon.width: 16
icon.height: 16
}
property int count: {
var sum = 0
for(var i=0;i<children.length;i++){
var item = children[i]
if(item instanceof PaneItem || item instanceof PaneItemExpander){
sum = sum + item.count
}
}
return sum
}
}
