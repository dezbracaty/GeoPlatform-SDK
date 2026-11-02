import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SmoothUI.impl
/*!
\qmltype ScrollableTextBox
\inqmlmodule SmoothUI.Controls
\brief A scrollable multi-line text input
*/
Flickable {
id: control
SmoothUI.theme: Theme.of(control)
property alias textArea: text_box
property alias text: text_box.text
boundsBehavior: Flickable.StopAtBounds
TextArea.flickable: MultiLineTextBox{
id: text_box
wrapMode: Text.WrapAnywhere
implicitWidth: control.width
onClickSelectAll: function(){
var oldY = control.contentY
text_box.selectAll()
Qt.callLater(function() {
control.contentY = oldY
})
}
Keys.onPressed: function(event) {
if (event.matches(StandardKey.SelectAll)) {
var oldY = control.contentY
text_box.selectAll()
Qt.callLater(function() {
control.contentY = oldY
})
event.accepted = true
}
}
}
onContentXChanged: {
if(contentX<0){
contentX = 0
}
}
onContentYChanged: {
if(contentY<0){
contentY = 0
}
}
ScrollBar.vertical: ScrollBar{}
}
