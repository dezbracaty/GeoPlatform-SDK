/*!
\qmltype LinearGradient
\inqmlmodule SmoothUI.Controls
\brief Renders a linear gradient overlay over a source item.
Applies a configurable linear gradient (start/end points, gradient stops)
over a source item using shader-based rendering with optional caching.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
implicitWidth: 100
implicitHeight: 100
SmoothUI.theme: Theme.of(control)
property variant start: Qt.point(0, 0)
property variant end: Qt.point(0, height)
property bool cached: false
property variant source
property Gradient gradient: Gradient {
GradientStop { position: 0.0; color: "white" }
GradientStop { position: 1.0; color: "black" }
}
ShaderEffectSource {
id: source_gradient
sourceItem: Rectangle {
width: 16
height: 256
gradient: control.gradient
smooth: true
}
smooth: true
hideSource: true
visible: false
}
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
anchors.fill: parent
property variant source: source_gradient
property variant maskSource: control.source
property variant startPoint: Qt.point(start.x / width, start.y / height)
property real dx: end.x - start.x
property real dy: end.y - start.y
property real l: 1.0 / Math.sqrt(Math.pow(dx / width, 2.0) + Math.pow(dy / height, 2.0))
property real angle: Math.atan2(dx, dy)
property variant matrixData: Qt.point(Math.sin(angle), Math.cos(angle))
vertexShader: "qrc:/qt/qml/SmoothUI/Controls/shaders/lineargradient.vert.qsb"
fragmentShader: maskSource === undefined ? noMaskShader : maskShader
onFragmentShaderChanged: lChanged()
property string maskShader: "qrc:/qt/qml/SmoothUI/Controls/shaders/lineargradient_mask.frag.qsb"
property string noMaskShader: "qrc:/qt/qml/SmoothUI/Controls/shaders/lineargradient_nomask.frag.qsb"
}
}
