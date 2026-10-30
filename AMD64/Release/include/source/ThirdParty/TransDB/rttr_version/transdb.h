#pragma once
#include <spdlog/spdlog.h>

#include <string>
#include <string_view>
#include <any>
#include <cctype>
#include <iostream>
#include <memory>
#include <optional>
#include <unordered_map>
#include <vector>

// 包含事务管理器
#include "TransactionManager.hpp"
// 包含 Prop 类
#include "Prop.hpp"


// 事务系统便利宏定义
#define TRANS_FIELD(prop) backupProperty(#prop)

// 新增：不需要默认值的属性宏（使用 Prop）
// 使用 T{} 作为默认构造值，避免静态变量和复杂的初始化
#define FIELD_VALUE(ClassName, type, name)                                           \
public:                                                                              \
    static inline const trans::Prop& PROP_##name() {                                 \
        static const trans::Prop prop(typeid(ClassName), #name);                     \
        return prop;                                                                  \
    }                                                                                \
    type get##name() const {                                                         \
        return trans::TransDB::getProperty<type>(PROP_##name());                     \
    }                                                                                \
    void set##name(const type& value) {                                              \
        trans::TransDB::setProperty(PROP_##name(), value);                            \
        on##name##Changed(value);                                                    \
    }                                                                                \
    std::function<void(const type&)> on##name##Changed = [](const type&) {};

// 简化版本 - 不需要默认值
#define FIELD_VALUE_SIMPLE(ClassName, type, name)                                    \
public:                                                                              \
    static inline const trans::Prop& PROP_##name() {                                 \
        static const trans::Prop prop(typeid(ClassName), #name);                     \
        return prop;                                                                  \
    }                                                                                \
    type get##name() const {                                                         \
        return trans::TransDB::getProperty<type>(PROP_##name());                     \
    }                                                                                \
    void set##name(type value) {                                                     \
        trans::TransDB::setProperty(PROP_##name(), value);                            \
        on##name##Changed(value);                                                    \
    }                                                                                \
    std::function<void(type)> on##name##Changed = [](type) {};

// 瞬态属性：保留 TransDB 的统一存储与变化通知，但永远不写入 undo/redo。
// 适用于播放位置、视图过滤器等非文档状态。
#define TRANSIENT_FIELD_VALUE(ClassName, type, name)                                 \
public:                                                                              \
    static inline const trans::Prop& PROP_##name() {                                 \
        static const trans::Prop prop(typeid(ClassName), #name);                     \
        return prop;                                                                  \
    }                                                                                \
    type get##name() const {                                                         \
        return trans::TransDB::getProperty<type>(PROP_##name());                     \
    }                                                                                \
    void set##name(const type& value) {                                              \
        TransientUpdateGuard transientUpdateGuard;                                  \
        trans::TransDB::setProperty(PROP_##name(), value);                           \
        on##name##Changed(value);                                                    \
    }                                                                                \
    std::function<void(const type&)> on##name##Changed = [](const type&) {};

#define TRANSIENT_FIELD_VALUE_SIMPLE(ClassName, type, name)                          \
public:                                                                              \
    static inline const trans::Prop& PROP_##name() {                                 \
        static const trans::Prop prop(typeid(ClassName), #name);                     \
        return prop;                                                                  \
    }                                                                                \
    type get##name() const {                                                         \
        return trans::TransDB::getProperty<type>(PROP_##name());                     \
    }                                                                                \
    void set##name(type value) {                                                     \
        TransientUpdateGuard transientUpdateGuard;                                  \
        trans::TransDB::setProperty(PROP_##name(), value);                           \
        on##name##Changed(value);                                                    \
    }                                                                                \
    std::function<void(type)> on##name##Changed = [](type) {};

// 特定领域的宏已移至 ActorDBMacros.hpp
// TransDB 只保留通用的 FIELD_VALUE 宏



namespace trans {

    /**
     * @brief 事务数据库基类
     *
     * 提供事务支持的数据对象基类。
     * 使用模板化接口提供类型安全的属性访问。
     */
    class TransDB : public std::enable_shared_from_this<TransDB> {
    protected:
        // 构造函数改为 protected，防止直接构造
        TransDB();

    public:
        virtual ~TransDB();

        // 子类可重写此方法来处理事务记录

        // 虚函数版本 - 可被子类覆写以实现自定义逻辑（如嵌套属性）
    public:
        // Prop 参数版本的虚函数
        virtual std::any getPropertyImpl(const Prop& prop) const {
            auto it = m_properties.find(prop);
            if (it != m_properties.end()) {
                return it->second;
            }
            return std::any{};
        }

        virtual void setPropertyImpl(const Prop& prop, const std::any& value) {
            const Prop resolvedProp = resolvePropForWrite(prop);
            m_properties[resolvedProp] = value;
        }

