/*!
\qmltype PasswordBox
\inqmlmodule SmoothUI.Controls
\brief A password text input with reveal toggle.
Provides a themed password input field with masked text
and a trailing icon button to toggle password visibility.
*/
import QtQuick
import QtQuick.Layouts
import SmoothUI.impl
import SmoothUI.Controls
TextBox {
id: control
SmoothUI.theme: Theme.of(control)
echoMode: TextInput.Password
trailing: IconButton{
id: btn_reveal
property int echoMode: 0
implicitWidth: 30
implicitHeight: 20
icon.name: FluentIcons.graph_RevealPasswordMedium
icon.width: 10
icon.height: 10
onPressedChanged: {
if(pressed){
btn_reveal.echoMode = control.echoMode
control.echoMode = TextInput.Normal
}else{
control.echoMode = btn_reveal.echoMode
}
}
}
}
