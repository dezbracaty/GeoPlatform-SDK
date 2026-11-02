import QtQuick
import com.kdab.dockwidgets as KDDW
KDDW.DockingArea {
id: control
property int contentsMargin: 0
property int titleBarContentsMargin: 0
function addDockWidget2(dockWidget,location){
this.addDockWidget(dockWidget, KDDW.KDDockWidgets.Location_OnBottom);
}
}
