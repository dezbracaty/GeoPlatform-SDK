/*!
\qmltype PageIndicator
\inqmlmodule SmoothUI
\brief A Fluent-styled page indicator with caterpillar slide animation.
Wraps \l T.PageIndicator with SmoothUI theme integration.
Animates a pill-shaped indicator that stretches and slides
between page dots with a smooth caterpillar motion.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.PageIndicator {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
padding: 6
spacing: 6
contentItem: Item {
id: d_content
implicitWidth: Math.max(0, control.count * (8 + control.spacing) - control.spacing)
implicitHeight: 8
Row {
spacing: control.spacing
Repeater {
model: control.count
delegate: Item {
implicitWidth: 8
implicitHeight: 8
Rectangle {
anchors.centerIn: parent
width: 8
height: 8
radius: width / 2
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
opacity: 0.45
}
TapHandler {
enabled: control.interactive
onTapped: control.currentIndex = index
}
}
}
}
Rectangle {
id: pill
width: 8
height: 8
radius: height / 2
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
opacity: 0.95
z: 1
visible: control.count > 0
}
SequentialAnimation {
id: anim_caterpillar
ParallelAnimation {
PropertyAnimation {
id: anim_stretch_w
target: pill
property: "width"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
PropertyAnimation {
id: anim_stretch_x
target: pill
property: "x"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
ParallelAnimation {
PropertyAnimation {
id: anim_shrink_w
target: pill
property: "width"
to: 8
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
PropertyAnimation {
id: anim_move_x
target: pill
property: "x"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
function animateToIndex() {
if (!__initialized || control.count === 0)
return
var newX = control.currentIndex * (8 + control.spacing)
var dist = newX - pill.x
if (Math.abs(dist) < 0.01)
return
var absDist = Math.abs(dist)
var anim_stretch_width = 8 + absDist
if (dist > 0) {
anim_stretch_w.to = anim_stretch_width
anim_stretch_x.to = pill.x
} else {
anim_stretch_w.to = anim_stretch_width
anim_stretch_x.to = pill.x - absDist
}
anim_move_x.to = newX
anim_caterpillar.restart()
}
property bool __initialized: false
Connections {
target: control
function onCurrentIndexChanged() {
d_content.animateToIndex()
}
}
Component.onCompleted: {
pill.x = control.currentIndex * (8 + control.spacing)
__initialized = true
}
}
}
