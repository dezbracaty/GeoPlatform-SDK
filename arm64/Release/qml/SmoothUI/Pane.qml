/*!
\qmltype Pane
\inqmlmodule SmoothUI
\brief A Fluent-styled pane container with themed background.
Wraps \l T.Pane with SmoothUI theme integration.
Provides a bordered container with mica background color.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Pane {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.radius: Theme.panelRadius
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
padding: Theme.space16
background: Frame {
enabled: false
padding: 0
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
SmoothUI.radius: control.SmoothUI.radius
}
}
