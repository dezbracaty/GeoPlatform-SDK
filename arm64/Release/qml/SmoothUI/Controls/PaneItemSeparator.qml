/*!
\qmltype PaneItemSeparator
\inqmlmodule SmoothUI.Controls
\brief A visual separator between navigation pane items.
Provides a thin divider line used to visually separate groups
of navigation items with visibility control.
*/
import QtQuick
import SmoothUI.impl
Objects {
id: control
property bool visible: true
property bool __footer: false
property var __parent
property var __index
}