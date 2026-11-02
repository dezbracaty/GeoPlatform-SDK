import QtQuick
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype StatisticTimer
\inqmlmodule SmoothUI.Controls
\brief A countdown or count-up timer
*/
Statistic {
id: control
//! \value StatisticTimerType.Countdown Counts down from the target date
property int timerType: StatisticTimerType.Countdown
property date targetDate: new Date()
property string format: "HH:mm:ss"
signal finished()
signal timeChanged(var remaining)
formatter: function(v) {
const diff = d.timeDiff
if (isNaN(diff) || diff < 0) {
if (diff < 0 && d.isCountdown && !d.finishedEmitted) {
d.finishedEmitted = true
control.finished()
d.timer.stop()
}
return Tools.formatTimeStr(0, control.format)
}
return Tools.formatTimeStr(diff, control.format)
}
QtObject {
id: d
property bool isCountdown: control.timerType === StatisticTimerType.Countdown
property real timeDiff: 0
property bool finishedEmitted: false
}
Timer {
id: d_timer
interval: 16
repeat: true
running: control.visible
onTriggered: {
const now = Date.now()
const target = control.targetDate.getTime()
let diff
if (d.isCountdown) {
diff = target - now
} else {
diff = now - target
}
d.timeDiff = Math.max(diff, 0)
control.timeChanged(d.timeDiff)
if (d.isCountdown && diff <= 0 && !d.finishedEmitted) {
d.finishedEmitted = true
control.finished()
d_timer.stop()
}
}
}
onTargetDateChanged: {
d.finishedEmitted = false
if (control.visible) {
d_timer.start()
}
}
onVisibleChanged: {
if (control.visible) {
d.finishedEmitted = false
d_timer.start()
} else {
d_timer.stop()
}
}
Component.onCompleted: {
d_timer.start()
}
}
