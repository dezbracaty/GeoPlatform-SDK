/*!
\qmltype HyperlinkButton
\inqmlmodule SmoothUI.Controls
\brief A text button styled as a clickable hyperlink.
Provides a themed hyperlink button based on IconButton with
accent-colored text that changes appearance on interaction.
*/
import QtQuick
import SmoothUI.impl
IconButton {
id: control
SmoothUI.theme: Theme.of(control)
property var accentColor: SmoothUI.theme.accentColor
display: IconButton.TextOnly
SmoothUI.textColor: {
if(!enabled){
return control.SmoothUI.theme.res.accentFillColorDisabled
}
if(pressed){
return control.accentColor.tertiaryBrushFor(control.SmoothUI.dark)
}
if(hovered){
return control.accentColor.secondaryBrushFor(control.SmoothUI.dark)
}
return control.accentColor.defaultBrushFor(control.SmoothUI.dark)
}
}
