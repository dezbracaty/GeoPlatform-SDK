#pragma once

#include "MenuGroup.hpp"
#include "MenuItem.hpp"
#include "stdafx.h"
#include <QObject>
#include <QQmlEngine>
#include <QJsonObject>
#include <QJsonArray>
#include <qqml.h>
class MenuData : public QObject, public Singleton<MenuData>
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MenuData)
    QML_SINGLETON
    SINGLETON(MenuData)

    // 🆕 环境相关属性
    Q_PROPERTY(QString currentEnvironment READ currentEnvironment WRITE setCurrentEnvironment NOTIFY environmentChanged)
    Q_PROPERTY(QStringList availableEnvironments READ availableEnvironments NOTIFY availableEnvironmentsChanged)

private:
    explicit MenuData(QObject* parent = nullptr);
    TMenuItem* m_currentMenu;

    // 🔄 修改数据存储结构 - 两层映射：环境 -> 组名 -> MenuGroup
    QMap<QString, QMap<QString, TMenuGroup::SPtr>> m_environmentGroups;

    // 🆕 环境管理
    QString m_currentEnvironment;
    QString m_defaultEnvironment;
    QStringList m_availableEnvironments;

    // JSON 解析方法
    void loadFromJson(const QString& filePath);
    TMenuItem* parseMenuItem(const QJsonObject& json);
    TMenuGroup::SPtr parseMenuGroup(const QJsonObject& json);
    QString getConfigFilePath();

    // 🆕 解析环境配置
    // clearExisting: true = 清空现有配置后加载（默认），false = 覆盖同名配置
    void parseEnvironments(const QJsonObject& root, bool clearExisting = true);

public:
    ~MenuData();

    // default create function for QML_SINGLETON
    static MenuData* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine);
    void Init() {};

    // override virtual function
    Q_INVOKABLE bool onMenuActionTriggered(TMenuItem* item);

    // 🔄 修改 getGroup - 从当前环境获取
    Q_INVOKABLE const TMenuGroup* getGroup(const QString& groupName);

    // 🆕 添加带环境参数的版本
    Q_INVOKABLE const TMenuGroup* getGroup(const QString& groupName, const QString& environment);

    void addGroup(QString groupName, TMenuGroup::SPtr items);

    // 加载额外的菜单配置文件（支持应用层扩展）
    Q_INVOKABLE void loadMenusFromFile(const QString& filePath);

    // 🆕 环境管理接口
    QString currentEnvironment() const { return m_currentEnvironment; }
    void setCurrentEnvironment(const QString& env);
    QStringList availableEnvironments() const { return m_availableEnvironments; }
    QString defaultEnvironment() const { return m_defaultEnvironment; }

Q_SIGNALS:
    void menuActionDispatch(TMenuItem* item);
    void environmentChanged(const QString& newEnvironment);  // 🆕 环境切换信号
    void availableEnvironmentsChanged();  // 🆕 可用环境列表变化信号
};