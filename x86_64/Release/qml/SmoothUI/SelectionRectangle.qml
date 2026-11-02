/*!
\qmltype SelectionRectangle
\inqmlmodule SmoothUI
\brief A Fluent-styled text selection rectangle with resize handles.
Wraps \l T.SelectionRectangle with SmoothUI theme integration.
Provides draggable circular handles with accent color for
text selection adjustments.
*/
import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
T.SelectionRectangle {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
topLeftHandle: Handle {}
bottomRightHandle: Handle {}
component Handle : Rectangle {
id: handle
property Item handleControl: SelectionRectangle.control
width: 20
height: width
radius: width / 2
color: control.SmoothUI.theme.res.controlSolidFillColorDefault
Shadow{
radius: width / 2
}
visible: SelectionRectangle.control.active
Rectangle{
width: 10
height: 10
anchors.centerIn: parent
radius: width / 2
scale:{
if(!handleControl.enabled){
return 1
}
if(handleControl.pressed){
return 0.9
}
return handleControl.hovered ? 1.2 : 1
}
color: Theme.checkedInputColor(handleControl,control.accentColor,control.SmoothUI.dark)
Behavior on scale{
NumberAnimation{
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
}
}
