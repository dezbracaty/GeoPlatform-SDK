import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
ContentPage {
id: control
default property alias content: container.data
property alias headerContent: headerLoader.sourceComponent
property int columnSpacing: 0
padding: 0
leftPadding: 24
rightPadding: 24
ColumnLayout {
anchors.fill: parent
spacing: 0
Loader {
id: headerLoader
Layout.fillWidth: true
Layout.preferredHeight: item ? item.implicitHeight : 0
Layout.leftMargin: control.leftPadding
Layout.rightMargin: control.rightPadding
}
Item {
Layout.fillWidth: true
Layout.fillHeight: true
Flickable {
id: content
anchors.fill: parent
clip: true
ScrollBar.vertical: scrollbar
boundsBehavior: Flickable.StopAtBounds
contentHeight: container.height
ColumnLayout {
spacing: control.columnSpacing
id: container
width: parent.width
anchors.topMargin: 24
anchors.bottomMargin: 24
}
}
ScrollBar {
id: scrollbar
anchors {
top: parent.top
bottom: parent.bottom
right: parent.right
rightMargin: 4
}
}
}
}
}
