/*!
\qmltype ScrollBar
\inqmlmodule SmoothUI
\brief A Fluent-styled scroll bar with auto-hide and navigation buttons.
Wraps \l T.ScrollBar with SmoothUI theme integration.
Features expand-on-hover behavior, directional scroll buttons,
and animated state transitions.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ScrollBar {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
padding: 2
visible: control.policy !== T.ScrollBar.AlwaysOff && control.size < 1.0 && control.enabled
minimumSize: 0.08
QtObject{
id: d
property color scrollbarColor: control.SmoothUI.theme.res.textFillColorTertiary
property color hoverScrollbarColor: control.SmoothUI.theme.res.textFillColorSecondary
property bool buttonVisible: Number(control.contentItem.implicitWidth) === 6
}
verticalPadding : vertical ? padding+12 : padding
horizontalPadding : horizontal ? padding+12 : padding
contentItem: Rectangle {
implicitWidth: 2
implicitHeight: 2
radius: width / 2
color: d.scrollbarColor
states: State {
name: "active"
when: control.policy === T.ScrollBar.AlwaysOn || (control.active && control.size < 1.0)
PropertyChanges {
control.contentItem.implicitWidth: 6
control.contentItem.implicitHeight: 6
}
}
transitions: [
Transition {
from: "active"
SequentialAnimation {
PauseAnimation { duration: Theme.slowAnimationDuration }
NumberAnimation { target: control.contentItem; duration: Theme.fastAnimationDuration; properties: "implicitWidth,implicitHeight"; to: 2 }
}
},
Transition {
to: "active"
SequentialAnimation {
PauseAnimation { duration: Theme.fastAnimationDuration }
NumberAnimation { target: control.contentItem; duration: Theme.fastAnimationDuration; properties: "implicitWidth,implicitHeight"; to: 6 }
}
}
]
}
background: Rectangle{
opacity: control.active
color: control.SmoothUI.theme.res.controlFillColorDefault
radius: 5
Behavior on opacity {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
MouseArea{
width: 8
height: 8
visible: d.buttonVisible && control.vertical
hoverEnabled: true
anchors{
horizontalCenter: parent.horizontalCenter
top: parent.top
topMargin: 4
}
Icon{
anchors.fill: parent
scale: parent.pressed ? 0.85 : 1
color: parent.containsMouse ? d.hoverScrollbarColor : d.scrollbarColor
source: FluentIcons.graph_CaretUpSolid8
}
onClicked: {
control.decrease()
}
}
MouseArea{
width: 8
height: 8
visible: d.buttonVisible && control.vertical
hoverEnabled: true
anchors{
horizontalCenter: parent.horizontalCenter
bottom: parent.bottom
bottomMargin: 4
}
Icon{
anchors.fill: parent
scale: parent.pressed ? 0.85 : 1
color: parent.containsMouse ? d.hoverScrollbarColor : d.scrollbarColor
source: FluentIcons.graph_CaretDownSolid8
}
onClicked: {
control.increase()
}
}
MouseArea{
width: 8
height: 8
visible: d.buttonVisible && control.horizontal
hoverEnabled: true
anchors{
verticalCenter: parent.verticalCenter
left: parent.left
leftMargin: 4
}
Icon{
anchors.fill: parent
scale: parent.pressed ? 0.85 : 1
color: parent.containsMouse ? d.hoverScrollbarColor : d.scrollbarColor
source: FluentIcons.graph_CaretLeftSolid8
}
onClicked: {
control.decrease()
}
}
MouseArea{
width: 8
height: 8
visible: d.buttonVisible && control.horizontal
hoverEnabled: true
anchors{
verticalCenter: parent.verticalCenter
right: parent.right
rightMargin: 4
}
Icon{
anchors.fill: parent
scale: parent.pressed ? 0.85 : 1
color: parent.containsMouse ? d.hoverScrollbarColor : d.scrollbarColor
source: FluentIcons.graph_CaretRightSolid8
}
onClicked: {
control.increase()
}
}
}
