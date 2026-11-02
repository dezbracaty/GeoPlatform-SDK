import QtQuick
import QtQuick.Controls
import SmoothUI.Controls
import SmoothUI.impl
/*!
\qmltype StaggeredGridView
\inqmlmodule SmoothUI.Controls
\brief A scrollable, virtualized staggered/masonry grid view.
StaggeredGridView provides a Flickable-based scrollable grid with virtual scrolling —
only items within the visible viewport (plus a configurable \c bufferPixel margin) are
created. Items that scroll out of view are moved to an internal reuse pool rather than
destroyed, so scrolling back reuses existing delegate instances with updated model data.
The layout engine implements the shortest-column (masonry/waterfall) algorithm from
Flutter's \c staggered_grid_view package, specifically the \c{RenderStaggeredGrid}
tile-placement routine and \c{_findBestCandidate()} scan.
Items are populated from a \c model via a \c delegate. Tile dimensions can be
controlled through model-data properties:
\list
\li \c{crossAxisCellCount} — number of columns this tile spans (default: 1)
\li \c{mainAxisCellCount} — height as a multiple of cell stride
\li \c{mainAxisExtent} — exact pixel height (overrides mainAxisCellCount)
\endlist
When neither \c{mainAxisCellCount} nor \c{mainAxisExtent} is set, the tile
fits to its content (uses the delegate's implicit height).
Column control:
\list
\li \c{crossAxisCount} — fixed number of columns
\li \c{maxCrossAxisExtent} — auto-columns from max tile width (overrides crossAxisCount)
\endlist
\note The delegate accesses model data through the QML scope chain. Use
\c{model.propertyName} inside the delegate, \e{not} \c{required property var model}.
(The scope chain pattern is more efficient with the reuse pool.)
*/
Flickable {
id: control
clip: true
implicitWidth: 200
implicitHeight: 200
contentHeight: d.contentHeight
contentWidth: width
SmoothUI.theme: Theme.of(control)
ScrollBar.vertical: ScrollBar {
visible: control.contentHeight > control.height
}
property int crossAxisCount: 4
property real maxCrossAxisExtent: 0
property int mainAxisSpacing: 0
property int crossAxisSpacing: 0
property alias model: d.sourceModel
property Component delegate: null
property int bufferPixel: 300
property real defaultItemHeight: 120
property int cachePoolSize: 64
/*! \internal Notifies when a delegate instance is moved to the reuse pool.
The item can pause timers / animations here. */
signal pooled(Item item)
/*! \internal Notifies when a delegate instance is taken from the pool
and re-bound to a new model index. */
signal reused(Item item)
onWidthChanged: { d.resolveColumns(); d.scheduleLayout() }
onCrossAxisCountChanged: d.scheduleLayout()
onMaxCrossAxisExtentChanged: d.scheduleLayout()
onMainAxisSpacingChanged: d.scheduleLayout()
onCrossAxisSpacingChanged: d.scheduleLayout()
onContentYChanged: d.updateVisibleRange()
onHeightChanged: d.updateVisibleRange()
onBufferPixelChanged: d.updateVisibleRange()
Item {
id: _poolContainer
visible: false
}
QtObject {
id: d
property int resolvedCrossAxisCount: 4
property real stride: 0
property real contentHeight: 0
property var colHeights: []
property var itemPositions: []          // [{x, y, w, h, cellSpan, columnStart}]
property var itemMeta: ({})             // index -> {wrapper, delegateItem, heightConn}
property var sourceModel: null
property var _availablePool: []
property Component wrapperComponent: Component {
Item {
id: wrapperItem
property var model: ({})
// model.* through the QML scope chain.
}
}
property Component _heightWatcherComponent: Component {
Connections {
function onHeightChanged() {
layoutTimer.restart()
}
}
}
function init() {
layoutTimer.triggered.connect(doLayout)
return true
}
property var _dummy: init()
function resolveColumns() {
if (control.maxCrossAxisExtent > 0 && control.width > 0) {
var n = Math.ceil(control.width / (control.maxCrossAxisExtent + control.crossAxisSpacing))
resolvedCrossAxisCount = Math.max(1, n)
} else {
resolvedCrossAxisCount = Math.max(1, control.crossAxisCount)
}
}
function getModelCount() {
var m = sourceModel
if (!m) return 0
if (typeof m === 'number') return m
if (Array.isArray(m)) return m.length
if (typeof m.count === 'number') return m.count
try { return m.count } catch(e) { return 0 }
}
function getModelData(index) {
var m = sourceModel
var data = {}
try {
if (!m) return data
if (typeof m === 'number') {
data.index = index
return data
}
if (Array.isArray(m)) {
if (index >= 0 && index < m.length) {
data = m[index]
if (typeof data !== 'object') data = {}
}
data.index = index
return data
}
if (typeof m.get === 'function') {
var row = m.get(index)
if (row) {
var keys = Object.keys(row)
for (var ki = 0; ki < keys.length; ki++)
data[keys[ki]] = row[keys[ki]]
}
}
data.index = index
} catch(e) {}
return data
}
function getTileInfo(index) {
var result = { crossAxisCellCount: 1, mainAxisCellCount: 0, mainAxisExtent: 0 }
try {
var data = getModelData(index)
if (data.crossAxisCellCount !== undefined)
result.crossAxisCellCount = Math.max(1, Number(data.crossAxisCellCount))
if (data.mainAxisCellCount !== undefined)
result.mainAxisCellCount = Math.max(0, Number(data.mainAxisCellCount))
if (data.mainAxisExtent !== undefined)
result.mainAxisExtent = Math.max(0, Number(data.mainAxisExtent))
} catch (e) {}
return result
}
function findBestCandidate(offsets, span) {
var len = offsets.length
var bestIndex = 0
var bestOffset = Infinity
for (var i = 0; i < len; i++) {
var offset = offsets[i]
if (bestOffset - offset < 0.001) continue
var start = 0, count = 0
for (var j = 0; count < span && j < len && len - j >= span - count; j++) {
if (offsets[j] - offset < 0.001) {
count++
if (count === span) {
bestIndex = start
bestOffset = offset
}
} else {
start = j + 1
count = 0
}
}
}
return { index: bestIndex, offset: bestOffset }
}
function calculatePositions() {
var count = getModelCount()
var cols = resolvedCrossAxisCount
if (cols <= 0 || count <= 0) {
itemPositions = []
contentHeight = 0
return
}
stride = (control.width + control.crossAxisSpacing) / cols
colHeights = new Array(cols).fill(0)
var positions = []
for (var i = 0; i < count; i++) {
var info = getTileInfo(i)
var cellSpan = Math.min(info.crossAxisCellCount, cols)
var tileWidth = stride * cellSpan - control.crossAxisSpacing
var tileHeight = control.defaultItemHeight
if (info.mainAxisExtent > 0) {
tileHeight = info.mainAxisExtent
} else if (info.mainAxisCellCount > 0) {
tileHeight = stride * info.mainAxisCellCount - control.mainAxisSpacing
}
var pos = findBestCandidate(colHeights, cellSpan)
var x = pos.index * stride
var y = pos.offset
if (y > 0) y += control.mainAxisSpacing
positions.push({
x: x, y: y,
w: tileWidth, h: tileHeight,
cellSpan: cellSpan,
columnStart: pos.index
})
var bottom = y + tileHeight
for (var c = pos.index; c < pos.index + cellSpan; c++)
colHeights[c] = Math.max(colHeights[c], bottom)
}
itemPositions = positions
contentHeight = Math.max.apply(null, colHeights) || 0
}
function updateVisibleRange() {
if (itemPositions.length === 0) return
var viewStart = control.contentY - control.bufferPixel
var viewEnd = control.contentY + control.height + control.bufferPixel
var first = -1, last = -1
var positions = itemPositions
for (var i = 0; i < positions.length; i++) {
var p = positions[i]
if (p.y + p.h >= viewStart && first < 0) first = i
if (p.y <= viewEnd) last = i
}
if (first < 0) { first = 0; last = -1 }
var idxs = Object.keys(itemMeta)
for (var ki = 0; ki < idxs.length; ki++) {
var idx = parseInt(idxs[ki])
if (idx < first || idx > last)
recycleItem(idx)
}
if (last < 0) return
if (!control.delegate) return
for (var ci = first; ci <= last; ci++)
ensureItemAt(ci)
}
function ensureItemAt(index) {
if (itemMeta[index]) return
var pos = itemPositions[index]
if (!pos) return
var data = getModelData(index)
var info = getTileInfo(index)
var wrapper, delegateItem, heightConn
if (_availablePool.length > 0) {
var recycled = _availablePool.pop()
wrapper = recycled.wrapper
delegateItem = recycled.delegateItem
heightConn = recycled.heightConn
wrapper.parent = control.contentItem
wrapper.visible = true
wrapper.x = pos.x
wrapper.y = pos.y
wrapper.width = pos.w
wrapper.height = pos.h
delegateItem.width = pos.w
if (info.mainAxisExtent > 0 || info.mainAxisCellCount > 0)
delegateItem.height = pos.h
wrapper.model = data
try { delegateItem.model = data } catch(e) {}
if (heightConn)
heightConn.target = delegateItem
control.reused(delegateItem)
} else {
wrapper = wrapperComponent.createObject(control.contentItem, {
x: pos.x,
y: pos.y,
width: pos.w,
height: pos.h
})
if (!wrapper) return
wrapper.model = data
// (supports "required property var model" pattern)
delegateItem = control.delegate.createObject(wrapper, { 'model': data })
if (!delegateItem) {
delegateItem = control.delegate.createObject(wrapper)
}
if (!delegateItem) {
wrapper.destroy()
return
}
delegateItem.width = pos.w
if (info.mainAxisExtent > 0 || info.mainAxisCellCount > 0)
delegateItem.height = pos.h
if (info.mainAxisExtent <= 0 && info.mainAxisCellCount <= 0) {
heightConn = _heightWatcherComponent.createObject(delegateItem, {
target: delegateItem
})
}
}
itemMeta[index] = {
wrapper: wrapper,
delegateItem: delegateItem,
heightConn: heightConn
}
}
function recycleItem(index) {
var meta = itemMeta[index]
if (!meta) return
if (meta.heightConn)
meta.heightConn.target = null
control.pooled(meta.delegateItem)
meta.wrapper.parent = _poolContainer
meta.wrapper.visible = false
if (_availablePool.length < control.cachePoolSize) {
_availablePool.push(meta)
} else {
while (_availablePool.length >= control.cachePoolSize) {
var oldest = _availablePool.shift()
if (oldest.heightConn) oldest.heightConn.destroy()
if (oldest.delegateItem) oldest.delegateItem.destroy()
oldest.wrapper.destroy()
}
_availablePool.push(meta)
}
delete itemMeta[index]
}
function recycleAllItems() {
var idxs = Object.keys(itemMeta)
for (var ki = 0; ki < idxs.length; ki++)
recycleItem(parseInt(idxs[ki]))
while (_availablePool.length > 0) {
var meta = _availablePool.pop()
if (meta.heightConn) meta.heightConn.destroy()
if (meta.delegateItem) meta.delegateItem.destroy()
meta.wrapper.destroy()
}
}
function scheduleLayout() {
layoutTimer.restart()
}
function doLayout() {
resolveColumns()
calculatePositions()
recycleAllItems()
updateVisibleRange()
}
onSourceModelChanged: scheduleLayout()
}
Timer {
id: layoutTimer
interval: 1
onTriggered: { d.doLayout() }
}
/*!
Forces a full layout recalculation (column resolution, tile positions,
and visible-range update).
*/
function relayout() {
d.scheduleLayout()
}
/*!
Clears all items, resets layout data, and optionally clears the model
if it exposes a \c clear() function.
*/
function clear() {
d.recycleAllItems()
d.itemPositions = []
d.colHeights = []
d.contentHeight = 0
d._availablePool = []
if (model && typeof model.clear === 'function')
model.clear()
}
/*!
Returns the delegate Item at the given \a index, or \c null if the item
is not currently instantiated (outside the visible range + cache buffer).
*/
function itemAtIndex(index) {
var meta = d.itemMeta[index]
return meta ? meta.delegateItem : null
}
/*!
Returns the index of the visible item at the given content coordinates,
or \c -1 if no item exists at that position.
*/
function indexAt(x, y) {
var positions = d.itemPositions
for (var i = 0; i < positions.length; i++) {
var p = positions[i]
if (x >= p.x && x < p.x + p.w && y >= p.y && y < p.y + p.h)
return i
}
return -1
}
/*!
Scrolls the view so the item at \a index is positioned according to \a mode.
Supported \a mode values:
\list
\li \c "beginning" — top of the view (default)
\li \c "center" — center of the view
\li \c "end" — bottom of the view
\li \c "visible" — only scrolls if item is not already visible
\endlist
*/
function positionViewAtIndex(index, mode) {
if (index < 0 || index >= d.itemPositions.length) return
var pos = d.itemPositions[index]
if (!pos) return
var target
if (mode === "center") {
target = pos.y + pos.h / 2 - height / 2
} else if (mode === "end") {
target = pos.y + pos.h - height
} else if (mode === "visible") {
if (pos.y >= contentY && pos.y + pos.h <= contentY + height)
return
if (pos.y < contentY)
target = pos.y
else
target = pos.y + pos.h - height
} else { // "beginning" (default)
target = pos.y
}
contentY = Math.max(0, Math.min(target, Math.max(0, contentHeight - height)))
}
}
