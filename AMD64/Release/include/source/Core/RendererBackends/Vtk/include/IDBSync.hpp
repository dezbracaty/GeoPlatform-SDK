#pragma once

#include <AutoRegisterDB.hpp>
#include <vtkSmartPointer.h>
#include <vtkObject.h>
#include <vtkProp.h>
#include <vtkRenderer.h>
#include <memory>
#include <IDocumentReadView.hpp>
#include "RenderingContext.hpp"
#include <functional>

class RenderThread;
class vtkGenericOpenGLRenderWindow;
#include <SystemTypes.hpp>
#include "VisualStyle.hpp"
#include "Prop.hpp"

// VTK前向声明
class vtkActor;

/**
 * @brief 渲染层级枚举
 */
enum class RenderLayer {
    BACKGROUND = 0,     // 背景层（如天空盒、网格）
    GEOMETRY = 1,       // 主要几何体层（默认）
    OVERLAY = 2,        // 覆盖层（如坐标轴、测量工具）
    UI_WIDGET = 3,      // UI组件层（始终在最上层）
    DEBUG = 4           // 调试信息层
};


/**
 * @brief DBSync基础接口 - 所有DBSync的基本契约
 * 
 * 核心设计原则：
 * 1. 类型安全 - 移除类型枚举，使用继承关系和dynamic_cast
 * 2. 线程安全 - 统一的VTK操作线程调度机制
 * 3. 清晰的生命周期管理 - 统一的初始化、更新、清理接口
 * 4. 按需渲染上下文 - 轻量级设计，避免不必要的开销
 * 5. 数据只读 - 渲染层只保存 DBInstanceID，通过 IDocumentReadView 获取只读 DB
 * 
 * 架构原则：
 * - DB 层是数据的唯一权威来源
 * - 渲染层只读取 DB，同步到 VTK，绝不修改 DB
 * - 所有 DB 访问通过注入的 IDocumentReadView 获取 const 指针
 */
class IDBSync {
public:
    virtual ~IDBSync() = default;

    // Render-thread hook after camera/DB updates, before drawing or picking.
    virtual void synchronizeView() {}

    void setDocumentReadView(std::shared_ptr<IDocumentReadView> document) {
        m_document = std::move(document);
    }
    
    // === 生命周期管理 ===
    // 只传递 DBInstanceID，不传递 DB 指针
    // DBSync 通过 IDocumentReadView 按需获取只读 DB
    virtual void initialize(
        const DBInstanceID& id,
        vtkSmartPointer<vtkRenderer> renderer,
        std::shared_ptr<RenderThread> renderThread) = 0;
    
    virtual void cleanup(const DBInstanceID& id) = 0;
    
    // === 更新接口 ===
    // 只传递 DBInstanceID，DBSync 内部通过 IDocumentReadView 获取只读 DB
    virtual void update(
        const DBInstanceID& id,
        ChangeType changeType,
        const std::string& propertyName = "") = 0;

    virtual void update(
        const DBInstanceID& id,
        ChangeType changeType,
        const trans::Prop& prop) = 0;
    
    // === 可见性控制 ===
    virtual void setVisible(bool visible) = 0;
    
    // === VTK对象访问 (明确语义) ===
    virtual vtkSmartPointer<vtkObject> getPrimaryVTKObject() const = 0;  // 纯虚函数
    
    // 智能默认实现：如果主要对象是vtkProp，则返回它；否则返回nullptr
    virtual vtkSmartPointer<vtkProp> getVTKProp() const {
        return vtkProp::SafeDownCast(getPrimaryVTKObject());
    }
    
    // === 按需渲染上下文接口 ===
    virtual bool needsRenderingContext() const { 
        return true;  // 默认需要，大部分DBSync都需要渲染上下文
    }
    
    virtual void setRenderingContext(const RenderingContext& context) {
        if (needsRenderingContext()) {
            m_context = context;
            applyRenderingContext();
        }
    }
    
    virtual void applyRenderingContext() {
        // 默认空实现，需要的子类重写
    }
    
    virtual const RenderingContext& getRenderingContext() const {
        return m_context;
    }
    