    public:
        // 模板化的属性访问接口 - 类型安全，调用虚函数实现
        template <typename T>
        T getProperty(const Prop& prop) const {
            std::any value = getPropertyImpl(prop);
            if (value.has_value()) {
                try {
                    return std::any_cast<T>(value);
                } catch (const std::bad_any_cast&) {
                    SPDLOG_ERROR("TransDB: type mismatch for property '{}' (owner='{}', expected='{}', actual='{}')",
                                 prop.name(), prop.typeName(), typeid(T).name(), value.type().name());
                }
            }
            return T{};
        }

        template <typename T>
        bool setProperty(const Prop& prop, const T& value) {
            const Prop resolvedProp = resolvePropForWrite(prop);
            std::any oldValueAny = getPropertyImpl(resolvedProp);

            if (oldValueAny.has_value()) {
                try {
                    T oldValue = std::any_cast<T>(oldValueAny);
                    if (oldValue != value) {
                        if (TransactionManager::instance().isInTransaction()) {
                            TransactionManager::instance().recordPropertyChange(
                                shared_from_this(), resolvedProp, oldValueAny, std::any(value));
                        }

                        setPropertyImpl(resolvedProp, std::any(value));
                        return true;
                    }
                    return false;
                } catch (const std::bad_any_cast&) {
                    if (TransactionManager::instance().isInTransaction()) {
                        TransactionManager::instance().recordPropertyChange(
                            shared_from_this(), resolvedProp, oldValueAny, std::any(value));
                    }

                    setPropertyImpl(resolvedProp, std::any(value));
                    return true;
                }
            } else {
                if (TransactionManager::instance().isInTransaction()) {
                    TransactionManager::instance().recordPropertyChange(
                        shared_from_this(), resolvedProp, std::any{}, std::any(value));
                }

                setPropertyImpl(resolvedProp, std::any(value));
                return true;
            }
        }

        /**
         * @brief 动态类型属性写入（运行时 any）
         *
         * 用于不具备编译期模板类型信息的场景（例如 AI DB patch）。
         * 行为与 setProperty<T> 保持一致：在事务中记录 old/new，再调用 setPropertyImpl。
         */
        bool setPropertyAny(const Prop& prop, const std::any& value) {
            const Prop resolvedProp = resolvePropForWrite(prop);
            std::any oldValueAny = getPropertyImpl(resolvedProp);
            const bool hadOldValue = oldValueAny.has_value();

            bool changed = true;
            if (oldValueAny.has_value() && oldValueAny.type() == value.type()) {
                const std::type_info& type = value.type();
                try {
                    if (type == typeid(bool)) {
                        changed = std::any_cast<bool>(oldValueAny) != std::any_cast<bool>(value);
                    } else if (type == typeid(int)) {
                        changed = std::any_cast<int>(oldValueAny) != std::any_cast<int>(value);
                    } else if (type == typeid(unsigned int)) {
                        changed = std::any_cast<unsigned int>(oldValueAny) != std::any_cast<unsigned int>(value);
                    } else if (type == typeid(long)) {
                        changed = std::any_cast<long>(oldValueAny) != std::any_cast<long>(value);
                    } else if (type == typeid(unsigned long)) {
                        changed = std::any_cast<unsigned long>(oldValueAny) != std::any_cast<unsigned long>(value);
                    } else if (type == typeid(long long)) {
                        changed = std::any_cast<long long>(oldValueAny) != std::any_cast<long long>(value);
                    } else if (type == typeid(unsigned long long)) {
                        changed = std::any_cast<unsigned long long>(oldValueAny) !=
                                  std::any_cast<unsigned long long>(value);
                    } else if (type == typeid(float)) {
                        changed = std::any_cast<float>(oldValueAny) != std::any_cast<float>(value);
                    } else if (type == typeid(double)) {
                        changed = std::any_cast<double>(oldValueAny) != std::any_cast<double>(value);
                    } else if (type == typeid(std::string)) {
                        changed = std::any_cast<std::string>(oldValueAny) != std::any_cast<std::string>(value);
                    }
                } catch (const std::bad_any_cast&) {
                    std::cerr << "[WARNING] TransDB::setPropertyAny compare bad_any_cast, property='"
                              << resolvedProp.name() << "' type='" << type.name() << "'" << std::endl;
                    changed = true;
                }
            }

            if (!changed) {
                std::cerr << "[WARNING] TransDB::setPropertyAny skipped unchanged value, property='"
                          << resolvedProp.name() << "' type='" << value.type().name() << "'" << std::endl;
                return false;
            }

            if (TransactionManager::instance().isInTransaction()) {
                TransactionManager::instance().recordPropertyChange(
                    shared_from_this(), resolvedProp, oldValueAny, value);
            }

            setPropertyImpl(resolvedProp, value);
            const std::any verifyValue = getPropertyImpl(resolvedProp);
            if (!verifyValue.has_value()) {
                std::cerr << "[WARNING] TransDB::setPropertyAny verification failed (empty after set), property='"
                          << resolvedProp.name() << "'" << std::endl;
                return true;
            }

            if (verifyValue.type() != value.type()) {
                std::cerr << "[WARNING] TransDB::setPropertyAny verification type mismatch, property='"
                          << resolvedProp.name() << "' expected='" << value.type().name() << "' actual='"
                          << verifyValue.type().name() << "'" << std::endl;
                return true;
            }

            if (!hadOldValue) {
                std::cerr << "[WARNING] TransDB::setPropertyAny created new runtime field, property='"
                          << resolvedProp.name() << "' type='" << value.type().name() << "'" << std::endl;
            }
            return true;
        }

