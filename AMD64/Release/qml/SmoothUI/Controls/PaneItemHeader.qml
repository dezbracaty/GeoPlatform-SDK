/*!
\qmltype PaneItemHeader
\inqmlmodule SmoothUI.Controls
\brief A section header label in a navigation pane.
Provides a text header used to label groups of navigation
items with visibility and position tracking.
*/
import QtQuick
import SmoothUI.impl
Objects {
id: control
property string title
property bool visible: true
property bool __footer: false
property var __parent
property var __index
}
