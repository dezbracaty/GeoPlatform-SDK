/*!
\qmltype HorizontalHeaderView
\inqmlmodule SmoothUI
\brief A Fluent-styled horizontal table header view.
Wraps \l T.HorizontalHeaderView with SmoothUI theme integration.
Provides styled header cells for table views.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.HorizontalHeaderView {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: syncView ? syncView.width : 0
implicitHeight: Math.max(1, contentHeight)
delegate: Rectangle {
id: delegate
required property var model
readonly property real cellPadding: 8
implicitWidth: text.implicitWidth + (cellPadding * 2)
implicitHeight: Math.max(control.height, text.implicitHeight + (cellPadding * 2))
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
