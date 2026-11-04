#pragma once

#include "IDBSync.hpp"
#include "VisualStyle.hpp"
#include <WidgetDB.hpp>
#include <vtkSmartPointer.h>
#include <vtkRenderer.h>
#include <vtkProp.h>
#include <vtkGenericOpenGLRenderWindow.h>
#include <memory>
#include <vector>

/**
 * @brief Widget类型DBSync的抽象基类 - 采用模板方法模式
 *
 * 设计理念：
 * - 基类负责：Widget生命周期管理，标准更新逻辑
 * - 子类负责：特定Widget的创建逻辑，属性更新
 *
 * 渲染层级管理：
 * - 渲染层级由 RenderThread 统一创建和配置
 * - DBRenderAdapter 根据 getDefaultRenderLayer() 获取正确层级的渲染器
 * - 子类只需声明层级，直接使用 m_vtkRenderer
 */
class WidgetDBSync : public IDBSync, public std::enable_shared_from_this<WidgetDBSync> {
public:
    RenderLayer getDefaultRenderLayer() const override {
        return RenderLayer::UI_WIDGET;  // Widget默认在UI层
    }
    
    bool needsRenderingContext() const override {
        return true;  // Widget通常需要渲染上下文
    }
    
    // 实现IDBSync接口
    void initialize(
        const DBInstanceID& id,
        vtkSmartPointer<vtkRenderer> renderer,
        std::shared_ptr<RenderThread> renderThread) override;
        
    void cleanup(const DBInstanceID& id) override;
    
    // Widget的getPrimaryVTKObject返回主要的Prop
    vtkSmartPointer<vtkObject> getPrimaryVTKObject() const override {
        return m_widgetProps.empty() ? nullptr : m_widgetProps[0];
    }
    
    // Widget的getVTKProp()返回主要的Prop
    vtkSmartPointer<vtkProp> getVTKProp() const override {
        return m_widgetProps.empty() ? nullptr : m_widgetProps[0];
    }
    
    // === 模板方法（final - 子类不可重写）===
    void update(
        const DBInstanceID& id,
        ChangeType changeType,
        const std::string& propertyName = "") override final {

        // Widget的更新逻辑统一处理
        switch(changeType) {
            case ChangeType::OBJECT_CREATED:
                // 对象创建时，需要更新所有内容
                updateWidgetPropertiesInternal(propertyName);
                updateVisibilityInternal(propertyName);
                break;
            case ChangeType::OBJECT_DELETED:
                // 对象删除，不需要更新
                break;
            case ChangeType::PROPERTY_CHANGED:
                // 属性变化，根据属性名判断更新类型
                if (propertyName == "Visible" || propertyName == "Opacity") {
                    updateVisibilityInternal(propertyName);
                } else {
                    // 通用属性更新 + 子类钩子
                    updateWidgetPropertiesInternal(propertyName);
                }
                break;
            default:
                // 其他类型，默认处理
                updateWidgetPropertiesInternal(propertyName);
                break;
        }
    }

    void update(
        const DBInstanceID& id,
        ChangeType changeType,
        const trans::Prop& prop) override final {
        // Prop 参数版本：使用 PROP_##name() 语法进行属性比较

        // Widget的更新逻辑统一处理
        switch(changeType) {
            case ChangeType::OBJECT_CREATED:
                // 对象创建时，需要更新所有内容
                updateWidgetPropertiesInternal(prop.name());
                updateVisibilityInternal(prop.name());
                break;
            case ChangeType::OBJECT_DELETED:
                // 对象删除，不需要更新
                break;
            case ChangeType::PROPERTY_CHANGED:
                // 属性变化，根据属性名判断更新类型
                // 🎯 使用 PROP_##name() 语法进行属性比较
                if (prop == WidgetDB::PROP_Visible() || prop == WidgetDB::PROP_Opacity()) {
                    updateVisibilityInternal(prop.name());
                } else {
                    // 通用属性更新 + 子类钩子
                    updateWidgetPropertiesInternal(prop.name());
                }
                break;
            default:
                // 其他类型，默认处理
                updateWidgetPropertiesInternal(prop.name());
                break;
        }
    }
    
    void setVisible(bool visible) override final {
        if (m_renderThread) {
            dispatchRenderCommand([this, visible](auto*, auto*) {
                for (auto& prop : m_widgetProps) {
                    if (prop) {
                        prop->SetVisibility(visible ? 1 : 0);
                    }
                }
                // 调用钩子让子类扩展
                onVisibilityChanged(visible);
            });
        }
    }
    
    void applyRenderingContext() override final {
        if (!needsRenderingContext()) return;

        if (m_renderThread) {
            dispatchRenderCommand([this](auto*, auto*) {
                applyWidgetContext();
                onRenderingContextApplied(getRenderingContext());
            });
        }
    }

    // === Widget部件高亮接口（子类可选重写）===

    /**
     * @brief 高亮Widget的特定部分
     * @param partId 部件ID（由identifyWidgetPart返回）
     * @param style 高亮样式
     * @return true如果成功高亮，false如果不支持或失败
     */
    bool highlightPart(int partId, const VisualStyle& style) override {
        // 默认实现：不支持部件级高亮
        return false;
    }

    /**
     * @brief 清除Widget特定部分的高亮
     * @param partId 部件ID
     * @return true如果成功清除，false如果不支持或失败
     */
    bool clearPartHighlight(int partId) override {
        // 默认实现：不支持部件级高亮
        return false;
    }

protected:

    // === 纯虚函数（子类必须实现）===
    virtual void createWidget() = 0;

    // === 钩子函数（子类可选重写）===
    virtual void onWidgetPropertyChanged(const std::string& prop) = 0;
    
    virtual void onVisibilityChanged(bool visible) {
        // 默认空实现，子类可扩展
    }
    
    virtual void onRenderingContextApplied(const RenderingContext& context) {
        // 默认空实现，子类可扩展
    }
    
    // === Widget辅助方法 ===
    void addWidgetProp(vtkSmartPointer<vtkProp> prop) {
        if (prop) {
            m_widgetProps.push_back(prop);
            if (m_renderThread && m_vtkRenderer) {
                dispatchRenderCommand([this, prop](auto*, auto*) {
                    m_vtkRenderer->AddViewProp(prop);
                });
            }
        }
    }

    void removeWidgetProp(vtkSmartPointer<vtkProp> prop) {
        auto it = std::find(m_widgetProps.begin(), m_widgetProps.end(), prop);
        if (it != m_widgetProps.end()) {
            m_widgetProps.erase(it);
            if (m_renderThread && m_vtkRenderer) {
                dispatchRenderCommand([this, prop](auto*, auto*) {
                    m_vtkRenderer->RemoveViewProp(prop);
                });
            }
        }
    }

    virtual void updateWidgetTransform();
    virtual void applyWidgetContext();

protected:
    // Widget特有的成员
    std::vector<vtkSmartPointer<vtkProp>> m_widgetProps;

private:

    // === 内部方法（子类不应访问）===
    void updateWidgetPropertiesInternal(const std::string& prop) {
        if (prop == "HoveredPart") {
            applyHoveredPart();
            return;
        }

        // 处理通用的Widget属性
        if (prop.find("Position") != std::string::npos ||
            prop.find("Viewport") != std::string::npos ||
            prop.find("Transform") != std::string::npos) {
            updateWidgetTransform();
        }

        // 调用子类钩子处理具体属性
        onWidgetPropertyChanged(prop);
    }

    void applyHoveredPart();
    void updateVisibilityInternal(const std::string& prop);
};
