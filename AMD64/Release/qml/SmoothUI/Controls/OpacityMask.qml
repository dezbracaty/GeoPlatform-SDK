/*!
\qmltype OpacityMask
\inqmlmodule SmoothUI.Controls
\brief Masks a source item using another item's alpha channel.
Uses a ShaderEffect to apply an opacity mask where the mask
source's alpha channel determines the visibility of the
primary source.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
implicitWidth: 100
implicitHeight: 100
SmoothUI.theme: Theme.of(control)
property variant source
property variant maskSource
property bool cached: false
property bool invert: false
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
property variant maskSource: control.maskSource
anchors.fill: parent
fragmentShader: invert ? "qrc:/qt/qml/SmoothUI/Controls/shaders/opacitymask_invert.frag.qsb" : "qrc:/qt/qml/SmoothUI/Controls/shaders/opacitymask.frag.qsb"
}
}
