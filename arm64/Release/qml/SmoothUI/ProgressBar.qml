/*!
\qmltype ProgressBar
\inqmlmodule SmoothUI
\brief A Fluent-styled progress bar with indeterminate animation.
Wraps \l T.ProgressBar with SmoothUI theme integration.
Provides a rounded progress bar with accent color and
animated indeterminate (marquee) mode.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.ProgressBar {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
contentItem: RoundClip {
radius: [3,3,3,3]
Rectangle {
width: control.position * parent.width
visible: !control.indeterminate && control.value
height: parent.height
radius: 3
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
Rectangle{
visible: control.indeterminate
width: 0.5 * parent.width
height: parent.height
radius: 3
color: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
SequentialAnimation on x {
loops: Animation.Infinite
running: control.indeterminate && control.visible
NumberAnimation {
from: -control.contentItem.width
to: control.contentItem.width
easing.type: Theme.animationCurve
duration: Theme.slowAnimationDuration * 3
}
NumberAnimation {
from: -control.contentItem.width * 0.5
to: control.contentItem.width
easing.type: Theme.animationCurve
duration: Theme.slowAnimationDuration * 2
}
}
}
}
background: Rectangle {
implicitWidth: 200
implicitHeight: 6
y: (control.height - height) / 2
height: 6
radius: 3
color: control.SmoothUI.theme.res.inactiveBackgroundColor
}
}
