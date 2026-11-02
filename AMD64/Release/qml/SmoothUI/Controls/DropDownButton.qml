/*!
\qmltype DropDownButton
\inqmlmodule SmoothUI.Controls
\brief A button that opens a dropdown menu on click.
Provides a StandardButton with a chevron icon that toggles
a popup menu, supporting arbitrary menu content.
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
default property alias contentData: menu.contentData
property alias menu: menu
icon.name: FluentIcons.graph_ChevronDown
icon.width: 12
icon.height: 12
spacing: Theme.contentSpacing
iconMirrored: true
onClicked: {
menu.popup(control,0,control.height)
}
Menu {
id: menu
dim: true
modal: true
width: parent.width
SmoothUI.minimumHeight: control.SmoothUI.minimumHeight
Overlay.modal: Item{}
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
}
}
