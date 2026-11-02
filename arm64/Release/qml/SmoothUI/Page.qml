/*!
\qmltype Page
\inqmlmodule SmoothUI
\brief A Fluent-styled page container with title header.
Wraps \l T.Page with SmoothUI theme integration.
Provides a content page with automatic header label
for the page title.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Page {
id: control
SmoothUI.theme: Theme.of(control)
spacing: 0
SmoothUI.radius: Theme.panelRadius
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding,
implicitHeaderWidth,
implicitFooterWidth)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding
+ (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
+ (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))
background: Item{}
header: Label{
text: control.title
font: Typography.title
visible: text !== ""
topPadding: Theme.space24
leftPadding: Theme.space24
rightPadding: Theme.space24
}
padding: Theme.space24
}
