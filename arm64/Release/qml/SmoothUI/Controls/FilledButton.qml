/*!
\qmltype FilledButton
\inqmlmodule SmoothUI.Controls
\brief A prominent filled-style button with accent color background.
Provides a StandardButton variant with filled accent color
background for primary actions, following Fluent Design's
filled button style.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
import SmoothUI.Controls
StandardButton {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
forceHighlighted: true
}
