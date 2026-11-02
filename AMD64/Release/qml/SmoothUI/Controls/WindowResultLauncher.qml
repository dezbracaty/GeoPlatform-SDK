import QtQuick
import SmoothUI.impl
/*!
\qmltype WindowResultLauncher
\inqmlmodule SmoothUI.Controls
\brief Utility for launching windows with result callbacks
*/
Item {
id: control
SmoothUI.theme: Theme.of(control)
visible: false
property var __from : Window.window
property var __to
property var path
signal result(var data)
function launch(argument = {}){
WindowRouter.go(control.path,argument,control)
}
function setResult(data = {}){
control.result(data)
}
}
