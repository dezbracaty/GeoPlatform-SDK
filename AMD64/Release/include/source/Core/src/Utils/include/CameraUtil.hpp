#pragma once

#include <memory>
#include <CameraDB.hpp>

/**
 * @brief 相机工具类
 *
 * 提供相机相关的工具函数，包括：
 * - 智能相机适应
 * - 相机位置计算
 */
class CameraUtil {
public:
    /**
     * @brief 智能适应相机：保持相机角度，只调整距离以适应场景
     *
     * @param camera 相机实例
     * @param renderer VTK渲染器（可选，用于计算场景边界）
     */
    static void smartFitCamera(std::shared_ptr<CameraDB> camera, void* renderer = nullptr);

    /**
     * @brief 计算场景边界并调整相机距离
     *
     * @param camera 相机实例
     * @param sceneBounds 场景边界 [minX, maxX, minY, maxY, minZ, maxZ]
     */
    static void fitCameraToBounds(std::shared_ptr<CameraDB> camera, const float* sceneBounds);

private:
    // 私有构造函数，防止实例化
    CameraUtil() = delete;
    ~CameraUtil() = delete;
};
