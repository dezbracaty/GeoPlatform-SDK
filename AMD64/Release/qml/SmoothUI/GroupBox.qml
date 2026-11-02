/*!
\qmltype GroupBox
\inqmlmodule SmoothUI
\brief A Fluent-styled group box with title label.
Wraps \l T.GroupBox with SmoothUI theme integration.
Provides a titled framed section with rounded border.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.GroupBox {
id: control
SmoothUI.theme: Theme.of(control)
SmoothUI.radius: Theme.panelRadius
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding,
implicitLabelWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
spacing: Theme.contentSpacing
padding: Theme.space16
font: Typography.subtitle
topPadding: padding + (implicitLabelWidth > 0 ? implicitLabelHeight + spacing : 0)
label: Label {
width: control.availableWidth
text: control.title
font: control.font
elide: Text.ElideRight
verticalAlignment: Text.AlignVCenter
}
background: Rectangle {
y: control.topPadding - control.bottomPadding
width: parent.width
height: parent.height - control.topPadding + control.bottomPadding
radius: control.SmoothUI.radius
color: control.SmoothUI.theme.res.cardBackgroundColor
border.width: 1
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
