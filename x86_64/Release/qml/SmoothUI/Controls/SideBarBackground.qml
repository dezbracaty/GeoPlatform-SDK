pragma Singleton
import QtQuick
/**
* SideBarBackground - 全局侧边栏背景配置单例
*
* ========================================
* 功能说明
* ========================================
*
* 本单例用于全局配置 NavigationView 的侧边栏背景样式。
* 支持页面声明式背景配置，页面切换时自动应用。
*
* ========================================
* 页面声明式使用（推荐）
* ========================================
*
* 在页面中声明 sideBarBackground 属性，NavigationView 会自动检测并应用：
*
* ContentPage {
*     // 声明侧边栏背景
*     property var sideBarBackground: ({
*         type: "gradient",
*         colors: ["#1E3A6E", "#2B579A"],
*         direction: "vertical"
*     })
*
*     // 页面内容...
* }
*
* 如果页面不声明 sideBarBackground，则使用默认背景（主题 mica 背景色）。
*
* ---------- 示例 1: 纯色背景 ----------
* property var sideBarBackground: ({ type: "color", color: "#2B579A" })
*
* ---------- 示例 2: 带透明度的纯色背景 ----------
* property var sideBarBackground: ({ type: "color", color: "#802B579A" })
*
* ---------- 示例 3: 渐变背景 ----------
* property var sideBarBackground: ({
*     type: "gradient",
*     colors: ["#2B579A", "#1E3A6E"],
*     direction: "vertical"
* })
*
* ---------- 示例 4: 透明背景 ----------
* property var sideBarBackground: ({ type: "transparent" })
*
* ========================================
*/
QtObject {
id: control
/**
* 默认背景配置
* 当页面未声明 sideBarBackground 时使用
* null 表示使用主题默认背景
*/
property var defaultBackground: null
/**
* 背景类型
* - "default": 使用主题默认背景
* - "transparent": 透明背景
* - "color": 纯色背景
* - "gradient": 渐变背景
*/
property string type: "default"
/**
* 纯色背景颜色
*/
property color backgroundColor: "#F3F3F3"
/**
* 渐变颜色数组
*/
property var gradientColors: ["#F3F3F3", "#E8E8E8"]
/**
* 渐变方向
* - "vertical": 从上到下
* - "horizontal": 从左到右
*/
property string gradientDirection: "vertical"
/**
* 设置纯色背景
*/
function setColor(color) {
control.type = "color"
control.backgroundColor = color
}
/**
* 设置渐变背景
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
* 重置为默认背景（使用主题背景）
*/
function resetToDefault() {
applyConfig(defaultBackground)
}
/**
* 应用背景配置
* @param config 背景配置对象，可为 null（使用默认背景）
*/
function applyConfig(config) {
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
* 获取当前配置对象
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
