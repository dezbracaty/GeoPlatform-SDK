import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype SegmentedControl
\inqmlmodule SmoothUI.Controls
\brief A set of segments for mutually exclusive selection
*/
T.TabBar {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
spacing: 0
padding: 0
contentItem: ListView {
model: control.contentModel
currentIndex: control.currentIndex
spacing: control.spacing
orientation: ListView.Horizontal
boundsBehavior: Flickable.StopAtBounds
flickableDirection: Flickable.AutoFlickIfNeeded
snapMode: ListView.SnapToItem
highlightMoveDuration: Theme.mediumAnimationDuration
highlightResizeDuration: 0
highlightFollowsCurrentItem: true
highlightRangeMode: ListView.ApplyRange
preferredHighlightBegin: 48
preferredHighlightEnd: width - 48
highlight: Item {
z: 2
Rectangle {
height: 3
radius: 1.5
width: 18
y: control.position === T.TabBar.Footer ? 0 : parent.height - height
color: control.accentColor?.defaultBrushFor(control.SmoothUI.dark)??"#00000000"
anchors{
horizontalCenter: parent.horizontalCenter
}
}
}
}
background: Rectangle {
radius: control.SmoothUI.radius
color: control.SmoothUI.theme.res.controlAltFillColorSecondary
border.width: 1
border.color: control.SmoothUI.theme.res.dividerStrokeColorDefault
}
}
