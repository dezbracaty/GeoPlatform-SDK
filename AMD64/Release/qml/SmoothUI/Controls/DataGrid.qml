/*!
\qmltype DataGrid
\inqmlmodule SmoothUI.Controls
\brief A flat data grid component for tabular data display.
Extends \l TreeDataGrid without hierarchy to provide a
flat table view with smooth row transitions, sorting,
column resizing, and selection support.
*/
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
TreeDataGrid{
view.addDisplaced: Transition {
NumberAnimation {
properties: "x,y"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
view.move: Transition {
NumberAnimation {
properties: "x,y"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
view.moveDisplaced: Transition {
NumberAnimation {
properties: "x,y"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
view.removeDisplaced: Transition {
NumberAnimation {
properties: "x,y"
duration: Theme.fastAnimationDuration
easing.type: Theme.animationCurve
}
}
}
