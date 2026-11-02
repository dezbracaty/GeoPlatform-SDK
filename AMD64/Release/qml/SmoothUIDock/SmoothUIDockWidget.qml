import QtQuick
import SmoothUI.impl
import SmoothUI.Controls
Item {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
readonly property QtObject dockWidgetCpp: parent
anchors.fill: parent
}
