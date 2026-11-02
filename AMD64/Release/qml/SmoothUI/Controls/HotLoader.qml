/*!
\qmltype HotLoader
\inqmlmodule SmoothUI.Controls
\brief A hot-reload loader that watches QML source files for changes.
Extends \l AutoLoader with file watching capabilities. When
the source QML file changes on disk, it automatically reloads
the component for rapid development iteration.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
AutoLoader{
id: control
property var reload: function(){
var timestamp = Date.now()
var url = new URL(control.source)
url.searchParams.set('timestamp', timestamp)
control.source = url.toString()
}
SmoothUI.theme: Theme.of(control)
Component.onDestruction: sourceComponent = undefined
FileWatcher{
path: control.source.toString()
onFileChanged: {
control.reload()
}
}
Component{
id: comp_error
Item{
CopyableText{
color: control.SmoothUI.theme.res.systemFillColorCritical
width: parent.width
horizontalAlignment: Label.AlignHCenter
anchors.verticalCenter: parent.verticalCenter
wrapMode: Label.WrapAnywhere
text: control.sourceComponent.errorString()
}
}
}
Loader{
anchors.fill: parent
sourceComponent: control.status === Loader.Error ? comp_error : undefined
}
}
