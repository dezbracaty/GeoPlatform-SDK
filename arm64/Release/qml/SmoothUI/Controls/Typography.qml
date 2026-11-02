pragma Singleton
import QtQuick
/*!
\qmltype Typography
\inqmlmodule SmoothUI.Controls
\brief Singleton providing Fluent Design typography presets
*/
QtObject {
readonly property font display: Qt.font({pixelSize : 62, weight: Font.DemiBold})
readonly property font titleLarge: Qt.font({pixelSize : 37, weight: Font.DemiBold})
readonly property font title: Qt.font({pixelSize : Theme.pageTitleFontSize, weight: Font.DemiBold})
readonly property font subtitle: Qt.font({pixelSize : Theme.panelTitleFontSize, weight: Font.DemiBold})
readonly property font bodyLarge: Qt.font({pixelSize : 17, weight: Font.Normal})
readonly property font bodyStrong: Qt.font({pixelSize : Theme.bodyFontSize, weight: Font.DemiBold})
readonly property font body: Qt.font({pixelSize : Theme.bodyFontSize, weight: Font.Normal})
readonly property font caption: Qt.font({pixelSize : Theme.captionFontSize, weight: Font.Normal})
}
