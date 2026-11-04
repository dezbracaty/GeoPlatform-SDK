#pragma once

#include "IFilamentDBSync.hpp"

#include <RendererInstanceContext.hpp>

#include <functional>
#include <memory>
#include <unordered_map>
#include <vector>

class AutoRegisterDB;

namespace GPlatform::Rendering {

class FilamentSceneAdapter;

class FilamentDBSyncFactory final {
public:
    using Creator = std::function<std::unique_ptr<IFilamentDBSync>(
        DBInstanceID,
        FilamentSceneAdapter&)>;
    using InstancePredicate = std::function<bool(
        const RendererInstanceContext&,
        const std::shared_ptr<const AutoRegisterDB>&)>;

    struct Registration {
        Creator creator;
        RendererRoleMask rendererRoles{0};
        InstancePredicate instancePredicate;
    };

    FilamentDBSyncFactory() = default;
    static FilamentDBSyncFactory& instance();
    using EnvironmentSynchronizer = std::function<void(FilamentSceneAdapter&)>;
    void setEnvironmentSynchronizer(EnvironmentSynchronizer synchronizer);
    void synchronizeEnvironment(FilamentSceneAdapter& adapter) const;

    bool registerDBSync(
        TypeID type,
        Creator creator,
        RendererRoleMask rendererRoles,
        InstancePredicate instancePredicate = {});
    std::unique_ptr<IFilamentDBSync> createDBSync(
        DBInstanceID id,
        TypeID type,
        const RendererInstanceContext& rendererContext,
        const std::shared_ptr<const AutoRegisterDB>& db,
        FilamentSceneAdapter& adapter) const;
    std::vector<TypeID> registeredTypes(RendererRole role) const;
    bool supports(TypeID type, RendererRole role) const;

private:
    const Registration* find(TypeID type) const;

    std::unordered_map<std::uint32_t, Registration> m_registrations;
    EnvironmentSynchronizer m_environmentSynchronizer;
};

} // namespace GPlatform::Rendering
