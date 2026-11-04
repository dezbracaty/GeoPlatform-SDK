#pragma once

#include "FilamentRenderTypes.hpp"

#include <cstdint>

namespace filament {
class Engine;
class Material;
class MaterialInstance;
class Texture;
}

namespace GPlatform::Rendering {

class FilamentMaterialLibrary final {
public:
    enum class ProgramKind : std::uint8_t {
        StandardPbr,
        StandardUnlit,
        Refraction,
        TransparentOverlay,
        TexturedPbr,
        TexturedUnlit
    };

    struct Binding {
        filament::MaterialInstance* instance{nullptr};
        filament::Texture* texture{nullptr};
        ProgramKind kind{ProgramKind::StandardPbr};
    };

    explicit FilamentMaterialLibrary(filament::Engine& engine);
    ~FilamentMaterialLibrary();

    FilamentMaterialLibrary(const FilamentMaterialLibrary&) = delete;
    FilamentMaterialLibrary& operator=(const FilamentMaterialLibrary&) = delete;

    bool initialize();
    bool createBinding(
        const FilamentMaterialDescriptor& descriptor,
        Binding& result);
    bool updateBinding(
        Binding& binding,
        const FilamentMaterialDescriptor& descriptor);
    void destroyBinding(Binding& binding) noexcept;
    void shutdown() noexcept;

    static ProgramKind programKind(
        const FilamentMaterialDescriptor& descriptor) noexcept;

private:
    filament::Texture* createTexture(const std::string& path);
    static void apply(
        filament::MaterialInstance& instance,
        const FilamentMaterialDescriptor& descriptor,
        filament::Texture* texture);
    filament::Material* program(ProgramKind kind) const noexcept;

    filament::Engine& m_engine;
    filament::Material* m_standardPbr{nullptr};
    filament::Material* m_standardUnlit{nullptr};
    filament::Material* m_refraction{nullptr};
    filament::Material* m_transparentOverlay{nullptr};
    filament::Material* m_texturedPbr{nullptr};
    filament::Material* m_texturedUnlit{nullptr};
};

} // namespace GPlatform::Rendering
