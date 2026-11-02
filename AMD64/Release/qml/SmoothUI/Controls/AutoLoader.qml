/*!
\qmltype AutoLoader
\inqmlmodule SmoothUI.Controls
\brief A Loader with automatic cleanup on destruction.
Extends \l Loader while preserving its theme-neutral lifecycle.
Automatically clears the source component on destruction
to prevent memory leaks.
*/
import QtQuick
import QtQuick.Controls
Loader {
id: control
Component.onDestruction: sourceComponent = undefined
}
