import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ToolSeparator {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
horizontalPadding: 6
verticalPadding: 4
contentItem: Rectangle {
implicitWidth: control.vertical ? 1 : 12
implicitHeight: control.vertical ? 12 : 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
