#pragma once

#include "SystemTypes.hpp"
#include <memory>
#include <vector>

// 前置声明
class ActorDB;

/**
 * @brief 模型位置工具类
 *
 * 提供模型位置计算和调整的通用工具函数，包括：
 * - 贴合托盘：让模型底部贴在打印床表面
 * - 位置调整：避免碰撞和重叠
 * - 几何中心计算
 */
class ModelPositionUtil {
public:
    /**
     * @brief 模型贴合托盘
     *
     * 根据模型的包围盒，计算出让模型底部贴在打印床表面(Z=0)的位置调整量
     *
     * @param basePosition 目标基础位置（通常是鼠标位置或用户指定位置）
     * @param boundingBoxMin 模型包围盒的最小点
     * @param boundingBoxMax 模型包围盒的最大点
     * @return 调整后的位置，确保模型底部贴在打印床上
     */
    static Vector3 adjustPositionToBed(const Vector3& basePosition,
                                       const Vector3& boundingBoxMin,
                                       const Vector3& boundingBoxMax);

    /**
     * @brief 从ActorDB对象计算贴合托盘位置
     *
     * 便捷方法：直接从ActorDB对象获取包围盒并计算贴合位置
     *
     * @param basePosition 目标基础位置
     * @param actor ActorDB对象，用于获取包围盒信息
     * @return 调整后的位置，鼠标位置作为模型中心，底部贴在打印床上
     */
    static Vector3 adjustPositionToBed(const Vector3& basePosition,
                                       std::shared_ptr<ActorDB> actor);

    /**
     * @brief 计算模型的几何中心
     *
     * @param boundingBoxMin 模型包围盒的最小点
     * @param boundingBoxMax 模型包围盒的最大点
     * @return 模型的几何中心点
     */
    static Vector3 calculateGeometryCenter(const Vector3& boundingBoxMin,
                                           const Vector3& boundingBoxMax);

    /**
     * @brief 从包围盒信息计算贴合托盘的Z偏移量
     *
     * 这是核心算法，从UnifiedModelImportHandler中提取
     *
     * @param boundingBoxMin 模型包围盒的最小点
     * @return Z轴偏移量，用于让模型底部贴在打印床上
     */
    static float calculateBedSnapOffset(const Vector3& boundingBoxMin);

    /**
     * @brief 现有对象的信息结构
     */
    struct ExistingObject {
        Vector3 position;  // 对象中心位置
        Vector3 size;      // 对象尺寸
    };

    /**
     * @brief 智能摆放使用的二维平台范围
     *
     * 显式传入范围可以让多打印盘场景使用当前目标盘，而不是隐式依赖
     * 文档中的第一个 PrintBedDB。
     */
    struct PlacementArea {
        float width{400.0f};
        float height{400.0f};
        Vector3 center{0.0f, 0.0f, 0.0f};
    };

    /**
     * @brief 智能摆放：寻找避免与现有对象重叠的位置
     *
     * 使用螺旋式搜索算法，从原点开始向外搜索，找到第一个不与现有对象重叠的位置
     *
     * @param objectSize 新对象的尺寸
     * @param existingObjects 现有对象列表（位置和尺寸信息）
     * @param margin 对象间的最小间距(mm)，默认10mm
     * @return 找到的可用位置，如果找不到返回备选位置
     */
    static Vector3 findAvailablePosition(const Vector3& objectSize,
                                       const std::vector<ExistingObject>& existingObjects,
                                       float margin = 10.0f);

    /**
     * @brief 在指定平台范围内寻找可用位置
     */
    static Vector3 findAvailablePosition(const Vector3& objectSize,
                                       const std::vector<ExistingObject>& existingObjects,
                                       const PlacementArea& placementArea,
                                       float margin = 10.0f);

    /**
     * @brief 检查两个包围盒是否重叠
     *
     * @param pos1 第一个对象的中心位置
     * @param size1 第一个对象的尺寸
     * @param pos2 第二个对象的中心位置
     * @param size2 第二个对象的尺寸
     * @param margin 额外的安全边距
     * @return true如果重叠，false如果不重叠
     */
    static bool checkBoundingBoxOverlap(const Vector3& pos1, const Vector3& size1,
                                        const Vector3& pos2, const Vector3& size2,
                                        float margin = 0.0f);

private:
    /**
     * @brief 检查位置是否在打印平台边界内
     *
     * @param position 对象中心位置
     * @param objectSize 对象尺寸
     * @return true如果在边界内，false如果超出边界
     */
    static bool isPositionWithinPlatformBounds(const Vector3& position, const Vector3& objectSize);

    ModelPositionUtil() = delete; // 静态工具类，禁止实例化
};
