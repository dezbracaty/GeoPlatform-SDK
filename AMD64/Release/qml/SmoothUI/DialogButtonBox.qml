/*!
\qmltype DialogButtonBox
\inqmlmodule SmoothUI
\brief A Fluent-styled dialog button row with role-based highlighting.
Wraps \l T.DialogButtonBox with SmoothUI theme integration.
Buttons with AcceptRole/YesRole/ApplyRole are automatically
highlighted as the primary action.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.DialogButtonBox {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
contentWidth: (contentItem as ListView).contentWidth
spacing: Theme.space8
padding: Theme.space12
horizontalPadding: Theme.space16 + Theme.space4
alignment: Qt.AlignRight
buttonLayout: DialogButtonBox.GnomeLayout
SmoothUI.radius: Theme.dialogRadius
property var __highlighted : [DialogButtonBox.AcceptRole,DialogButtonBox.YesRole,DialogButtonBox.ApplyRole]
delegate: StandardButton {
implicitWidth: Math.max(76, implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
forceHighlighted: __highlighted.indexOf(DialogButtonBox.buttonRole) !== -1
}
contentItem: ListView {
implicitWidth: contentWidth
model: control.contentModel
spacing: control.spacing
orientation: ListView.Horizontal
boundsBehavior: Flickable.StopAtBounds
snapMode: ListView.SnapToItem
}
background: RoundRectangle {
implicitHeight: Theme.actionHeight
x: 1; y: 1
width: parent.width - 2
height: parent.height - 2
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
radius: [0, 0, control.SmoothUI.radius, control.SmoothUI.radius]
Rectangle {
anchors.left: parent.left
anchors.right: parent.right
anchors.top: parent.top
height: Theme.borderWidth
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
}
