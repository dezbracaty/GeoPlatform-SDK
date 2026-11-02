/*!
\qmltype Tumbler
\inqmlmodule SmoothUI
\brief A Fluent-styled tumbler/picker wheel with smooth scrolling.
Wraps \l T.Tumbler with SmoothUI theme integration.
Provides a spinning wheel selector with delegate styling
and mouse wheel support.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import SmoothUI.impl
import SmoothUI.Controls
import QtQuick.Templates as T
T.Tumbler {
id: control
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
SmoothUI.highlightMoveDuration: Theme.fastAnimationDuration
delegate: Label {
text: modelData
color: control.visualFocus ? control.palette.highlight : control.palette.text
font: control.font
opacity: 1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount / 2)
horizontalAlignment: Label.AlignHCenter
verticalAlignment: Label.AlignVCenter
required property var modelData
required property int index
}
Component.onCompleted: {
if (control.currentItem.parent.parent instanceof ListView) {
control.currentItem.parent.parent.highlightMoveDuration = SmoothUI.highlightMoveDuration
control.currentItem.parent.parent.boundsBehavior = ListView.StopAtBounds
}
if (control.currentItem.parent instanceof PathView) {
control.currentItem.parent.highlightMoveDuration = SmoothUI.highlightMoveDuration
}
}
contentItem: TumblerView {
implicitWidth: 60
implicitHeight: 200
model: control.model
delegate: control.delegate
path: Path {
startX: control.contentItem.width / 2
startY: -control.contentItem.delegateHeight / 2
PathLine {
x: control.contentItem.width / 2
y: (control.visibleItemCount + 1) * control.contentItem.delegateHeight - control.contentItem.delegateHeight / 2
}
}
property real delegateHeight: control.availableHeight / control.visibleItemCount
}
WheelHandler {
onWheel: (event) => {
if (control.currentItem.parent instanceof PathView) {
if (event.angleDelta.y > 0) {
control.currentItem.parent.decrementCurrentIndex()
} else {
control.currentItem.parent.incrementCurrentIndex()
}
}
}
}
}
