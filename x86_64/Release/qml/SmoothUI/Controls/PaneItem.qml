/*!
\qmltype PaneItem
\inqmlmodule SmoothUI.Controls
\brief An item in a navigation pane.
Provides a navigation pane entry with title, tap/right-tap
signals, and configurable interaction behavior.
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
property Component infoBadge
property int count: 0
property bool visible: true
property var key
property alias icon: d.icon
property string iconFamily: FluentIcons.fontLoader.name
property var iconColor: undefined
property bool enabled: true
property bool __footer: false
property var __parent
property var __index
property Action __action: Action{
id: d
icon.width: 16
icon.height: 16
}
}
