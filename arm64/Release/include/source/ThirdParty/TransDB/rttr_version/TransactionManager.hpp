#pragma once

#include <memory>
#include <vector>
#include <deque>
#include <mutex>
#include <any>
#include <string>
#include <functional>
#include <variant>
#include <chrono>
#include <unordered_map>
#include "TransDBTypes.hpp"
#include "Prop.hpp"

// Forward declarations
namespace trans {
    class TransDB;
}

/**
 * @brief 新的事务管理器 - 支持对象生命周期管理
 *
 * 核心设计理念：
 * 1. 事务由用户主动开启，不在事务中的操作不被记录
 * 2. 基于数据的撤销/重做，不使用函数指针
 * 3. 支持批量属性变化的原子回滚
 * 4. 支持对象创建和删除的撤销/重做
 */
class TransactionManager {
public:
    using ListenerID = size_t;
    using TransactionMetadata = std::unordered_map<std::string, std::string>;

    /**
     * @brief 变化类型
     */
    enum class ChangeType {
        PROPERTY_CHANGE, // 属性变化
        OBJECT_CREATED,  // 对象创建
        OBJECT_DELETED   // 对象删除
    };

    /**
     * @brief 属性变化记录
     */
    struct PropertyChange {
        std::weak_ptr<trans::TransDB> object; // 对象的弱引用
        std::string typeName;                 // 类型名（用于创建 Prop）
        std::string propertyName;             // 属性名（用于创建 Prop）
        std::any oldValue;                    // 旧值
        std::any newValue;                    // 新值
    };

    /**
     * @brief 对象生命周期变化记录
     */
    struct ObjectLifecycleChange {
        std::shared_ptr<trans::TransDB> object; // 对象的强引用（保持存活）
        trans::DBInstanceID instanceId;         // 对象ID
        trans::TypeID dbType;                   // 对象类型
        bool created = false;                   // true=创建对象, false=删除对象
    };

    /**
     * @brief ownership 边变化记录
     */
    struct OwnershipChange {
        trans::DBInstanceID parentId;
        trans::DBInstanceID childId;
        std::string relationName;
        bool attached = false; // true=attach, false=detach
    };

    /**
     * @brief dependency relation 边变化记录
     */
    struct DependencyRelationChange {
        trans::DBInstanceID sourceId;
        trans::DBInstanceID targetId;
        std::string relationName;
        bool attached = false; // true=attach, false=detach
    };

    /**
     * @brief 统一的变化记录（使用 std::variant）
     */
    using Change = std::variant<PropertyChange, ObjectLifecycleChange, OwnershipChange, DependencyRelationChange>;

    /**
     * @brief 事务记录
     */
    struct Transaction {
        uint64_t id = 0;                             // 事务ID（单调递增）
        std::string description;                    // 事务描述
        ChangeType type;                            // 主要变化类型
        std::vector<Change> changes;                // 所有变化列表
        std::chrono::steady_clock::time_point time; // 事务时间
        TransactionMetadata metadata;               // 调用来源上下文标签
    };

    struct TransactionSummary {
        uint64_t id = 0;
        std::string description;
        ChangeType type = ChangeType::PROPERTY_CHANGE;
        size_t changeCount = 0;
        TransactionMetadata metadata;
    };

    /**
     * @brief 获取单例实例
     */
    static TransactionManager& instance();

    // 禁止拷贝和赋值
    TransactionManager(const TransactionManager&) = delete;
    TransactionManager& operator=(const TransactionManager&) = delete;

    /**
     * @brief 开始新事务
     * @param description 事务描述
     */
    void beginTransaction(const std::string& description = "");

    /**
     * @brief 提交当前事务
     * 将当前事务添加到撤销栈，清空重做栈
     */
    void commitTransaction();

    /**
     * @brief 回滚当前事务
     * 恢复当前事务中的所有属性变化
     */
    void rollbackTransaction();

    /**
     * @brief 检查是否在事务中
     * @return true 如果当前有活跃事务
     */
    bool isInTransaction() const;

    /**
     * @brief 检查当前是否处于派生更新上下文
     *
     * 派生更新可以修改 DB 并发出通知，但不会写入 undo/redo 历史。
     */
    bool isRecordingSuppressed() const;

    /**
     * @brief 记录属性变化
     * @param object 对象指针
     * @param prop 属性标识符
     * @param oldValue 旧值
     * @param newValue 新值
     */
    void recordPropertyChange(
        std::shared_ptr<trans::TransDB> object,
        const trans::Prop& prop,
        const std::any& oldValue,
        const std::any& newValue);

    /**
     * @brief 记录对象创建
     * @param object 对象指针
     * @param id 对象ID
     * @param type 对象类型
     */
    void recordObjectCreation(
        std::shared_ptr<trans::TransDB> object,
        const trans::DBInstanceID& id,
        trans::TypeID type);

