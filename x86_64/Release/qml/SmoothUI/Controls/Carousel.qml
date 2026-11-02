/*!
\qmltype Carousel
\inqmlmodule SmoothUI.Controls
\brief A feature-rich carousel for cycling through items.
Supports auto-play, navigation arrow buttons (always / on-hover / never),
dot indicators, slide animation, pause-on-hover, wheel navigation,
and configurable properties throughout. Replaces both \l BannerLayout
and \l FlipView.
Uses \l PathView internally for smooth item transitions.
\qml
import QtQuick
import SmoothUI.Controls
Carousel {
width: 480; height: 300
autoPlay: true
autoPlaySpeed: 3000
model: ["banner_1.webp", "banner_2.webp", "banner_3.webp"]
delegate: Image {
source: "qrc:/qt/qml/Gallery/res/image/" + modelData
fillMode: Image.PreserveAspectCrop
}
}
\endqml
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
PathView {
id: control
SmoothUI.theme: Theme.of(control)
// currentIndex, currentItem, interactive, clip, moving, dragging
/*!
\brief Whether the carousel automatically cycles through items.
Default: \c false.
*/
property bool autoPlay: false
/*!
\brief Interval in milliseconds between auto-play transitions.
Default: \c 3000.
*/
property int autoPlaySpeed: 3000
/*!
\brief Whether to pause auto-play when the mouse hovers over
the carousel area. Default: \c true.
*/
property bool pauseOnHover: true
/*!
\brief Whether to ignore manual navigation while a transition
is still running. Default: \c false.
*/
property bool waitForAnimate: false
/*!
\brief Whether the mouse wheel can navigate between items.
Default: \c true.
*/
property bool wheelEnabled: true
/*!
\brief Scroll orientation: \c Qt.Horizontal (default) or
\c Qt.Vertical.
*/
property int orientation: Qt.Horizontal
/*!
\brief Number of items visible at once. Default: \c 1.
*/
property int visibleItemCount: 1
/*!
\brief Whether to show the dot indicator strip. Default: \c true.
*/
property bool showDots: true
/*!
\brief Position of the dot indicators.
One of: \c Qt.BottomEdge (default), \c Qt.TopEdge,
\c Qt.LeftEdge, \c Qt.RightEdge.
*/
property int dotPosition: Qt.BottomEdge
/*!
\brief Color of an inactive dot.
Default: \c textFillColorSecondary.
*/
property color dotColor: control.SmoothUI.theme.res.textFillColorSecondary
/*!
\brief Color of the active (current) dot.
Default: the theme accent color.
*/
property color dotActiveColor: Theme.of(control).accentColor.defaultBrushFor(SmoothUI.dark)
/*!
\brief Size of each dot in pixels. Default \c 8.
*/
property real dotSize: 8
/*!
\brief Controls when the previous/next arrow buttons are visible.
\c CarouselType.Never — never shown.
\c CarouselType.Always — always shown.
\c CarouselType.OnHover (default) — shown on mouse hover.
*/
property int buttonShowMode: CarouselType.OnHover
/*!
\brief Custom component for the previous button.
The component should define \c onClicked for navigation.
Default: a themed arrow button (slim rectangle, \c radius 4).
*/
property Component prevButton
/*!
\brief Custom component for the next button.
The component should define \c onClicked for navigation.
Default: a themed arrow button (slim rectangle, \c radius 4).
*/
property Component nextButton
/*!
\brief Custom PageIndicator component for the dot indicators.
The component receives \c count, \c currentIndex and other
properties from the default PageIndicator. Default: a themed
PageIndicator with circular dots.
*/
property Component pageIndicator
/*!
\brief Emitted just before the displayed item changes.
\param from The index of the previously displayed item.
\param to The index of the item about to be displayed.
*/
signal beforeChange(int from, int to)
/*!
\brief Emitted after the displayed item has changed.
\param current The index of the newly displayed item.
*/
signal afterChange(int current)
// PathView configuration (BannerLayout style)
implicitWidth: 400
implicitHeight: 200
pathItemCount: control.visibleItemCount + 1
dragMargin: Math.max(width, height) / 2
snapMode: PathView.SnapOneItem
preferredHighlightBegin: 0.5
preferredHighlightEnd: 0.5
clip: true
interactive: true
Path {
id: path_vertical
startX: control.width / 2
startY: -control.height / 2
PathLine {
x: control.width / 2
y: control.pathItemCount * control.height - control.height / 2
}
}
Path {
id: path_horizontal
startX: -control.width / 2
startY: control.height / 2
PathLine {
x: control.pathItemCount * control.width - control.width / 2
y: control.height / 2
}
}
path: control.orientation === Qt.Horizontal ? path_horizontal : path_vertical
// Internal state
QtObject {
id: d
property bool hovered: false
property bool dragPaused: false
readonly property bool isHorizontal: control.orientation === Qt.Horizontal
function navigate(direction) {
if (control.waitForAnimate && control.moving)
return
var from = control.currentIndex
var to = Math.max(0, Math.min(from + direction, control.count - 1))
if (to === from)
return
control.beforeChange(from, to)
if (direction < 0)
control.decrementCurrentIndex()
else
control.incrementCurrentIndex()
}
}
// Signal wiring
onCurrentIndexChanged: {
control.afterChange(control.currentIndex)
}
onDraggingChanged: {
d.dragPaused = dragging
}
// Auto-play
Timer {
id: timer
interval: control.autoPlaySpeed
running: control.autoPlay
&& !(control.pauseOnHover && d.hovered)
&& !d.dragPaused
&& control.count > 1
repeat: true
onTriggered: {
var next = (control.currentIndex + 1) % control.count
control.beforeChange(control.currentIndex, next)
control.incrementCurrentIndex()
}
}
// Hover detection (HoverHandler avoids conflict with PathView)
HoverHandler {
id: hoverHandler
onHoveredChanged: {
d.hovered = hovered
}
}
// Navigation buttons
readonly property bool _buttonsVisible: {
if (buttonShowMode === CarouselType.Always) return true
if (buttonShowMode === CarouselType.Never) return false
return d.hovered
}
readonly property bool _showPrev: _buttonsVisible
&& control.currentIndex > 0 && control.count > 1
readonly property bool _showNext: _buttonsVisible
&& control.currentIndex < control.count - 1 && control.count > 1
Loader {
id: btnPrev
z: 10
active: _showPrev
sourceComponent: control.prevButton || comp_prev_button
anchors {
left: d.isHorizontal ? parent.left : undefined
top: d.isHorizontal ? undefined : parent.top
leftMargin: d.isHorizontal ? 2 : 0
topMargin: d.isHorizontal ? 0 : 2
verticalCenter: d.isHorizontal ? parent.verticalCenter : undefined
horizontalCenter: d.isHorizontal ? undefined : parent.horizontalCenter
}
}
Loader {
id: btnNext
z: 10
active: _showNext
sourceComponent: control.nextButton || comp_next_button
anchors {
right: d.isHorizontal ? parent.right : undefined
bottom: d.isHorizontal ? undefined : parent.bottom
rightMargin: d.isHorizontal ? 2 : 0
bottomMargin: d.isHorizontal ? 0 : 2
verticalCenter: d.isHorizontal ? parent.verticalCenter : undefined
horizontalCenter: d.isHorizontal ? undefined : parent.horizontalCenter
}
}
Component {
id: comp_prev_button
Rectangle {
width: d.isHorizontal ? 20 : 40
height: d.isHorizontal ? 40 : 20
radius: control.SmoothUI.radius
color: Colors.withOpacity(
control.SmoothUI.theme.res.solidBackgroundFillColorBase, 0.6)
StandardButton {
anchors.fill: parent
SmoothUI.radius: parent.radius
icon.name: d.isHorizontal
? FluentIcons.graph_CaretLeftSolid8
: FluentIcons.graph_CaretUpSolid8
icon.width: 8
icon.height: 8
onClicked: d.navigate(-1)
}
}
}
Component {
id: comp_next_button
Rectangle {
width: d.isHorizontal ? 20 : 40
height: d.isHorizontal ? 40 : 20
radius: control.SmoothUI.radius
color: Colors.withOpacity(
control.SmoothUI.theme.res.solidBackgroundFillColorBase, 0.6)
StandardButton {
anchors.fill: parent
SmoothUI.radius: parent.radius
icon.name: d.isHorizontal
? FluentIcons.graph_CaretRightSolid8
: FluentIcons.graph_CaretDownSolid8
icon.width: 8
icon.height: 8
onClicked: d.navigate(1)
}
}
}
// Dot indicators (PageIndicator via Loader)
Loader {
id: dotsLoader
z: 10
active: control.showDots && control.count > 1
sourceComponent: control.pageIndicator || comp_page_indicator
anchors {
bottom: control.dotPosition === Qt.BottomEdge ? parent.bottom : undefined
top: control.dotPosition === Qt.TopEdge ? parent.top : undefined
left: control.dotPosition === Qt.LeftEdge ? parent.left : undefined
right: control.dotPosition === Qt.RightEdge ? parent.right : undefined
horizontalCenter: (control.dotPosition === Qt.BottomEdge
|| control.dotPosition === Qt.TopEdge)
? parent.horizontalCenter : undefined
verticalCenter: (control.dotPosition === Qt.LeftEdge
|| control.dotPosition === Qt.RightEdge)
? parent.verticalCenter : undefined
bottomMargin: 12
topMargin: 12
leftMargin: 12
rightMargin: 12
}
}
Component {
id: comp_page_indicator
PageIndicator {
count: control.count
currentIndex: control.currentIndex
interactive: false
delegate: Rectangle {
width: control.dotSize
height: control.dotSize
radius: width / 2
color: index === control.currentIndex
? control.dotActiveColor : control.dotColor
opacity: index === control.currentIndex ? 1.0 : 0.5
Behavior on color { ColorAnimation { duration: 200 } }
MouseArea {
anchors.fill: parent
hoverEnabled: true
cursorShape: Qt.PointingHandCursor
onClicked: {
if (index !== control.currentIndex) {
control.beforeChange(control.currentIndex, index)
control.currentIndex = index
}
}
}
}
}
}
// Wheel navigation
WheelHandler {
enabled: control.wheelEnabled && control.count > 1
onWheel: (event) => {
var delta = d.isHorizontal
? (Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y)
? event.angleDelta.x : event.angleDelta.y)
: event.angleDelta.y
d.navigate(delta > 0 ? -1 : 1)
}
}
}
