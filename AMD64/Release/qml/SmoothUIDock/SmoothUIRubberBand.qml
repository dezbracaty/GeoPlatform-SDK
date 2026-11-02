import QtQuick
import SmoothUI.Controls
import SmoothUI.impl
Rectangle {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property var primaryColor: accentColor?.defaultBrushFor(control.SmoothUI.dark)??"#00000000"
color: Colors?.withOpacity(primaryColor,0.3)??"#00000000"
radius: control.SmoothUI.radius
border {
color: primaryColor
width: Theme.borderWidth
}
anchors.fill: parent
}
