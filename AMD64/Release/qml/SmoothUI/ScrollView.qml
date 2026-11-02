import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ScrollView {
id: control
SmoothUI.theme: Theme.of(control)
clip: true
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
T.ScrollBar.vertical: ScrollBar {
parent: control
x: control.mirrored ? 0 : control.width - width
y: control.topPadding
height: control.availableHeight
active: control.ScrollBar.horizontal.active
}
T.ScrollBar.horizontal: ScrollBar {
parent: control
x: control.leftPadding
y: control.height - height
width: control.availableWidth
active: control.ScrollBar.vertical.active
}
}
