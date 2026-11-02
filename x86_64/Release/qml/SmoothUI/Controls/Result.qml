/*!
\qmltype Result
\inqmlmodule SmoothUI.Controls
\brief Displays an operation result with status icon and message.
Provides a result display with icon, title, description, and
action button. Supports Info, Success, Warning, Error, and
HTTP status modes.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmoothUI.impl
import SmoothUI.Controls
Item {
id: control
SmoothUI.theme: Theme.of(control)
property int status: ResultType.Info
property string title: ""
property string subTitle: ""
property int httpStatusCode: 404
property Component icon
property Component extra
implicitWidth: column_layout.implicitWidth + leftPadding + rightPadding
implicitHeight: column_layout.implicitHeight + topPadding + bottomPadding
property int topPadding: 20
property int bottomPadding: 20
property int leftPadding: 0
property int rightPadding: 0
QtObject {
id: d
property color iconColor: {
if (control.status === ResultType.Success) return control.SmoothUI.theme.res.systemFillColorSuccess
if (control.status === ResultType.Error) return control.SmoothUI.theme.res.systemFillColorCritical
if (control.status === ResultType.Warning) return control.SmoothUI.theme.res.systemFillColorCaution
return control.SmoothUI.theme.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
property string iconName: {
if (control.status === ResultType.Success) return FluentIcons.graph_CompletedSolid
if (control.status === ResultType.Error) return FluentIcons.graph_StatusErrorFull
if (control.status === ResultType.Warning) return FluentIcons.graph_Warning
return FluentIcons.graph_InfoSolid
}
property bool showStatusIcon: {
return control.status !== ResultType.None
}
}
Component {
id: comp_status_icon
Icon {
source: d.iconName
color: d.iconColor
width: 48
height: 48
}
}
Component {
id: comp_http_status
Label {
font: Typography.display
text: control.httpStatusCode.toString()
color: control.SmoothUI.theme.res.textFillColorPrimary
}
}
ColumnLayout {
id: column_layout
anchors.fill: parent
AutoLoader {
id: loader_icon
Layout.alignment: Qt.AlignHCenter
sourceComponent: {
if (control.icon) return control.icon
if (!d.showStatusIcon) return undefined
if (control.status === ResultType.HttpStatus) return comp_http_status
return comp_status_icon
}
visible: status === Loader.Ready
}
Label {
Layout.alignment: Qt.AlignHCenter
Layout.topMargin: 16
visible: control.title !== ""
font: Typography.subtitle
text: control.title
color: control.SmoothUI.theme.res.textFillColorPrimary
}
Label {
Layout.alignment: Qt.AlignHCenter
Layout.topMargin: 4
visible: control.subTitle !== ""
font: Typography.body
text: control.subTitle
color: control.SmoothUI.theme.res.textFillColorSecondary
}
AutoLoader {
id: loader_extra
Layout.alignment: Qt.AlignHCenter
Layout.topMargin: 20
sourceComponent: control.extra
visible: control.extra
}
}
}
