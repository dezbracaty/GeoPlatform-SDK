/*!
\qmltype MenuSeparator
\inqmlmodule SmoothUI
\brief A Fluent-styled horizontal menu separator line.
Wraps \l T.MenuSeparator with SmoothUI theme integration.
Renders a themed divider line.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.MenuSeparator {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
verticalPadding: 2
contentItem: Rectangle {
implicitWidth: 200
implicitHeight: 1
color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
