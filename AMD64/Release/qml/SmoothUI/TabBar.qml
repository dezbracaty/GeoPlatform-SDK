/*!
\qmltype TabBar
\inqmlmodule SmoothUI
\brief A Fluent-styled tab bar with sliding highlight indicator.
Wraps \l T.TabBar with SmoothUI theme integration.
Provides a scrollable tab list with accent-colored underline
highlight that follows the current tab.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.TabBar {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
contentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
contentHeight + topPadding + bottomPadding)
spacing: 18
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
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
anchors{
horizontalCenter: parent.horizontalCenter
}
}
}
}
background: Item {}
}
