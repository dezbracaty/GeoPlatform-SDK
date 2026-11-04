#pragma once

#include <QColor>
#include <RendererRole.hpp>
#include <SystemTypes.hpp>
#include <memory>

/**
 * @brief 渲染模式枚举
 * 
 * 定义不同的渲染效果模式
 */
enum class RenderingMode {
    STANDARD,       // 标准模式 - 完整细节
    WIREFRAME,      // 线框模式 - 仅轮廓  
    SIMPLIFIED,     // 简化模式 - 低多边形
    HIGHLIGHT,      // 高亮模式 - 增强显示
    XRAY,          // 透视模式 - 半透明
    BLUEPRINT      // 蓝图模式 - 工程图样式
};

/**
 * @brief 渲染上下文类
 * 
 * 包含渲染模式、材质覆盖、几何变换、细节等级等配置
 * 通过这个类实现同一个DB对象在不同RenderThread中的差异化渲染
 */
class RenderingContext {
public:
    /**
     * @brief 材质覆盖设置
     */
    struct MaterialOverride {
        QColor color = QColor();  // 无效颜色，表示不覆盖原始Material颜色
        float opacity = -1.0f;    // -1表示不覆盖原始透明度
        float metallic = 0.0f;
        float roughness = 0.5f;
        bool wireframe = false;
        float lineWidth = 1.0f;
        bool edgeVisibility = false;
        QColor edgeColor = QColor(0, 0, 0);
        
        bool operator==(const MaterialOverride& other) const {
            return color == other.color &&
                   opacity == other.opacity &&
                   metallic == other.metallic &&
                   roughness == other.roughness &&
                   wireframe == other.wireframe &&
                   lineWidth == other.lineWidth &&
                   edgeVisibility == other.edgeVisibility &&
                   edgeColor == other.edgeColor;
        }
    };
    
    /**
     * @brief 几何体变换设置
     */
    struct GeometryTransform {
        Vector3 scaleMultiplier = {1.0f, 1.0f, 1.0f};
        Vector3 offsetDelta = {0.0f, 0.0f, 0.0f};
        bool applyJitter = false; // 添加微小随机偏移
        float jitterAmount = 0.01f;
        
        bool operator==(const GeometryTransform& other) const {
            return scaleMultiplier == other.scaleMultiplier &&
                   offsetDelta == other.offsetDelta &&
                   applyJitter == other.applyJitter &&
                   jitterAmount == other.jitterAmount;
        }
    };
    
    /**
     * @brief 细节等级控制
     */
    struct LevelOfDetail {
        float tessellationScale = 1.0f;  // 细分倍数
        int maxPolygons = -1;            // 最大多边形数(-1=无限制)
        bool adaptiveDetail = false;     // 基于距离的自适应细节
        float adaptiveThreshold = 100.0f; // 自适应阈值
        
        bool operator==(const LevelOfDetail& other) const {
            return tessellationScale == other.tessellationScale &&
                   maxPolygons == other.maxPolygons &&
                   adaptiveDetail == other.adaptiveDetail &&
                   adaptiveThreshold == other.adaptiveThreshold;
        }
    };
    
    // === 构造函数 ===
    RenderingContext() = default;
    explicit RenderingContext(RenderingMode mode) : m_mode(mode) {}
    
    // === 基础模式访问器 ===
    RenderingMode getMode() const { return m_mode; }
    void setMode(RenderingMode mode) { m_mode = mode; }
    
    // === 配置访问器 ===
    const MaterialOverride& getMaterialOverride() const { return m_materialOverride; }
    MaterialOverride& getMaterialOverride() { return m_materialOverride; }
    
    const GeometryTransform& getGeometryTransform() const { return m_geometryTransform; }
    GeometryTransform& getGeometryTransform() { return m_geometryTransform; }
    
    const LevelOfDetail& getLevelOfDetail() const { return m_levelOfDetail; }
    LevelOfDetail& getLevelOfDetail() { return m_levelOfDetail; }
    
    // === 设置方法 ===
    void setMaterialOverride(const MaterialOverride& override) { 
        m_materialOverride = override; 
    }
    
    void setGeometryTransform(const GeometryTransform& transform) { 
        m_geometryTransform = transform; 
    }
    
    void setLevelOfDetail(const LevelOfDetail& lod) { 
        m_levelOfDetail = lod; 
    }
    
    // === 预设配置工厂方法 ===
    static RenderingContext createStandardContext();
    static RenderingContext createWireframeContext();
    static RenderingContext createBlueprintContext();
    static RenderingContext createXRayContext();
    static RenderingContext createSimplifiedContext();
    static RenderingContext createHighlightContext();

    // 将页面角色的展示策略合成到当前视觉模式中。该覆盖只存在于
    // 当前渲染会话，不会写回共享 DB。
    RenderingContext withRendererRole(
        GPlatform::Rendering::RendererRole role) const;
    
    // === 比较操作符 ===
    bool operator==(const RenderingContext& other) const {
        return m_mode == other.m_mode &&
               m_materialOverride == other.m_materialOverride &&
               m_geometryTransform == other.m_geometryTransform &&
               m_levelOfDetail == other.m_levelOfDetail;
    }
    
    bool operator!=(const RenderingContext& other) const {
        return !(*this == other);
    }
    
    // === 克隆方法 ===
    RenderingContext clone() const {
        RenderingContext copy;
        copy.m_mode = m_mode;
        copy.m_materialOverride = m_materialOverride;
        copy.m_geometryTransform = m_geometryTransform;
        copy.m_levelOfDetail = m_levelOfDetail;
        return copy;
    }

private:
    RenderingMode m_mode = RenderingMode::STANDARD;
    MaterialOverride m_materialOverride;
    GeometryTransform m_geometryTransform;
    LevelOfDetail m_levelOfDetail;
};
