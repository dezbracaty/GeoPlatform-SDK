import QtQuick
import SmoothUI.impl
/*!
\qmltype RoundClip
\inqmlmodule SmoothUI.Controls
\brief Clips its child to a rounded rectangle
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
default property alias content: container.data
property var radius: [0,0,0,0]
Item{
id: container
opacity: 0
width: control.width
height: control.height
layer.enabled: true
}
RoundRectangle{
id: mask_source
radius: control.radius
width: control.width
height: control.height
visible: false
layer.enabled: true
}
OpacityMask {
width: control.width
height: control.height
source: container
maskSource: mask_source
}
}
