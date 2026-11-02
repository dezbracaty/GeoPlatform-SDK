/*!
\qmltype ParallaxView
\inqmlmodule SmoothUI.Controls
\brief Creates a parallax scrolling effect.
Moves a source item at a different rate than the scroll
position to create a depth illusion, with configurable
shift amounts and bound offsets.
*/
import QtQuick
import QtQuick.Controls
import SmoothUI.impl
Item {
id: root
property Item source: null
property real verticalShift: 0
property real verticalSourceStartOffset: 0
property real verticalSourceEndOffset: 0
property bool isVerticalShiftClamped: true
property real maxVerticalShiftRatio: 1.0
property int verticalSourceOffsetKind: ParallaxViewType.Absolute
property real horizontalShift: 0
property real horizontalSourceStartOffset: 0
property real horizontalSourceEndOffset: 0
property bool isHorizontalShiftClamped: true
property real maxHorizontalShiftRatio: 1.0
property int horizontalSourceOffsetKind: ParallaxViewType.Absolute
default property alias content: container_content.data
clip: true
Item {
id: container_content
property bool verticalEnabled: verticalShift !== 0
property bool horizontalEnabled: horizontalShift !== 0
width: parent.width
height: parent.height
}
Connections {
target: source
function onContentYChanged() {
if (!container_content.verticalEnabled || !source || !source.contentItem) return
var startOffset = verticalSourceOffsetKind === ParallaxViewType.Relative  ?
verticalSourceStartOffset * source.height : verticalSourceStartOffset
var endOffset = verticalSourceOffsetKind === ParallaxViewType.Relative ?
verticalSourceEndOffset * source.height : verticalSourceEndOffset
var scrollableHeight = source.contentHeight - source.height
var adjustedContentY = Math.max(0, source.contentY - startOffset)
var adjustedScrollableHeight = scrollableHeight - startOffset - endOffset
var progress = Math.min(1, Math.max(0, adjustedContentY / adjustedScrollableHeight))
var shift = isVerticalShiftClamped ?
Math.min(maxVerticalShiftRatio, 1.0) * verticalShift * progress :
verticalShift * progress
container_content.y = -shift
}
function onContentXChanged() {
if (!container_content.horizontalEnabled || !source || !source.contentItem) return
var startOffset = horizontalSourceOffsetKind === ParallaxViewType.Relative ?
horizontalSourceStartOffset * source.width : horizontalSourceStartOffset
var endOffset = horizontalSourceOffsetKind === ParallaxViewType.Relative ?
horizontalSourceEndOffset * source.width : horizontalSourceEndOffset
var scrollableWidth = source.contentWidth - source.width
var adjustedContentX = Math.max(0, source.contentX - startOffset)
var adjustedScrollableWidth = scrollableWidth - startOffset - endOffset
var progress = Math.min(1, Math.max(0, adjustedContentX / adjustedScrollableWidth))
var shift = isHorizontalShiftClamped ?
Math.min(maxHorizontalShiftRatio, 1.0) * horizontalShift * progress :
horizontalShift * progress
container_content.x = -shift
}
}
}
