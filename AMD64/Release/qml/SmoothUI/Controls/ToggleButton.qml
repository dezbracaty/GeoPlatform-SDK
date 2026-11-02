import QtQuick
import QtQuick.Controls
import SmoothUI.impl
import SmoothUI.Controls
/*!
\qmltype ToggleButton
\inqmlmodule SmoothUI.Controls
\brief A button that toggles between checked/unchecked states
*/
StandardButton {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
highlighted: checked
}
