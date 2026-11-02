/*!
\qmltype Dial
\inqmlmodule SmoothUI
\brief A Fluent-styled rotary dial control with theme integration.
Wraps \l T.Dial with SmoothUI theme support, providing
an accent-colored circular dial handle.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.Dial {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
background: Rectangle {
implicitWidth: 100
implicitHeight: 100
x: control.width / 2 - width / 2
y: control.height / 2 - height / 2
width: Math.max(64, Math.min(control.width, control.height))
height: width
color: "transparent"
radius: width / 2
border.width: 2
border.color: control.enabled ? control.accentColor.defaultBrushFor(control.SmoothUI.dark) : control.SmoothUI.theme.res.controlFillColorDisabled
}
handle: Rectangle {
id: handle
x: control.background.x + control.background.width / 2 - width / 2
y: control.background.y + control.background.height / 2 - height / 2
transform: [
Translate {
y: -control.background.height * 0.4
+ (control.handle ? control.handle.height / 2 : 0)
},
Rotation {
angle: control.angle
origin.x: control.handle ? control.handle.width / 2 : 0
origin.y: control.handle ? control.handle.height / 2 : 0
}
]
property Item control: SelectionRectangle.control
width: 22
height: 22
radius: width * 0.5
border.width: 1
border.color: control.SmoothUI.theme.res.popupBorderColor
color: control.SmoothUI.theme.res.controlSolidFillColorDefault
Shadow{
radius: width * 0.5
}
Rectangle{
property real diameter: !control.enabled ? 10 : control.pressed ? 8 : control.hovered ? 14 : 10
width: diameter
height: diameter
anchors.centerIn: parent
radius: diameter * 0.5
color: Theme.checkedInputColor(control,control.accentColor,control.SmoothUI.dark)
Behavior on diameter {
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
}
