/*!
\qmltype ToolTip
\inqmlmodule SmoothUI
\brief A Fluent-styled tooltip popup with shadow.
Wraps \l T.ToolTip with SmoothUI theme integration.
Provides a rounded tooltip with themed background and shadow.
*/
import QtQuick
import SmoothUI.Controls
import QtQuick.Templates as T
import SmoothUI.impl
T.ToolTip {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.radius: Theme.popupRadius
x: parent ? (parent.width - implicitWidth) / 2 : 0
y: -implicitHeight - 3
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
margins: 6
leftPadding: Theme.space12
rightPadding: Theme.space12
topPadding: Theme.space8
bottomPadding: Theme.space8
closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent
font: Typography.body
contentItem: Label {
text: control.text
font: control.font
wrapMode: Text.Wrap
}
background: Rectangle {
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
color: control.SmoothUI.theme.res.solidBackgroundFillColorQuarternary
radius: control.SmoothUI.radius
Shadow{
radius: control.SmoothUI.radius
}
}
}
