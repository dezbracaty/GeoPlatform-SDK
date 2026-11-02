/*!
\qmltype VerticalHeaderView
\inqmlmodule SmoothUI
\brief A Fluent-styled vertical row header view for tables.
Wraps \l T.VerticalHeaderView with SmoothUI theme integration.
Provides styled row header cells for table views.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.VerticalHeaderView {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(1, contentWidth)
implicitHeight: syncView ? syncView.height : 0
delegate: Rectangle {
id: delegate
required property var model
readonly property real cellPadding: 8
implicitWidth: Math.max(control.width, text.implicitWidth + (cellPadding * 2))
implicitHeight: text.implicitHeight + (cellPadding * 2)
color: control.SmoothUI.theme.res.micaBackgroundColor
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
Label {
id: text
text: delegate.model[control.textRole]
width: delegate.width
height: delegate.height
horizontalAlignment: Text.AlignHCenter
verticalAlignment: Text.AlignVCenter
}
}
}
