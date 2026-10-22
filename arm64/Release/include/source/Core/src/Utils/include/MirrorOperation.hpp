#pragma once

#include "ActorDB.hpp"
#include <Geometry.hpp>
#include "SystemTypes.hpp"
#include <vector>

/**
 * @brief 镜像操作工具类
 *
 * 提供模型镜像变换的计算和执行功能
 * 参考 OrcaSlicer 的实现方式，直接修改几何数据而不是使用变换矩阵
 */
class MirrorOperation {
public:
    /**
     * @brief 镜像轴向枚举
     */
    enum class MirrorAxis {
        X_AXIS,  // X 轴镜像
        Y_AXIS,  // Y 轴镜像
        Z_AXIS   // Z 轴镜像
    };

    /**
     * @brief 对单个 Actor 执行镜像操作
     * @param actor 要镜像的 ModelInstanceDB
     * @param axis 镜像轴向
     * 
     * 实现方式：
     * 对 Instance 的全部 Part 生成镜像网格，并通过 ModelGraphUtil
     * 主动替换每个 Part 的几何。
     */
    static void applyMirrorToActor(std::shared_ptr<ActorDB> actor, MirrorAxis axis);

    /**
     * @brief 对多个 Actor 执行镜像操作
     * @param actors 要镜像的 Actor 列表
     * @param axis 镜像轴向
     */
    static void applyMirrorToActors(const std::vector<std::shared_ptr<ActorDB>>& actors, MirrorAxis axis);

    /**
         * @brief 创建镜像副本
         * @param actor 原始 ModelInstanceDB
         * @param axis 镜像轴向
         * @return 镜像后的副本
         * 
         * 实现方式：
         * 创建新的 Object / Part / Instance 图，原图不变。
         */
        static std::shared_ptr<ActorDB> createMirroredCopy(std::shared_ptr<ActorDB> actor, MirrorAxis axis);
    
    private:
    };
