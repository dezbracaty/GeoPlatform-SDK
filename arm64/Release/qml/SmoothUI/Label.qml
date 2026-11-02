/*!
\qmltype Label
\inqmlmodule SmoothUI
\brief A Fluent-styled text label with theme colors.
Wraps \l T.Label with SmoothUI theme integration.
Provides primary text color and accent link color.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Label {
id: control
SmoothUI.theme: Theme.of(control)
color: control.SmoothUI.theme.res.textFillColorPrimary
linkColor: control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark)
font: Typography.body
renderType: Theme.textRender
}
