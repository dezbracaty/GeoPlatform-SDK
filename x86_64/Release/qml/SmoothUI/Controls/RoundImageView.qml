import QtQuick
import SmoothUI.impl
/*!
\qmltype RoundImageView
\inqmlmodule SmoothUI.Controls
\brief An image view with rounded corners
*/
Item{
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
property var radius: [round_clip.defalutRadius,round_clip.defalutRadius,round_clip.defalutRadius,round_clip.defalutRadius]
property url source
property alias sourceSize: image.sourceSize
property int borderWidth : 0
property color borderColor: control.accentColor.defaultBrushFor(control.SmoothUI.dark)
property var dashPattern: []
property int borderStyle: Qt.SolidLine
property alias view: image
RoundClip{
id: round_clip
property int defalutRadius: Math.min(control.width,control.height)/2
anchors.fill: parent
radius: control.radius
Image {
id: image
anchors.fill: parent
source: control.source
}
RoundRectangle{
anchors.fill: parent
color: Colors.transparent
borderWidth: control.borderWidth
radius: control.radius
borderColor: control.borderColor
dashPattern: control.dashPattern
borderStyle: control.borderStyle
}
}
}