    /**
     * @brief 记录对象删除
     * @param object 对象指针
     * @param id 对象ID
     * @param type 对象类型
     */
    void recordObjectDeletion(
        std::shared_ptr<trans::TransDB> object,
        const trans::DBInstanceID& id,
        trans::TypeID type);

    /**
     * @brief 记录 ownership 关系变化
     */
    void recordOwnershipChange(
        const trans::DBInstanceID& parentId,
        const trans::DBInstanceID& childId,
        const std::string& relationName,
        bool attached);

    /**
     * @brief 记录 dependency relation 关系变化
     */
    void recordDependencyRelationChange(
        const trans::DBInstanceID& sourceId,
        const trans::DBInstanceID& targetId,
        const std::string& relationName,
        bool attached);

    /**
     * @brief 设置对象生命周期回调
     * @param callback 回调函数 (id, type, isCreate, object)
     * 对象指针在redo时包含原始对象，可以直接重用
     */
    using ObjectLifecycleCallback = std::function<void(
        const trans::DBInstanceID&,     // 对象ID
        trans::TypeID,                  // 对象类型
        bool,                           // true=创建, false=删除
        std::shared_ptr<trans::TransDB> // 对象指针（redo时使用原对象）
        )>;
    void setObjectLifecycleCallback(ObjectLifecycleCallback callback);

    using OwnershipReplayHandler = std::function<void(
        const trans::DBInstanceID&, // parent
        const trans::DBInstanceID&, // child
        const std::string&,         // relation
        bool                        // true=attach, false=detach
        )>;
    void setOwnershipReplayHandler(OwnershipReplayHandler handler);

    using DependencyRelationReplayHandler = std::function<void(
        const trans::DBInstanceID&, // source
        const trans::DBInstanceID&, // target
        const std::string&,         // relation
        bool                        // true=attach, false=detach
        )>;
    void setDependencyRelationReplayHandler(DependencyRelationReplayHandler handler);

    // 事务上下文标签（用于将 source/turnId/traceId/actionCode 写入后续提交事务）
    void setCurrentContextMetadata(const TransactionMetadata& metadata);
    TransactionMetadata currentContextMetadata() const;

    /**
     * @brief 注册事务开始监听器
     * @return 监听器ID，可用于后续注销
     */
    ListenerID addTransactionBegunListener(std::function<void(const std::string&)> listener);

    /**
     * @brief 注册事务提交监听器
     * @return 监听器ID，可用于后续注销
     */
    ListenerID addTransactionCommittedListener(std::function<void(const Transaction&)> listener);

    /**
     * @brief 注册撤销栈变化监听器
     * @return 监听器ID，可用于后续注销
     */
    ListenerID addUndoStackChangedListener(std::function<void()> listener);

    /**
     * @brief 注册重做栈变化监听器
     * @return 监听器ID，可用于后续注销
     */
    ListenerID addRedoStackChangedListener(std::function<void()> listener);

    /**
     * @brief 注销事务开始监听器
     */
    void removeTransactionBegunListener(ListenerID id);

    /**
     * @brief 注销事务提交监听器
     */
    void removeTransactionCommittedListener(ListenerID id);

    /**
     * @brief 注销撤销栈变化监听器
     */
    void removeUndoStackChangedListener(ListenerID id);

    /**
     * @brief 注销重做栈变化监听器
     */
    void removeRedoStackChangedListener(ListenerID id);

    /**
     * @brief 执行撤销
     * @return true 如果撤销成功
     */
    bool undo();

    /**
     * @brief 执行重做
     * @return true 如果重做成功
     */
    bool redo();

    /**
     * @brief 检查是否可以撤销
     */
    bool canUndo() const;

    /**
     * @brief 检查是否可以重做
     */
    bool canRedo() const;

    /**
     * @brief 清空所有事务记录
     */
    void clear();

    /**
     * @brief 获取撤销栈大小
     */
    size_t getUndoStackSize() const;

    /**
     * @brief 获取重做栈大小
     */
    size_t getRedoStackSize() const;

    /**
     * @brief 设置最大撤销栈大小
     * @param maxSize 最大大小（0表示无限制）
     */
    void setMaxUndoStackSize(size_t maxSize);

    /**
     * @brief 获取下一个撤销操作的描述
     */
    std::string getNextUndoDescription() const;

    /**
     * @brief 获取下一个重做操作的描述
     */
    std::string getNextRedoDescription() const;

    // 获取撤销栈顶部摘要（offsetFromTop=0 表示当前栈顶）
    TransactionSummary getUndoTransactionSummary(size_t offsetFromTop = 0) const;

    // 获取撤销栈顶部 count 个摘要（返回顺序：栈顶 -> 栈底方向）
    std::vector<TransactionSummary> getUndoTransactionSummaries(size_t count) const;

    // 回调函数
    std::function<void(const std::string&)> onTransactionBegun;
    std::function<void(const Transaction&)> onTransactionCommitted;
    std::function<void()> onUndoStackChanged;
    std::function<void()> onRedoStackChanged;

private:
    /**
     * @brief 私有构造函数（单例）
     */
    TransactionManager();
    ~TransactionManager();

