/*!
\qmltype Objects
\inqmlmodule SmoothUI.impl
\brief A container for grouping QML child objects.
Provides a simple QtObject wrapper that accepts default
children, used as a lightweight grouping and data container
in the SmoothUI framework.
*/
import QtQuick
QtObject {
id: control
default property list<QtObject> children
}
