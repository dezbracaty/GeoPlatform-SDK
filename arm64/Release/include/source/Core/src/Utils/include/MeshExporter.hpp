#pragma once

#include <string>
#include <memory>

class vtkPolyData;

namespace GPlatform {

/**
 * @brief 网格导出工具类
 *
 * 提供静态方法将网格数据导出为各种格式
 * 只接收明确的 vtkPolyData；模型图调用方负责选择需要导出的 Part。
 */
class MeshExporter {
public:
    /**
     * @brief 将 vtkPolyData 导出为 STL 文件
     * @param polyData VTK PolyData 数据
     * @param filePath 输出文件路径
     * @param binary 是否使用二进制格式（默认 true）
     * @return 导出成功返回 true
     */
    static bool exportToSTL(vtkPolyData* polyData, const std::string& filePath, bool binary = true);

private:
    MeshExporter() = delete;  // 禁止实例化
};

} // namespace GPlatform
