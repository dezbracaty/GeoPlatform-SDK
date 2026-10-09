#pragma once

#include <QObject>
#include <QThread>
#include <QString>
#include <SystemTypes.hpp> // 使用项目的Vector3定义
#include <Geometry.hpp>
#include <memory>
#include <cfloat> // for FLT_MAX
#include <atomic>
#include <vtkSmartPointer.h>

class vtkPolyData;

/**
 * @brief STL文件加载器 - 基于VTK的实现
 *
 * 使用VTK的STL读取器在后台线程加载STL文件
 * 支持ASCII和二进制STL格式
 */
class STLLoader : public QObject {
    Q_OBJECT

public:
    /**
     * @brief STL数据结构（旧接口，兼容使用）
     */
    struct STLData {
        QString fileName;
        std::vector<GeomTriangle> triangles;
        Vector3 boundingBoxMin;
        Vector3 boundingBoxMax;
        size_t vertexCount = 0;
        size_t triangleCount = 0;
        bool isValid = false;
        QString errorMessage;

        STLData()
            : boundingBoxMin(FLT_MAX, FLT_MAX, FLT_MAX), boundingBoxMax(-FLT_MAX, -FLT_MAX, -FLT_MAX) {
        }
    };

    explicit STLLoader(QObject* parent = nullptr);
    ~STLLoader() override;

    /**
     * @brief 异步加载STL文件
     * @param filePath STL文件路径
     */
    void loadSTLAsync(const QString& filePath);

    /**
     * @brief 同步加载STL文件（阻塞调用，返回临时 VTK 数据）
     * @param filePath STL文件路径
     * @return vtkPolyData，失败返回 nullptr
     * @note 推荐使用此方法，效率最高
     */
    vtkSmartPointer<vtkPolyData> loadSTLSyncPolyData(const QString& filePath);

    /**
     * @brief 同步加载STL文件（阻塞调用，旧接口）
     * @param filePath STL文件路径
     * @return STL数据
     * @note 此方法会将数据展开为三角形数组，效率较低
     */
    STLData loadSTLSync(const QString& filePath);

    /**
     * @brief 停止当前加载操作
     */
    void stopLoading();

    /**
     * @brief 是否正在加载
     */
    bool isLoading() const;

signals:
    /**
     * @brief 加载进度信号
     * @param progress 进度值 (0.0 - 1.0)
     */
    void progressChanged(double progress);

    /**
     * @brief 加载完成信号（旧接口）
     * @param stlData 加载的STL数据
     */
    void loadCompleted(const STLData& stlData);

    /**
     * @brief 加载错误信号
     * @param error 错误消息
     */
    void loadError(const QString& error);


private:
    class LoaderThread;
    std::unique_ptr<LoaderThread> m_thread;
    QString m_currentFile;
    std::atomic<bool> m_stopRequested{false};
    std::atomic<bool> m_isLoading{false};
    STLData m_lastLoadedData; // 保存最后加载的数据，避免跨线程传递

    /**
     * @brief 使用VTK加载STL文件的实际实现
     */
    vtkSmartPointer<vtkPolyData> loadSTLInternalPolyData(const QString& filePath);

    /**
     * @brief 使用VTK加载STL文件的实际实现（旧接口）
     */
    STLData loadSTLInternal(const QString& filePath);

};

// 注册类型到Qt元对象系统
Q_DECLARE_METATYPE(STLLoader::STLData)