        // 检查属性是否存在
        bool hasProperty(const Prop& prop) const {
            return findExistingPropByName(prop.nameView()).has_value();
        }

        struct PropertyEntry {
            Prop prop;
            std::any value;
        };

        /**
         * @brief 导出内部属性字典快照（原始 FIELD 存储）
         */
        std::vector<PropertyEntry> propertyEntries() const {
            std::vector<PropertyEntry> entries;
            entries.reserve(m_properties.size());
            for (const auto& [prop, value] : m_properties) {
                entries.push_back(PropertyEntry{prop, value});
            }
            return entries;
        }

        // 获取所有属性名
        std::vector<std::string_view> getPropertyNames() const {
            std::vector<std::string_view> names;
            names.reserve(m_properties.size());
            for (const auto& [prop, _] : m_properties) {
                names.push_back(prop.nameView());
            }
            return names;
        }

        // 按属性名查找当前对象中已存在的 Prop key（精确匹配优先，随后大小写不敏感匹配）
        std::optional<Prop> findExistingPropByName(std::string_view propName) const {
            for (const auto& [prop, _] : m_properties) {
                if (prop.nameView() == propName) {
                    return prop;
                }
            }

            for (const auto& [prop, _] : m_properties) {
                if (equalsIgnoreCase(prop.nameView(), propName)) {
                    return prop;
                }
            }
            return std::nullopt;
        }

        // 动态写入时解析真实 key：优先覆写已有字段，找不到才创建新 key
        Prop resolvePropForWrite(std::string_view typeName, std::string_view propName) const {
            if (const auto existingProp = findExistingPropByName(propName)) {
                return *existingProp;
            }
            return Prop(typeName, propName);
        }

        Prop resolvePropForWrite(const Prop& prop) const {
            return resolvePropForWrite(prop.typeNameView(), prop.nameView());
        }

        // 按属性名查找值（忽略声明该属性的具体类型；大小写不敏感兜底）
        std::any getPropertyByName(std::string_view propName) const {
            if (const auto existingProp = findExistingPropByName(propName)) {
                auto it = m_properties.find(*existingProp);
                if (it != m_properties.end()) {
                    return it->second;
                }
            }

            return std::any{};
        }


    protected:
        // 二阶段初始化钩子（在 shared_ptr 创建后调用）
        virtual void onCreated() {
            // 子类可以在这里安全使用 shared_from_this()
            // 子类负责初始化自己的属性
        }

        // 注册属性（实例方法，用于运行时设置属性）
        template <typename T>
        void registerProperty(const Prop& prop, const T& defaultValue) {
            if (!findExistingPropByName(prop.nameView()).has_value()) {
                m_properties[prop] = defaultValue;
            }
        }

    public:
        // 统一的工厂方法
        template <typename T, typename... Args>
        static std::shared_ptr<T> create(Args&&... args) {
            static_assert(std::is_base_of<TransDB, T>::value,
                          "T must inherit from TransDB");

            // 先创建 shared_ptr，不调用 onCreated
            std::shared_ptr<T> obj(new T(std::forward<Args>(args)...));

            // 使用一个小技巧来确保 enable_shared_from_this 的 weak_ptr 已经初始化
            // 通过一个临时的 shared_ptr 赋值来触发初始化
            auto temp = obj;

            // 现在可以安全地调用 onCreated
            obj->onCreated();

            return obj;
        }

    private:
        friend std::vector<std::uint8_t> serializeState(const TransDB& db);
        friend void deserializeState(TransDB& db,
                                     const std::vector<std::uint8_t>& state);

        static bool equalsIgnoreCase(std::string_view lhs, std::string_view rhs) {
            if (lhs.size() != rhs.size()) {
                return false;
            }
            for (size_t i = 0; i < lhs.size(); ++i) {
                const auto lc = static_cast<char>(std::tolower(static_cast<unsigned char>(lhs[i])));
                const auto rc = static_cast<char>(std::tolower(static_cast<unsigned char>(rhs[i])));
                if (lc != rc) {
                    return false;
                }
            }
            return true;
        }

        // 属性存储
        mutable std::unordered_map<Prop, std::any, PropHash> m_properties;
    };

} // namespace trans
