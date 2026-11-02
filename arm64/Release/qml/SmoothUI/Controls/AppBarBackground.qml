pragma Singleton
import QtQuick
/**
* AppBarBackground - 全局 AppBar 背景配置单例
*
* ========================================
* 功能说明
* ========================================
*
* 本单例用于全局配置 NavigationView 的 AppBar 背景样式。
* 支持页面声明式背景配置，页面切换时自动应用。
*
* ========================================
* 页面声明式使用（推荐）
* ========================================
*
* 在页面中声明 appBarBackground 属性，NavigationView 会自动检测并应用：
*
* ContentPage {
*     // 声明标题栏背景
*     property var appBarBackground: ({
*         type: "gradient",
*         colors: ["#667eea", "#764ba2"],
*         direction: "vertical"
*     })
*
*     // 页面内容...
* }
*
* 如果页面不声明 appBarBackground，则使用所在 NavigationView 的主题背景。
*
* ---------- 示例 1: 纯色背景 ----------
* property var appBarBackground: ({ type: "color", color: "#2B579A" })
*
* ---------- 示例 2: 带透明度的纯色背景 ----------
* property var appBarBackground: ({ type: "color", color: "#802B579A" })
*
* ---------- 示例 3: 渐变背景 ----------
* property var appBarBackground: ({
*     type: "gradient",
*     colors: ["#2B579A", "#1E3A6E"],
*     direction: "vertical"
* })
*
* ---------- 示例 4: 透明背景 ----------
* property var appBarBackground: ({ type: "transparent" })
*
* ========================================
* 编程式使用（向后兼容）
* ========================================
*
* AppBarBackground.setColor("#2B579A")
* AppBarBackground.setGradient(["#667eea", "#764ba2"], "vertical")
* AppBarBackground.setTransparent()
*
* ========================================
*/
QtObject {
id: control
/**
* 默认背景配置
* 当页面未声明 appBarBackground 时使用；null 表示使用局部主题背景
*/
property var defaultBackground: null
/**
* 背景类型
* - "default": 使用所在 NavigationView 的主题背景
* - "transparent": 透明背景
* - "color": 纯色背景
* - "gradient": 渐变背景
*/
property string type: "default"
/**
* 纯色背景颜色
* 支持:
* - "#RRGGBB" 格式
* - "#AARRGGBB" 格式 (带透明度)
* - Qt.rgba(r, g, b, a) 返回值
*/
property color backgroundColor: "#2B579A"
/**
* 渐变颜色数组
* 每个颜色支持透明度: ["#802B579A", "#801E3A6E"]
*/
property var gradientColors: ["#2B579A", "#1E3A6E"]
/**
* 渐变方向
* - "vertical": 从上到下
* - "horizontal": 从左到右
*/
property string gradientDirection: "vertical"
/**
* 设置纯色背景
* @param color 颜色值，支持 "#RRGGBB" 或 "#AARRGGBB" 格式
*/
function setColor(color) {
control.type = "color"
control.backgroundColor = color
}
/**
* 设置渐变背景
* @param colors 颜色数组，支持 2-4 个颜色，每个颜色可带透明度
* @param direction 渐变方向: "vertical" 或 "horizontal"
*/
function setGradient(colors, direction) {
control.type = "gradient"
control.gradientColors = colors
control.gradientDirection = direction || "vertical"
}
/**
* 设置透明背景
*/
function setTransparent() {
control.type = "transparent"
}
/**
* 重置为默认背景
*/
function resetToDefault() {
applyConfig(defaultBackground)
}
/**
* 应用背景配置
* @param config 背景配置对象，可为 null（使用默认背景）
*
* 配置格式：
* - { type: "transparent" }
* - { type: "color", color: "#RRGGBB" }
* - { type: "gradient", colors: [...], direction: "vertical"|"horizontal" }
*/
function applyConfig(config) {
if (!config) {
config = defaultBackground
}
if (!config) {
control.type = "default"
return
}
if (config.type === "transparent") {
control.type = "transparent"
} else if (config.type === "color") {
control.type = "color"
control.backgroundColor = config.color
} else if (config.type === "gradient") {
control.type = "gradient"
control.gradientColors = config.colors
control.gradientDirection = config.direction || "vertical"
}
}
/**
* 获取当前配置对象（供 NavigationView 内部使用）
*/
function getConfig() {
if (type === "default") {
return null
} else if (type === "transparent") {
return { type: "transparent" }
} else if (type === "color") {
return { type: "color", color: backgroundColor }
} else {
return {
type: "gradient",
colors: gradientColors,
direction: gradientDirection
}
}
}
}
