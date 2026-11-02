/*!
\qmltype Popup
\inqmlmodule SmoothUI
\brief A Fluent-styled popup with overlay backdrop.
Wraps \l T.Popup with SmoothUI theme integration.
Provides rounded popup with colored overlay for both
modal and modeless modes.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Popup {
id: control
SmoothUI.theme: Theme.of(control)
property int elevation: 0
property real shadowOpacity: 0.16
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
padding: Theme.popupPadding
SmoothUI.radius: Theme.popupRadius
background: Frame {
enabled: false
padding: 0
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
SmoothUI.radius: control.SmoothUI.radius
color: control.SmoothUI.theme.res.popupBackgroundColor
border.color: control.SmoothUI.theme.res.popupBorderColor
elevation: control.elevation
shadowOpacity: control.shadowOpacity
}
T.Overlay.modal: Rectangle {
color: control.SmoothUI.theme.res.smokeFillColorDefault
}
T.Overlay.modeless: Rectangle {
color: Colors.withOpacity(Colors.black, 0.15)
}
}
