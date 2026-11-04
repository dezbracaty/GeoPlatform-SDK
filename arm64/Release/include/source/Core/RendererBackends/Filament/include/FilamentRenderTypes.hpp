#pragma once

#include <Geometry.hpp>

#include <math/quat.h>
#include <math/vec2.h>
#include <math/vec3.h>

#include <cstdint>
#include <string>
#include <vector>

namespace GPlatform::Rendering {

enum class FilamentPrimitiveTopology : std::uint8_t {
    Triangles,
    Lines,
    Points
};

struct FilamentVertex {
    filament::math::float3 position;
    filament::math::quatf tangentFrame;
    filament::math::float2 uv{0.0f, 0.0f};
};

struct FilamentPrimitive {
    std::uint32_t label{0};
    std::uint32_t indexOffset{0};
    std::uint32_t indexCount{0};
    Vector3 authoredColor;
    FilamentPrimitiveTopology topology{FilamentPrimitiveTopology::Triangles};
};

struct FilamentGeometry {
    bool valid{false};
    std::string error;
    std::vector<FilamentVertex> vertices;
    std::vector<std::uint32_t> indices;
    std::vector<FilamentPrimitive> primitives;
};

struct FilamentMaterialDescriptor {
    Vector3 baseColor;
    float roughness{1.0f};
    float metallic{0.0f};
    float clearCoat{0.0f};
    float clearCoatRoughness{0.0f};
    float anisotropy{0.0f};
    bool unlit{false};
    bool refractive{false};
    bool transparentOverlay{false};
    std::string texturePath;
    float alpha{1.0f};
    Vector3 absorptionColor{1.0f, 1.0f, 1.0f};
    float absorptionDistance{1.0f};
    float thickness{0.0f};
    float indexOfRefraction{1.5f};
    float transmission{0.0f};
    float dispersion{0.0f};
};

} // namespace GPlatform::Rendering
