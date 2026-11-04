#pragma once

#include <BaseID.hpp>
#include <RendererInstanceContext.hpp>

#include <QSize>

#include <cstdint>
#include <functional>
#include <memory>
#include <unordered_map>

class IDocumentReadView;

namespace filament {
class Camera;
class Engine;
class Scene;
}

namespace GPlatform::Rendering {

class FilamentMaterialLibrary;
class FilamentEnvironmentController;

class FilamentSceneAdapter final {
public:
    struct PickIdentity {
        DBInstanceID objectId{};
        DBInstanceID partId{};

        bool operator==(const PickIdentity&) const = default;
    };

    struct PickIdentitySnapshot {
        std::uint64_t sceneGeneration{0};
        std::unordered_map<std::uint32_t, PickIdentity> identities;
    };

    FilamentSceneAdapter(
        filament::Engine& engine,
        filament::Scene& scene,
        filament::Camera& camera,
        RendererInstanceContext rendererContext,
        std::shared_ptr<IDocumentReadView> document,
        std::function<void()> requestFrame);
    ~FilamentSceneAdapter();

    FilamentSceneAdapter(const FilamentSceneAdapter&) = delete;
    FilamentSceneAdapter& operator=(const FilamentSceneAdapter&) = delete;

    void synchronize(const QSize& viewportSize);

    filament::Engine& engine() const noexcept;
    filament::Scene& scene() const noexcept;
    filament::Camera& camera() const noexcept;
    FilamentMaterialLibrary& materialLibrary() const noexcept;
    FilamentEnvironmentController& environmentController() const noexcept;
    const RendererInstanceContext& rendererContext() const noexcept;
    const std::shared_ptr<IDocumentReadView>& document() const noexcept;
    void requestFrame() const;

    void bindPickIdentity(
        std::uint32_t entityId, DBInstanceID objectId,
        DBInstanceID partId = DBInstanceID{});
    void unbindPickIdentity(std::uint32_t entityId);
    void markPickGeometryChanged();
    std::shared_ptr<const PickIdentitySnapshot> pickIdentitySnapshot() const;
    std::uint64_t sceneGeneration() const noexcept;

private:
    struct Impl;
    std::unique_ptr<Impl> m_impl;
};

} // namespace GPlatform::Rendering
