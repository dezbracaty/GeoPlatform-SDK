#pragma once

#include "IDBSync.hpp"
#include <memory>
#include <unordered_map>
#include <functional>
#include <vector>
#include "Foundation/Log.h"
#include "RendererInstanceContext.hpp"
#include "VtkBackendRegistration.hpp"
#include <TransDBTypes.hpp>

class AutoRegisterDB;

// =============================================================================
// Hash specialization for trans::TypeID to support std::unordered_map
// =============================================================================
namespace std {
    template<>
    struct hash<trans::TypeID> {
        std::size_t operator()(const trans::TypeID& typeId) const noexcept {
            return std::hash<uint32_t>()(typeId.getValue());
        }
    };
}

/**
 * @brief VTK 后端私有的 DBSync 工厂
 * 
 * 支持动态注册的工厂模式：
 * - ActorDB派生类 → ActorDBSync派生类
 * - WidgetDB派生类 → WidgetDBSync派生类
 * - CameraDB → CameraDBSync
 * 
 * DBSync registrations are executed by the VTK backend module entry.
 * 支持的DB类型：
 * - Concrete types are registered by AppRendering
 * - ModelOrientationWidgetDB, CameraDB
 */
class VtkDBSyncFactory {
public:
    using DBSyncCreator = std::function<std::shared_ptr<IDBSync>()>;
    using InstancePredicate = std::function<bool(
        const GPlatform::Rendering::RendererInstanceContext&,
        const std::shared_ptr<const AutoRegisterDB>&)>;

    struct DBSyncRegistration {
        DBSyncCreator creator;
        GPlatform::Rendering::RendererRoleMask rendererRoles{
            GPlatform::Rendering::RendererRoleSets::Compatibility};
        InstancePredicate instancePredicate;
    };
    
    static VtkDBSyncFactory& getInstance();
    
    /**
     * @brief 注册DBSync创建器（动态注册）
     * @param typeId DB类型ID
     * @param creator DBSync创建函数
     * @return 注册成功返回 true；重复 TypeID 返回 false，原注册保持不变
     */
    bool registerDBSync(
        trans::TypeID typeId,
        DBSyncCreator creator,
        GPlatform::Rendering::RendererRoleMask rendererRoles,
        InstancePredicate instancePredicate = {});
    
    /**
     * @brief 创建DBSync对象
     * @param dbType 数据库对象的类型ID
     * @return 对应的DBSync智能指针，如果不支持则返回nullptr
     */
    std::shared_ptr<IDBSync> createDBSync(
        trans::TypeID dbType,
        GPlatform::Rendering::RendererRole rendererRole,
        const std::shared_ptr<const AutoRegisterDB>& dbInstance) const;
    
    /**
     * @brief 获取所有已注册的DB类型
     * @return 支持的DB类型列表
     */
    std::vector<trans::TypeID> getRegisteredTypes(
        GPlatform::Rendering::RendererRole rendererRole) const;
    
    /**
     * @brief 检查是否有注册的DBSync
     * @param typeId DB类型ID
     * @return 是否已注册
     */
    bool hasDBSync(
        trans::TypeID typeId,
        GPlatform::Rendering::RendererRole rendererRole) const;

    bool acceptsDBInstance(
        trans::TypeID typeId,
        const GPlatform::Rendering::RendererInstanceContext& rendererContext,
        const std::shared_ptr<const AutoRegisterDB>& dbInstance) const;
    
private:
    VtkDBSyncFactory() = default;
    ~VtkDBSyncFactory() = default;
    VtkDBSyncFactory(const VtkDBSyncFactory&) = delete;
    VtkDBSyncFactory& operator=(const VtkDBSyncFactory&) = delete;

    const DBSyncRegistration* findRegistration(trans::TypeID typeId) const;
    
    std::unordered_map<trans::TypeID, DBSyncRegistration> m_registrations;
};

#define REGISTER_VTK_DBSYNC(TypeIdValue, SyncClass, RendererRoles)                       \
    void register##SyncClass() {                                                         \
        auto& factory = VtkDBSyncFactory::getInstance();                                 \
        factory.registerDBSync(                                                          \
            trans::TypeID(static_cast<uint32_t>(TypeIdValue)),                           \
            [] { return std::make_shared<SyncClass>(); },                               \
            RendererRoles);                                                              \
    }                                                                                    \
    REGISTER_VTK_BACKEND_ENTRY(register##SyncClass())

#define REGISTER_VTK_DBSYNC_FILTERED(TypeIdValue, SyncClass, RendererRoles, Predicate)     \
    void register##SyncClass() {                                                           \
        auto& factory = VtkDBSyncFactory::getInstance();                                   \
        factory.registerDBSync(                                                            \
            trans::TypeID(static_cast<uint32_t>(TypeIdValue)),                             \
            [] { return std::make_shared<SyncClass>(); },                                 \
            RendererRoles,                                                                 \
            Predicate);                                                                    \
    }                                                                                      \
    REGISTER_VTK_BACKEND_ENTRY(register##SyncClass())