    /**
     * @brief 应用属性变化
     * @param change 属性变化记录
     * @param useOldValue true使用旧值，false使用新值
     */
    void applyPropertyChange(const PropertyChange& change, bool useOldValue);

    /**
     * @brief 应用对象生命周期变化
     * @param change 生命周期变化记录
     * @param isUndo 是否是撤销操作
     */
    void applyObjectLifecycleChange(const ObjectLifecycleChange& change, bool isUndo);

    /**
     * @brief 应用 ownership 边变化
     */
    void applyOwnershipChange(const OwnershipChange& change, bool isUndo);

    /**
     * @brief 应用 dependency relation 边变化
     */
    void applyDependencyRelationChange(const DependencyRelationChange& change, bool isUndo);

    /**
     * @brief 应用变化
     * @param change 变化记录
     * @param isUndo 是否是撤销操作
     */
    void applyChange(const Change& change, bool isUndo);

    /**
     * @brief 限制撤销栈大小
     */
    void limitUndoStackSize();

    // 事件通知辅助函数（兼容旧回调字段 + 新监听器机制）
    void notifyTransactionBegun(const std::string& description);
    void notifyTransactionCommitted(const Transaction& transaction);
    void notifyUndoStackChanged();
    void notifyRedoStackChanged();

private:
    mutable std::recursive_mutex m_mutex;              // 递归互斥锁
    std::unique_ptr<Transaction> m_currentTransaction; // 当前活跃事务
    std::deque<Transaction> m_undoStack;               // 撤销栈
    std::deque<Transaction> m_redoStack;               // 重做栈
    size_t m_maxUndoStackSize;                         // 最大撤销栈大小
    ObjectLifecycleCallback m_objectLifecycleCallback; // 对象生命周期回调
    OwnershipReplayHandler m_ownershipReplayHandler; // undo/redo 回放 ownership 边变化
    DependencyRelationReplayHandler m_dependencyRelationReplayHandler; // undo/redo 回放 dependency relation 边变化
    TransactionMetadata m_currentContextMetadata;      // 当前调用上下文标签
    uint64_t m_nextTransactionId{1};                   // 单调递增事务ID

    // 多监听器事件系统
    ListenerID m_nextListenerId{1};
    std::unordered_map<ListenerID, std::function<void(const std::string&)>> m_transactionBegunListeners;
    std::unordered_map<ListenerID, std::function<void(const Transaction&)>> m_transactionCommittedListeners;
    std::unordered_map<ListenerID, std::function<void()>> m_undoStackChangedListeners;
    std::unordered_map<ListenerID, std::function<void()>> m_redoStackChangedListeners;
};

/**
 * @brief 派生更新守卫
 *
 * 用于 relation/rule/级联同步。守卫范围内的 DB 修改仍会通知系统，
 * 但不会记录到 undo/redo 事务历史。
 */
class DerivedUpdateGuard {
public:
    DerivedUpdateGuard() {
        ++depth();
    }

    ~DerivedUpdateGuard() {
        auto& currentDepth = depth();
        if (currentDepth > 0) {
            --currentDepth;
        }
    }

    DerivedUpdateGuard(const DerivedUpdateGuard&) = delete;
    DerivedUpdateGuard& operator=(const DerivedUpdateGuard&) = delete;

    static bool isActive() {
        return depth() > 0;
    }

private:
    static size_t& depth() {
        thread_local size_t value = 0;
        return value;
    }
};

/**
 * @brief 瞬态状态更新守卫
 *
 * 用于播放位置、视图过滤器等不属于文档编辑历史的状态。守卫范围内的
 * DB 修改仍然会发送正常的属性变化通知，但不会写入 undo/redo 历史。
 *
 * 它与 DerivedUpdateGuard 共用同一套事务记录抑制机制，但提供明确的
 * 领域语义，避免把用户界面状态伪装成 relation/rule 派生更新。
 */
class TransientUpdateGuard {
public:
    TransientUpdateGuard() = default;
    ~TransientUpdateGuard() = default;

    TransientUpdateGuard(const TransientUpdateGuard&) = delete;
    TransientUpdateGuard& operator=(const TransientUpdateGuard&) = delete;

private:
    DerivedUpdateGuard m_recordingSuppression;
};

/**
 * @brief 事务守卫（RAII）
 * 自动管理事务的开始和提交/回滚
 */
class TransactionGuard {
public:
    /**
     * @brief 构造函数，自动开始事务
     * @param description 事务描述
     */
    explicit TransactionGuard(const std::string& description = "");

    /**
     * @brief 析构函数，自动提交事务（如果未手动提交或回滚）
     */
    ~TransactionGuard();

    /**
     * @brief 手动提交事务
     */
    void commit();

    /**
     * @brief 手动回滚事务
     */
    void rollback();

private:
    bool m_committed;  // 是否已提交
    bool m_rolledBack; // 是否已回滚
};
