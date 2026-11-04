#pragma once

#include <Geometry.hpp>

#include <string>
#include <optional>
#include <unordered_set>

namespace filament {
class Engine;
class IndirectLight;
class Scene;
class Skybox;
class Texture;
}

namespace GPlatform::Rendering {

struct FilamentEnvironmentSettings {
    bool backgroundVisible{true};
    bool imageBasedLighting{true};
    float lightingIntensity{30000.0f};
    std::string lightingPath;
    std::string backgroundPath;
    Vector3 fallbackColor{0.035f, 0.045f, 0.060f};
};

class FilamentEnvironmentController final {
public:
    FilamentEnvironmentController(
        filament::Engine& engine,
        filament::Scene& scene);
    ~FilamentEnvironmentController();

    FilamentEnvironmentController(const FilamentEnvironmentController&) = delete;
    FilamentEnvironmentController& operator=(const FilamentEnvironmentController&) = delete;

    static FilamentEnvironmentSettings defaultSettings();
    void apply(const FilamentEnvironmentSettings& settings);
    void applyDefault();
    void shutdown() noexcept;

private:
    filament::Engine& m_engine;
    filament::Scene& m_scene;
    filament::Texture* m_iblTexture{nullptr};
    filament::Texture* m_skyboxTexture{nullptr};
    filament::IndirectLight* m_indirectLight{nullptr};
    filament::Skybox* m_skybox{nullptr};
    std::string m_appliedLightingPath;
    std::unordered_set<std::string> m_failedLightingPaths;
    std::optional<FilamentEnvironmentSettings> m_appliedBackground;
    std::unordered_set<std::string> m_failedBackgroundPaths;
};

} // namespace GPlatform::Rendering
