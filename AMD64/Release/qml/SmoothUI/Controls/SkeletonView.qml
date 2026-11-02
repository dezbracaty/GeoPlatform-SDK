import QtQuick
import QtQuick.Controls
import SmoothUI.impl
/*!
\qmltype SkeletonView
\inqmlmodule SmoothUI.Controls
\brief A container that shows skeleton loading placeholders while content loads.
SkeletonView wraps your content and automatically replaces it with skeleton
placeholder shapes when \c loading is \c true. A shimmer animation overlay
runs across the skeleton shapes to indicate the loading state.
When \c loading becomes \c false, a smooth cross-fade transition reveals the
actual content.
Use the \c skeleton property to define the skeleton placeholder layout:
\qml
import QtQuick
import SmoothUI.Controls
Item {
width: 400; height: 300
SkeletonView {
id: skeletonView
anchors.fill: parent
loading: true
skeleton: Column {
spacing: 16
anchors {
top: parent.top; topMargin: 20
left: parent.left; leftMargin: 20
right: parent.right; rightMargin: 20
}
Row {
spacing: 16
SkeletonItem { type: "circle"; width: 60; height: 60 }
Column {
spacing: 8
width: parent.parent.width - 76
SkeletonItem { type: "text"; lines: 2; lineWidth: [0.9, 0.6]; width: parent.width; lineHeight: 14 }
}
}
SkeletonItem { type: "rounded"; width: parent.width; height: 160; radius: 8 }
SkeletonItem { type: "text"; lines: 3; lineWidth: [0.95, 0.85, 0.5]; width: parent.width; lineHeight: 12 }
}
Column {
}
}
Button {
anchors.bottom: parent.bottom
text: skeletonView.loading ? "Show Content" : "Show Skeleton"
onClicked: skeletonView.loading = !skeletonView.loading
}
}
\endqml
\sa SkeletonItem, Shimmer
*/
Item {
id: control
clip: true
SmoothUI.theme: Theme.of(control)
//!        are shown with the shimmer animation. When \c false, the actual content
property bool loading: true
//!        elements. If unset, a simple rounded rectangle fills the container as a
property Item skeleton
//!        that's clearly visible in both light and dark mode.
property color boneColor: control.SmoothUI.theme.res.dividerStrokeColorDefault
property color highlightColor: Colors.withOpacity(Colors.white, control.SmoothUI.dark ? 0.3 : 0.9)
property color shimmerColor: Colors.withOpacity(Colors.white, control.SmoothUI.dark ? 0.2 : 0.8)
//!        ShimmerType.Pulse, or ShimmerType.Solid.
property int animationStyle: ShimmerType.Slide
//!     The higher the value, the faster the shimmer sweeps across the skeleton.
property real animationSpeed: 1500
//!        Default \c Theme.mediumAnimationDuration (250ms).
property int transitionDuration: Theme.mediumAnimationDuration
default property alias content: contentContainer.data
//!        (transition from loading → \c false completes).
signal contentReady()
//!        (transition from loading → \c true completes).
signal skeletonShown()
implicitWidth: contentContainer.implicitWidth
implicitHeight: contentContainer.implicitHeight
QtObject {
id: d
property bool _ready: false
}
Item {
id: skeletonLayer
anchors.fill: parent
visible: opacity > 0
opacity: control.loading ? 1.0 : 0.0
clip: true
Behavior on opacity {
NumberAnimation {
duration: control.transitionDuration
easing.type: Easing.OutCubic
onRunningChanged: {
if (!running) {
if (control.loading) {
control.skeletonShown()
} else {
control.contentReady()
}
}
}
}
}
Shimmer {
id: shimmerEffect
anchors.fill: parent
z: 65535
running: control.loading && control.visible
animationStyle: control.animationStyle
speed: control.animationSpeed
baseColor: control.boneColor
shimmerColor: control.shimmerColor
highlightColor: control.highlightColor
}
}
Item {
id: contentContainer
anchors.fill: parent
visible: opacity > 0
opacity: control.loading ? 0.0 : 1.0
clip: true
Behavior on opacity {
NumberAnimation {
duration: control.transitionDuration
easing.type: Easing.OutCubic
}
}
}
onSkeletonChanged: {
if (d._ready) {
adoptSkeleton()
}
}
Component.onCompleted: {
d._ready = true
adoptSkeleton()
}
/*!
Adopts the current \c skeleton item into the skeleton layer.
Called automatically when \c skeleton changes or on construction.
*/
function adoptSkeleton() {
if (!d._ready || !skeletonLayer) {
return
}
var existing = skeletonLayer.data
for (var i = existing.length - 1; i >= 0; i--) {
var child = existing[i]
if (child !== shimmerEffect && child !== control.skeleton && child !== null) {
try {
child.visible = false
child.parent = null
child.destroy()
} catch(e) {}
}
}
if (control.skeleton) {
control.skeleton.parent = skeletonLayer
control.skeleton.anchors.fill = skeletonLayer
control.skeleton.visible = true
} else {
var defaultRect = Qt.createQmlObject(
"import QtQuick; import SmoothUI.Controls; SkeletonItem { type: 'rounded'; objectName: 'defaultSkeleton' }",
skeletonLayer,
"defaultSkeleton"
)
if (defaultRect) {
defaultRect.anchors.fill = skeletonLayer
defaultRect.boneColor = control.boneColor
}
}
}
}
