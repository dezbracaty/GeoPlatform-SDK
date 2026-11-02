/*!
\qmltype DelayButton
\inqmlmodule SmoothUI
\brief A Fluent-styled delay button with progress animation.
Wraps \l T.DelayButton with SmoothUI theme integration.
The button fills progressively when pressed and triggers
after the configured delay elapses.
*/
import QtQuick
import QtQuick.Controls.impl as QQCImpl
import QtQuick.Templates as T
import SmoothUI.impl
import SmoothUI.Controls
T.DelayButton {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
implicitContentHeight + topPadding + bottomPadding)
padding: Theme.controlPadding
horizontalPadding: Theme.controlHorizontalPadding
transition: Transition {
NumberAnimation {
duration: control.delay * (control.pressed ? 1.0 - control.progress : 0.3 * control.progress)
easing.type: Theme.animationCurve
}
}
font: Typography.body
SmoothUI.textColor: {
if(control.checked){
if(!control.enabled){
return control.SmoothUI.theme.res.textOnAccentFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textOnAccentFillColorSecondary
}
if(control.hovered){
return control.SmoothUI.theme.res.textOnAccentFillColorPrimary
}
return control.SmoothUI.theme.res.textOnAccentFillColorPrimary
}else{
if(!control.enabled){
return control.SmoothUI.theme.res.textFillColorDisabled
}
if(control.pressed){
return control.SmoothUI.theme.res.textFillColorSecondary
}
if(control.flat && control.hovered){
return control.SmoothUI.theme.res.textFillColorTertiary
}
return control.SmoothUI.theme.res.textFillColorPrimary
}
}
focusPolicy: Qt.TabFocus
contentItem: QQCImpl.ItemGroup {
QQCImpl.ClippedText {
clip: control.progress > 0
clipX: -control.leftPadding + control.progress * control.width
clipWidth: (1.0 - control.progress) * control.width
visible: control.progress < 1
text: control.text
font: control.font
color: control.SmoothUI.textColor
horizontalAlignment: Text.AlignHCenter
verticalAlignment: Text.AlignVCenter
elide: Text.ElideRight
}
QQCImpl.ClippedText {
clip: control.progress > 0
clipX: -control.leftPadding
clipWidth: control.progress * control.width
visible: control.progress > 0
text: control.text
font: control.font
color: control.SmoothUI.textColor
horizontalAlignment: Text.AlignHCenter
verticalAlignment: Text.AlignVCenter
elide: Text.ElideRight
}
}
background: FocusItem{
implicitHeight: Theme.controlHeight
implicitWidth: Theme.controlHeight
radius: control.SmoothUI.radius
target: control
ControlBackground {
anchors.fill: parent
radius: control.SmoothUI.radius
target: control
accentColor: control.accentColor
highlighted: control.checked
}
ControlBackground {
width: control.progress * parent.width
height: parent.height
radius: control.SmoothUI.radius
target: control
accentColor: control.accentColor
highlighted: true
visible: !control.checked
}
}
}
