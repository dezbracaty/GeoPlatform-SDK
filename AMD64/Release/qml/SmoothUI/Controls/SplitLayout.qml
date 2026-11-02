import QtQuick
import QtQuick.Templates as T
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype SplitLayout
\inqmlmodule SmoothUI.Controls
\brief A resizable split layout with panes
*/
T.SplitView {
id: control
SmoothUI.theme: Theme.of(control)
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
QtObject{
id: d
property bool isVertical: control.orientation === Qt.Vertical
}
handle: Rectangle {
implicitWidth: d.isVertical ? control.width : 10
implicitHeight: d.isVertical ? 10 : control.height
clip: true
color:{
if(!control.enabled){
return control.SmoothUI.theme.res.controlFillColorDisabled
}else{
if(T.SplitHandle.pressed){
return control.SmoothUI.theme.res.subtleFillColorTertiary
}
if(T.SplitHandle.hovered){
return control.SmoothUI.theme.res.subtleFillColorSecondary
}
return control.SmoothUI.theme.res.subtleFillColorTransparent
}
}
Rectangle{
width: d.isVertical ? 26 : 4
height: d.isVertical ? 4 : 26
anchors.centerIn: parent
color: control.SmoothUI.theme.res.controlStrongStrokeColorDefault
radius: 2
}
}
}
