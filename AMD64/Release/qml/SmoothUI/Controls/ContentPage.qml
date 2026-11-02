/*!
\qmltype ContentPage
\inqmlmodule SmoothUI.Controls
\brief A page container with deferred initialization support.
Extends \l Page with SmoothUI theme integration and a
delayed initialization signal for lazy setup.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
Page {
id: control
SmoothUI.theme: Theme.of(control)
property int delayInterval: 200
signal delayInit
property PageContext context
Component.onCompleted: {
timer_init.start()
}
Timer {
id: timer_init
interval: control.delayInterval
repeat: false
onTriggered: control.delayInit()
}
}