    // === 渲染层级声明 ===

    /**
     * @brief 声明此 DBSync 默认属于哪个渲染层级
     *
     * DBRenderAdapter 在初始化时根据此返回值从 RenderThread 获取对应层级的渲染器。
     * 子类只需重写此方法声明层级，无需关心渲染器如何创建和配置。
     *
     * 层级在初始化时确定，不支持运行时更改。
     */
    virtual RenderLayer getDefaultRenderLayer() const {
        return RenderLayer::GEOMETRY;  // 默认在主几何层
    }

    // === Pick相关接口 ===

    // 判断某个vtkProp是否属于此DBSync
    virtual bool ownsProp(vtkSmartPointer<vtkProp> prop) const {
        return getVTKProp() == prop;
    }

    // Model Instance DBSync 可将内部 Part actor 映射回稳定的 Part DB ID。
    virtual DBInstanceID partIdForProp(
        vtkSmartPointer<vtkProp> prop) const {
        (void)prop;
        return DBInstanceID{};
    }

    // 判断是否是Widget
    virtual bool isWidget() const {
        return false;  // 默认不是Widget
    }

    // Widget专用：识别Widget的哪个部分
    virtual int identifyWidgetPart(vtkSmartPointer<vtkActor> actor) const {
        return -1;  // 默认不支持部分识别
    }

    // 可选的部件级高亮能力；不支持部件的同步器保持默认 no-op。
    virtual bool highlightPart(int partId, const VisualStyle& style) {
        (void)partId;
        (void)style;
        return false;
    }

    virtual bool clearPartHighlight(int partId) {
        (void)partId;
        return false;
    }

    // === 视觉样式操作接口 ===

    // 应用统一的视觉样式（新的简化接口）
    virtual void applyVisualStyle(const VisualStyle& style) {
        // 默认实现：空方法，子类应该重写
    }

    // 获取当前视觉样式状态
    virtual VisualStyle getCurrentVisualStyle() const {
        // 默认实现：返回空样式，子类应该重写
        return VisualStyle{};
    }

protected:
    template <typename T>
    std::shared_ptr<const T> documentDB(const DBInstanceID& id) const {
        return m_document ? m_document->get<T>(id) : nullptr;
    }

    const std::shared_ptr<IDocumentReadView>& documentReadView() const noexcept {
        return m_document;
    }

    using RenderCommand = std::function<void(vtkGenericOpenGLRenderWindow*, vtkObject*)>;
    void dispatchRenderCommand(RenderCommand command) const;
    void dispatchRenderCommandSync(RenderCommand command) const;
    void requestRender() const;
    void markSceneChanged() const;
    bool isOnRenderThread() const;
    DBInstanceID windowId() const;
    vtkSmartPointer<vtkRenderer> rendererForLayer(RenderLayer layer) const;
    std::shared_ptr<IDBSync> findDBSync(const DBInstanceID& id) const;

    // === 辅助方法 ===
    void addPropToRenderer(vtkSmartPointer<vtkProp> prop) {
        if (m_renderThread && m_vtkRenderer && prop) {
            dispatchRenderCommand([this, prop](auto*, auto*) {
                m_vtkRenderer->AddViewProp(prop);
            });
        }
    }
    
    void removePropFromRenderer(vtkSmartPointer<vtkProp> prop) {
        if (m_renderThread && m_vtkRenderer && prop) {
            dispatchRenderCommand([this, prop](auto*, auto*) {
                m_vtkRenderer->RemoveViewProp(prop);
            });
        }
    }
    
protected:
    // 公共基础设施
    DBInstanceID m_id;  // 只保存 ID，不保存 DB 指针
    vtkSmartPointer<vtkRenderer> m_vtkRenderer;  // 由 DBRenderAdapter 根据层级提供
    std::shared_ptr<RenderThread> m_renderThread;
    std::shared_ptr<IDocumentReadView> m_document;

    // 按需分配的渲染上下文（避免不必要的内存开销）
    RenderingContext m_context;
    int m_highlightedPart = -1;
};
