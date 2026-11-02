/*!
\qmltype AutoSuggestBox
\inqmlmodule SmoothUI.Controls
\brief A text input with auto-completion suggestions.
Extends \l TextBox with a dropdown suggestion list that filters
based on user input. Supports custom text roles and configurable
maximum suggestion count.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
TextBox {
id: control
SmoothUI.theme: Theme.of(control)
property var items:[]
property string noResultsMessage: qsTr("No results found")
property var textRole
property int maximumCount: 8
property var filter: function(item){
let text = item
if(textRole){
text = item[textRole]
}
if(text){
if(text.toLowerCase().indexOf(control.text.toLowerCase())!==-1){
return true
}
}
return false
}
signal tap(var data)
QtObject{
id: d
property var sourceItems: []
property bool silentFlag: false
signal upPressed
signal downPressed
signal enterPressed
}
onTextChanged: {
if(!d.silentFlag){
const result = []
items.forEach((item) => {
if(control.filter(item)){
result.push(item)
}
})
if(result.length===0){
result.push({__type:-999})
}
d.sourceItems = result
popup.popup(control)
}
}
Keys.onUpPressed: {
d.upPressed()
}
Keys.onDownPressed: {
d.downPressed()
}
Keys.onEnterPressed: {
d.enterPressed()
}
Keys.onReturnPressed: {
d.enterPressed()
}
DropDownPopup{
id: popup
width: control.width
modal: false
dim: false
SmoothUI.dark: control.SmoothUI.dark
SmoothUI.primaryColor: control.SmoothUI.primaryColor
height: list_view.height + 6
Item{
anchors.fill: parent
Connections{
target: d
function onUpPressed(){
list_view.currentIndex = Math.max(list_view.currentIndex-1,0)
}
function onDownPressed(){
list_view.currentIndex = Math.min(list_view.currentIndex+1,list_view.count-1)
}
function onEnterPressed(){
const modelData =  d.sourceItems[list_view.currentIndex]
control.tap(modelData)
popup.close()
}
}
ListView{
id: list_view
clip: true
width: parent.width
height: 40 * Math.min(d.sourceItems.length,maximumCount)
model: d.sourceItems
anchors.centerIn: parent
ScrollBar.vertical: ScrollBar{}
boundsBehavior: ListView.StopAtBounds
delegate: Item{
id: item_root
property bool isEmpty: modelData.__type === -999
enabled: !(modelData.enabled === false)
implicitHeight: 40
implicitWidth: control.width
ListTile{
anchors{
fill: parent
leftMargin: 4
rightMargin: 4
topMargin: 2
bottomMargin: 2
}
highlighted: !item_root.isEmpty && list_view.currentIndex === index
enabled: !isEmpty
text: {
if(isEmpty){
return control.noResultsMessage
}
return control.textRole ? modelData[control.textRole] : modelData
}
onClicked: {
control.tap(modelData)
popup.close()
updateText(text)
}
}
}
}
}
}
function close(){
popup.close()
}
function updateText(text){
d.silentFlag = true
control.text = text
d.silentFlag = false
}
}
