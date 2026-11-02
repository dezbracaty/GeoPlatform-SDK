/*!
\qmltype ColorOverlay
\inqmlmodule SmoothUI.Controls
\brief Applies a color tint overlay to a source item.
Uses a ShaderEffectSource combined with a colored overlay
Rectangle to apply a uniform color tint over visual content.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
implicitWidth: 100
implicitHeight: 100
SmoothUI.theme: Theme.of(control)
property variant source
property color color: "transparent"
property bool cached: false
ShaderEffectSource {
id: itm_cache
anchors.fill: parent
visible: control.cached
smooth: true
sourceItem: shader_effect
live: true
hideSource: visible
}
ShaderEffect {
id: shader_effect
property variant source: control.source
property color color: control.color
anchors.fill: parent
fragmentShader: "qrc:/qt/qml/SmoothUI/Controls/shaders/coloroverlay.frag.qsb"
}
}
