#pragma once

#include "FilamentMaterialLibrary.hpp"
#include "FilamentRenderTypes.hpp"

#include <Transform.hpp>

#include <utils/Entity.h>

#include <cstdint>
#include <string>
#include <vector>

namespace filament {
class Engine;
class IndexBuffer;
class Scene;
class VertexBuffer;
}

namespace GPlatform::Rendering {

class FilamentRenderableResource final {
public:
    FilamentRenderableResource(
        filament::Engine& engine,
        filament::Scene& scene,
        FilamentMaterialLibrary& materials);
    ~FilamentRenderableResource();

    FilamentRenderableResource(const FilamentRenderableResource&) = delete;
    FilamentRenderableResource& operator=(const FilamentRenderableResource&) = delete;

    bool rebuild(
        FilamentGeometry geometry,
        const std::vector<FilamentMaterialDescriptor>& materials,
        const Transform::Matrix4& transform);
    bool updateTransform(const Transform::Matrix4& transform);
    bool updateMaterials(
        const std::vector<FilamentMaterialDescriptor>& materials);
    bool setVisible(bool visible);
    bool reset() noexcept;

    bool valid() const noexcept;
    std::uint32_t entityId() const noexcept;
    const std::vector<std::uint32_t>& materialLabels() const noexcept;

private:
    filament::Engine& m_engine;
    filament::Scene& m_scene;
    FilamentMaterialLibrary& m_materialLibrary;
    utils::Entity m_entity;
    bool m_visible{false};
    filament::VertexBuffer* m_vertices{nullptr};
    filament::IndexBuffer* m_indices{nullptr};
    std::vector<FilamentMaterialLibrary::Binding> m_materials;
    std::vector<std::uint32_t> m_materialLabels;
    std::vector<std::string> m_texturePaths;
};

} // namespace GPlatform::Rendering
