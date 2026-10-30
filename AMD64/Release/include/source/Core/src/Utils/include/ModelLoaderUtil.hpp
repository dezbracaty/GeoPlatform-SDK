#pragma once

#include <QString>
#include <QFileInfo>
#include <memory>
#include <vector>
#include "SystemTypes.hpp"
#include <Geometry.hpp>

// 前置声明 VTK 类，避免在头文件中包含 VTK 头文件
class vtkPolyData;
class vtkAlgorithmOutput;

/**
 * @brief 模型加载工具类
 *
 * 支持多种3D模型格式的加载，包括：
 * - STL (二进制和ASCII)
 * - OBJ (带材质)
 * - glTF JSON（GLB 由 GlbDBImporter 独占处理）
 * - PLY (点云格式)
 * - FBX (需要额外支持)
 * - 3DS
 * - DAE (Collada)
 *
 * 3MF 是项目容器格式，明确由 libslicer 处理，不在此通用网格加载器中解析。
 */
class ModelLoaderUtil {
public:
    /**
     * @brief 模型加载结果结构
     */
    struct LoadResult {
        bool success{false};
        QString errorMessage;
        std::vector<GeomTriangle> triangles;
        Vector3 boundingBoxMin;
        Vector3 boundingBoxMax;
        Vector3 center;
        QString modelName;
        size_t vertexCount{0};
        size_t faceCount{0};
        bool hasNormals{false};
        bool hasTexCoords{false};
        bool hasColors{false};

        // 可选：材质信息
        struct MaterialInfo {
            Vector3 color{0.8f, 0.8f, 0.8f};
            float metallic{0.0f};
            float roughness{0.5f};
            QString texturePath;
        };
        std::optional<MaterialInfo> material;
    };

    /**
     * @brief 支持的文件格式
     */
    static QStringList supportedFormats() {
        return QStringList()
            << "*.stl" << "*.STL"
            << "*.obj" << "*.OBJ"
            << "*.gltf" << "*.GLTF"
            << "*.ply" << "*.PLY"
            << "*.3ds" << "*.3DS"
            << "*.dae" << "*.DAE"
            << "*.fbx" << "*.FBX";
    }

    /**
     * @brief 检查文件格式是否支持
     */
    static bool isFormatSupported(const QString& filePath);

    /**
     * @brief 加载3D模型文件
     * @param filePath 文件路径
     * @param scale 缩放因子（默认1.0）
     * @return 加载结果
     */
    static LoadResult loadModel(const QString& filePath, float scale = 1.0f);

    /**
     * @brief 根据文件扩展名获取格式类型
     */
    static QString getFormatType(const QString& filePath);

private:
    // 格式特定的加载函数
    static LoadResult loadSTL(const QString& filePath, float scale);
    static LoadResult loadOBJ(const QString& filePath, float scale);
    static LoadResult loadGLTF(const QString& filePath, float scale);
    static LoadResult loadPLY(const QString& filePath, float scale);
    static LoadResult load3DS(const QString& filePath, float scale);
    static LoadResult loadDAE(const QString& filePath, float scale);
    static LoadResult loadFBX(const QString& filePath, float scale);

    // VTK PolyData 转换为三角形列表
    static std::vector<GeomTriangle> convertPolyDataToTriangles(vtkPolyData* polyData, float scale);

    // 计算边界框
    static void calculateBounds(const std::vector<GeomTriangle>& triangles,
                               Vector3& minBounds, Vector3& maxBounds, Vector3& center);

    // 中心化模型数据 - 将几何中心移动到原点
    static void centerModelData(std::vector<GeomTriangle>& triangles,
                               Vector3& minBounds, Vector3& maxBounds, Vector3& center);

    // 辅助函数
    static bool checkFileReadable(const QString& filePath, LoadResult& result);
};
