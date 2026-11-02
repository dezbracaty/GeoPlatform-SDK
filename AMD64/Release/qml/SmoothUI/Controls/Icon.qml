/*!
\qmltype Icon
\inqmlmodule SmoothUI.Controls
\brief Displays a Fluent UI icon glyph.
Renders an icon from the Fluent UI icon font with configurable
source glyph, color, and font family. Supports all named icons
from \l FluentIcons.
*/
import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Controls.impl as QQCImpl
import SmoothUI.impl
Item{
id: control
property var source
property var color: control.SmoothUI.theme?.res?.textFillColorPrimary ?? (control.SmoothUI.dark ? Colors.white : Colors.black)
property string family: FluentIcons.fontLoader.name
implicitWidth: 24
implicitHeight: 24
Component{
id: comp_text
QQC.Label{
font.family: control.family
text: control.source
font.pixelSize: control.width
color: control.color
}
}
Component{
id: comp_image
Item{
QQCImpl.ColorImage{
id: image_icon
anchors.fill: parent
source: control.source
sourceSize: Qt.size(width,height)
color: control.color
}
}
}
AutoLoader {
anchors.fill: parent
sourceComponent: {
if(control.source){
if(Tools.isUrl(control.source)){
return comp_image
}
return comp_text
}
return undefined
}
}
}
