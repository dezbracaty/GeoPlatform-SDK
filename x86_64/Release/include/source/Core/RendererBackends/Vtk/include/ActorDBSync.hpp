#pragma once

#include "IDBSync.hpp"
#include "VisualStyle.hpp"
#include <ActorDB.hpp>
#include <vtkActor.h>
#include <vtkProperty.h>
#include <vtkPolyDataAlgorithm.h>
#include "Foundation/Log.h"
#include <array>
#include <string_view>

/**
 * @brief Actor类型DBSync的抽象基类 - 采用模板方法模式
 * 
 * 设计理念：
 * - 基类负责：VTK对象生命周期管理，标准更新逻辑，渲染上下文应用
 * - 子类负责：特定几何体的创建逻辑，几何参数更新，特殊扩展逻辑
 * 
 * 方法分类：
 * - final方法：算法骨架，子类不可重写
 * - 纯虚函数：子类必须实现的核心逻辑  
 * - 钩子函数：子类可选重写的扩展点
 * - private方法：基类内部实现，子类不应访问
 */
class ActorDBSync : public IDBSync, public std::enable_shared_from_this<ActorDBSync> {
public:
    
    // 实现IDBSync接口
    void initialize(
        const DBInstanceID& id,
        vtkSmartPointer<vtkRenderer> renderer,
        std::shared_ptr<RenderThread> renderThread) override;
        
    void cleanup(const DBInstanceID& id) override;
    
    // 实现VTK对象访问接口
    vtkSmartPointer<vtkObject> getPrimaryVTKObject() const override { return m_actor; }
    // getVTKProp()使用基类的智能默认实现，因为vtkActor IS-A vtkProp
    
    RenderLayer getDefaultRenderLayer() const override {
        return RenderLayer::GEOMETRY;  // Actor默认在几何体层
    }
    
    // === 模板方法（final - 子类不可重写）===
    void update(
        const DBInstanceID& id,
        ChangeType changeType,
        const std::string& propertyName = "") override final;


        // 定义更新算法的骨架
        // 注意：现在所有属性变化都使用 ChangeType::PROPERTY_CHANGED
        // 具体的更新类型通过 PropertyCategory 判断（在 DBRenderAdapter 中处理）
        void updateFromStringProperty(ChangeType changeType, const std::string& propertyName);

    void update(
        const DBInstanceID& id,
        ChangeType changeType,
        const trans::Prop& prop) override final;
    
    void setVisible(bool visible) override final {
        // 基类提供标准的可见性设置逻辑
        if (m_renderThread) {
            dispatchRenderCommand([this, visible](auto*, auto*) {
                if (m_actor) {
                    m_actor->SetVisibility(visible ? 1 : 0);
                }
                // 调用钩子让子类扩展
                onVisibilityChanged(visible);
            });
        }
    }
    
    void applyRenderingContext() override final {
        // 基类处理标准的上下文应用
        if (m_renderThread) {
            dispatchRenderCommand([this](auto*, auto*) {
                if (m_actor) {
                    applyMaterialContext();
                    applyGeometryContext();
                }
                // 调用钩子让子类扩展
                onRenderingContextApplied(getRenderingContext());
            });
        }
    }
    
protected:
    // === 纯虚函数（子类必须实现）===
    virtual void createActor() = 0;
    virtual void updateGeometry(const std::string& prop) = 0;

    // === 钩子函数（子类可选重写，有合理默认实现）===
    virtual void onMaterialChanged(const std::string& prop) {
        // 默认空实现 - 基类已经处理了标准材质更新
    }

    virtual void onTransformChanged(const std::string& prop) {
        // 默认空实现 - 基类已经处理了标准变换更新
    }

    virtual void onVisibilityChanged(bool visible) {
        // 默认空实现 - 基类已经处理了标准可见性更新
    }

    virtual void onRenderingContextApplied(const RenderingContext& context) {
        // 默认空实现 - 基类已经处理了标准上下文应用
    }


    virtual void onOtherChangeType(ChangeType changeType, const std::string& prop) {
        // 默认空实现 - 处理未明确分类的变化类型
    }

    // 🔑 钩子：控制是否应用 MaterialDB 的属性
    // 子类可以重写返回 false 来跳过 Material 应用。
    virtual bool shouldApplyMaterial() const { return true; }

    // 子类声明自己的几何属性，避免把每种 DB 的字段硬编码到基类。
    virtual bool isGeometryProperty(std::string_view prop) const { return false; }
    // 完全不影响渲染的属性可以在这里截断，不再误走材质更新。
    virtual bool isRenderIgnoredProperty(std::string_view prop) const {
        return prop == "WorldBounds";
    }

    // === 辅助方法（供子类钩子使用）===
    void applyMaterialFromDB();
    void applyTransformFromDB();
    // 直接使用 VisualStyle 设计，无需额外的状态管理
    void applyMaterialContext();    // 应用材质上下文
    void applyGeometryContext();    // 应用几何上下文

private:
    // === 材质应用辅助方法（内部使用）===
    void applyCommonParameters(vtkProperty* property);
    void applyLightingModelParameters(vtkProperty* property);
    void applyPBRParameters(vtkProperty* property);
    void applyPhongParameters(vtkProperty* property);

    // === 简化的视觉状态功能 ===
    void applyVisualStyle(const VisualStyle& style) override;
    VisualStyle getCurrentVisualStyle() const override;


protected:
    // Actor特有的成员
    vtkSmartPointer<vtkActor> m_actor;
    vtkSmartPointer<vtkPolyDataAlgorithm> m_source;


private:
    // === 内部方法（子类不应访问）===
    void updateMaterialInternal(const std::string& prop);
    void applyHoveredPart();

    void updateTransformInternal(const std::string& prop);

    void updateVisibilityInternal(const std::string& prop);

};
