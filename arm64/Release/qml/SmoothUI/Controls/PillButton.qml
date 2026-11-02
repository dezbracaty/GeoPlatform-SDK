/*!
\qmltype PillButton
\inqmlmodule SmoothUI.Controls
\brief A pill/rounded style button for compact actions.
Provides a fully rounded (pill-shaped) button variant based
on StandardButton for tag-like or compact action buttons.
*/
import QtQuick
import SmoothUI.impl
import SmoothUI.Controls
StandardButton {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
SmoothUI.radius: height/2
}
