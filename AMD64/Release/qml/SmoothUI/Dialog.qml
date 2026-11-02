/*!
\qmltype Dialog
\inqmlmodule SmoothUI
\brief A Fluent-styled dialog popup with title, content, and footer.
Wraps \l T.Dialog with SmoothUI theme integration.
Provides overlay backdrop, enter/exit animations, and
styled title bar and footer button area.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Dialog {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding,
implicitHeaderWidth,
implicitFooterWidth)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding
+ (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
+ (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))
padding: Theme.dialogPadding
horizontalPadding: Theme.space16 + Theme.space4
SmoothUI.radius: Theme.dialogRadius
background: Rectangle {
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
radius: control.SmoothUI.radius
}
enter: Transition {
NumberAnimation {
property: "opacity"
from: 0.0
to: 1.0
duration: Theme.fasterAnimationDuration
}
NumberAnimation {
property: "scale"
from: 0.8
to: 1.0
duration: Theme.fastAnimationDuration
}
}
exit: Transition {
NumberAnimation {
property: "opacity"
from: 1.0
to: 0.0
duration: Theme.fasterAnimationDuration
}
}
header: Label {
text: control.title
visible: control.title
elide: Label.ElideRight
font: Typography.subtitle
leftPadding: control.leftPadding
rightPadding: control.rightPadding
topPadding: Theme.dialogPadding
bottomPadding: Theme.dialogPadding
background: Rectangle {
x: 1; y: 1
width: parent.width - 2
height: parent.height - 1
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
radius: control.SmoothUI.radius
Rectangle {
anchors.left: parent.left
anchors.right: parent.right
anchors.bottom: parent.bottom
height: Theme.borderWidth
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
}
footer: DialogButtonBox {
SmoothUI.radius: control.SmoothUI.radius
visible: count > 0
}
T.Overlay.modal: Rectangle {
color: control.SmoothUI.theme.res.smokeFillColorDefault
}
T.Overlay.modeless: Rectangle {
color: Colors.withOpacity(Colors.black, 0.15)
}
}
