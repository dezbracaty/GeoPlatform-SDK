import QtQuick
import SmoothUI.impl
/*!
\qmltype Starter
\inqmlmodule SmoothUI.Controls
\brief A starter/getting-started screen or overlay
*/
Objects {
id: control
SmoothUI.theme: Theme.of(control)
property string appId: "A053D1AE-AEA9-4105-B79C-B5F5BEDC9208"
property bool singleton: false
property var locale: Qt.locale()
signal activeApplicationChanged(string args)
Component.onCompleted: {
impl.init(control.locale)
if(control.singleton && Qt.platform.os !== "wasm" && Qt.platform.os !== "android"){
impl.checkApplication(control.appId)
}
}
StarterImpl{
id: impl
onHandleDataChanged:
(args)=>{
control.activeApplicationChanged(args)
}
}
}
