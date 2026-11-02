/*!
\qmltype Frame
\inqmlmodule SmoothUI
\brief A Fluent-styled frame container with rounded border.
Wraps \l T.Frame with SmoothUI theme integration, providing
a styled bordered container with scaffold background color.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Frame {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.radius: Theme.panelRadius
property alias color: surface.color
property alias border: surface.border
property alias radius: surface.radius
property int elevation: 0
property real shadowOpacity: 0.16
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
background: Rectangle {
id: surface
radius: control.SmoothUI.radius
color: control.SmoothUI.theme.res.cardBackgroundColor
border.width: Theme.borderWidth
border.color: control.SmoothUI.theme.res.surfaceStrokeColorDefault
Shadow {
visible: control.elevation > 0
radius: surface.radius
elevation: control.elevation
opacity: Theme.shadowOpacityFor(control.SmoothUI.dark, control.shadowOpacity)
}
}
}
