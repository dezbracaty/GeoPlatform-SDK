/*!
\qmltype LiquidGlass
\inqmlmodule SmoothUI.Controls
\brief Creates a liquid glass / frosted glass visual effect.
Provides a realistic glass surface effect with configurable
refraction, bevel depth/width, frost intensity (animated),
and specular highlights.
*/
import QtQuick
import SmoothUI.impl
Item {
id: control
SmoothUI.theme: Theme.of(control)
property alias sourceItem: source.sourceItem
property alias sourceRect: source.sourceRect
property real refraction: 0.026
property real bevelDepth: 0.119
property real bevelWidth: 0.057
property real frost: 0.0
property bool frostAnimated: true
property bool specularAnimated: true
property real specularIntensity: 1.0
property real tiltX: 0.0
property real tiltY: 0.0
property real magnify: 1.0
property real radius: 0.0
readonly property real __srcScale: {
const magnifyPad = Math.max(1.0 / Math.max(control.magnify, 0.001), 1.0)
const refrPad = 1.0 + 2.0 * (control.refraction + control.bevelDepth)
return Math.max(magnifyPad, refrPad, 1.1)
}
ShaderEffectSource {
id: source
anchors.fill: parent
visible: false
sourceRect: Qt.rect(
control.x - control.width * (control.__srcScale - 1.0) * 0.5,
control.y - control.height * (control.__srcScale - 1.0) * 0.5,
control.width * control.__srcScale,
control.height * control.__srcScale
)
}
ShaderEffect {
id: shader_effect
anchors.fill: parent
property variant source: source
property vector2d resolution: Qt.vector2d(control.width, control.height)
property real refraction: control.refraction
property real bevelDepth: control.bevelDepth
property real bevelWidth: control.bevelWidth
property real frost: control.frost
property real radius: control.radius
property real specularIntensity: control.specularIntensity
property real tiltX: control.tiltX
property real tiltY: control.tiltY
property real magnify: control.magnify
property real iTime: 0.0
property real fTime: 0
NumberAnimation on iTime {
running: control.specularAnimated && control.specularIntensity > 0.0
loops: Animation.Infinite
from: 0
to: 360000
duration: 360000000
}
NumberAnimation on fTime {
from: 0
to: 10
duration: 10000
loops: Animation.Infinite
running: control.frostAnimated
}
vertexShader: 'qrc:/qt/qml/SmoothUI/Controls/shaders/liquid_glass.vert.qsb'
fragmentShader: 'qrc:/qt/qml/SmoothUI/Controls/shaders/liquid_glass.frag.qsb'
}
}
