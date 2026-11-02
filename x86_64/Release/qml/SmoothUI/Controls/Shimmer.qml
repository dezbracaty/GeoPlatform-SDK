import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Templates as T
import SmoothUI.impl
/*!
\qmltype Shimmer
\inqmlmodule SmoothUI.Controls
\brief A shimmer/skeleton loading placeholder animation.
Provides configurable shimmer animation effects for loading states.
Supports multiple animation styles: \c ShimmerType.Slide (default),
\c ShimmerType.Pulse, and \c ShimmerType.Solid.
*/
Item {
id: control
clip: true
SmoothUI.theme: Theme.of(control)
property bool running: true
//!     The animation duration is computed from this value and the window width,
//!     control size. Default: 1500.
property real speed: 1500
//!     In Slide mode, derived from \c speed and the window width so the shimmer
//!     In Pulse / Solid modes, a fixed value of 1000ms is used.
readonly property int duration: {
if (d.isSlide) {
var dist = (control.Window.width || control.width) + shimmer_rect.width * 3
var spd = Math.max(1, speed)
return Math.max(1, Math.ceil(dist / spd * 1000))
}
return 1000
}
property int animationStyle: ShimmerType.Slide
property real shimmerWidth: Math.max(width, height) * 0.3
property real shimmerAngle: 20
property color baseColor: Colors.white
property color shimmerColor: Colors.withOpacity(baseColor, control.SmoothUI.dark ? 0.2 : 0.8)
property color highlightColor: Colors.withOpacity(baseColor, control.SmoothUI.dark ? 0.3 : 0.9)
readonly property real requiredHeight: {
var angleRad = shimmerAngle * Math.PI / 180
var w = control.width
var h = control.height
return Math.abs(w * Math.sin(angleRad)) + Math.abs(h * Math.cos(angleRad))
}
QtObject {
id: d
readonly property bool isSlide: control.animationStyle === ShimmerType.Slide
readonly property bool isPulse: control.animationStyle === ShimmerType.Pulse
readonly property bool isSolid: control.animationStyle === ShimmerType.Solid
}
Rectangle {
id: shimmer_rect
z: 65535
visible: d.isSlide || d.isSolid
width: control.shimmerWidth
height: control.requiredHeight * 2
x: d.isSolid ? (control.width - width) / 2 : -width
y: -height * 0.3
transform: Rotation {
origin.x: 0
origin.y: height/2
angle: control.shimmerAngle
}
gradient: Gradient {
orientation: Gradient.Horizontal
GradientStop { position: 0.0; color: "transparent" }
GradientStop { position: 0.2; color: shimmerColor }
GradientStop { position: 0.5; color: highlightColor }
GradientStop { position: 0.8; color: shimmerColor }
GradientStop { position: 1.0; color: "transparent" }
}
SequentialAnimation on x {
id: anim_slide
loops: Animation.Infinite
running: control.visible && control.running && d.isSlide
NumberAnimation {
from: -shimmer_rect.width * 1.5
to: control.width + shimmer_rect.width * 1.5
duration: control.duration
easing.type: Theme.animationCurve
}
}
SequentialAnimation on opacity {
id: anim_slide_breathing
loops: Animation.Infinite
running: control.visible && control.running && d.isSlide
NumberAnimation { from: 0.8; to: 1.0; duration: control.duration/2 }
NumberAnimation { from: 1.0; to: 0.8; duration: control.duration/2 }
}
}
Rectangle {
id: pulse_rect
z: 65535
visible: d.isPulse
anchors.fill: parent
color: control.highlightColor
opacity: 0.0
SequentialAnimation on opacity {
id: anim_pulse
loops: Animation.Infinite
running: control.visible && control.running && d.isPulse
NumberAnimation { from: 0.0; to: 0.6; duration: control.duration / 2; easing.type: Easing.InOutSine }
NumberAnimation { from: 0.6; to: 0.0; duration: control.duration / 2; easing.type: Easing.InOutSine }
}
}
}
