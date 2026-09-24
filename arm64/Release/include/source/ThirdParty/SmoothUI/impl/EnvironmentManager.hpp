#pragma once

#include <QString>
#include <functional>

class EnvironmentManager {
public:
    static EnvironmentManager* instance();

    /**
     * @brief 切换到指定环境
     * @param environment 目标环境名称 (normal, slicing, editing, support, preview)
     * @return 切换是否成功
     */
    bool switchTo(const QString& environment);

    /**
     * @brief 设置环境切换验证回调
     * @param callback 验证函数，返回 true 表示允许切换，false 表示拒绝切换
     */
    void setValidationCallback(std::function<bool(const QString&)> callback);

    /**
     * @brief 设置环境切换前的回调
     * @param callback 回调函数，参数为 (fromEnv, toEnv)
     */
    void setBeforeSwitchCallback(std::function<void(const QString&, const QString&)> callback);

    /**
     * @brief 设置环境切换后的回调
     * @param callback 回调函数，参数为新环境名称
     */
    void setAfterSwitchCallback(std::function<void(const QString&)> callback);

private:
    EnvironmentManager() = default;
    ~EnvironmentManager() = default;

    // 禁止拷贝和赋值
    EnvironmentManager(const EnvironmentManager&) = delete;
    EnvironmentManager& operator=(const EnvironmentManager&) = delete;

    std::function<bool(const QString&)> m_validationCallback;
    std::function<void(const QString&, const QString&)> m_beforeSwitchCallback;
    std::function<void(const QString&)> m_afterSwitchCallback;
};
