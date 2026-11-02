/*!
\qmltype PageContext
\inqmlmodule SmoothUI.Controls
\brief Provides page-level context data for routing.
Carries navigation state including the current route path, URL,
arguments, and singleton status for use with PageRouter.
*/
import QtQuick
QtObject {
id: control
property var path
property var url
property var argument
property bool singleton
property var view
property var router
signal activated
signal deactivated
signal activating
signal deactivating
}
