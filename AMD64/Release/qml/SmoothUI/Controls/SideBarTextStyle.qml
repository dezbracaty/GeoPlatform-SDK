pragma Singleton
import QtQuick
/**
* SideBarTextStyle 单例
*
* 用于管理侧边栏文字样式，支持页面声明式配置。
*
* 页面使用方式：
* 在页面中声明 sideBarTextStyle 属性，NavigationView 会自动检测并应用：
*
* ContentPage {
*     property var sideBarTextStyle: ({
*         normalColor: "#333333",
*         selectedColor: "#0066CC",
*         disabledColor: "#999999"
*     })
* }
*
* 如果页面不声明 sideBarTextStyle，则使用主题默认颜色。
*/
QtObject {
id: control
property var defaultStyle: null
property color normalColor: "#333333"
property color selectedColor: "#0066CC"
property color disabledColor: "#999999"
property color hoverColor: "#555555"
property string type: "default"  // "default" 或 "custom"
/**
* 设置文字颜色配置
* @param config 配置对象 { normalColor, selectedColor, disabledColor, hoverColor }
*/
function setColors(config) {
if (!config) {
resetToDefault()
return
}
control.type = "custom"
if (config.normalColor !== undefined) {
control.normalColor = config.normalColor
}
if (config.selectedColor !== undefined) {
control.selectedColor = config.selectedColor
}
if (config.disabledColor !== undefined) {
control.disabledColor = config.disabledColor
}
if (config.hoverColor !== undefined) {
control.hoverColor = config.hoverColor
}
}
/**
* 重置为默认样式
*/
function resetToDefault() {
control.type = "default"
control.normalColor = "#333333"
control.selectedColor = "#0066CC"
control.disabledColor = "#999999"
control.hoverColor = "#555555"
}
/**
* 应用配置
* @param config 配置对象
*/
function applyConfig(config) {
if (!config) {
resetToDefault()
return
}
setColors(config)
}
/**
* 获取当前配置
* @returns 配置对象
*/
function getConfig() {
return {
type: control.type,
normalColor: control.normalColor,
selectedColor: control.selectedColor,
disabledColor: control.disabledColor,
hoverColor: control.hoverColor
}
}
}
