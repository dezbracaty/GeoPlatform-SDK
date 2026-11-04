#pragma once

#include "FilamentRenderTypes.hpp"

#include <ActorDB.hpp>

#include <vector>

namespace GPlatform::Rendering {

FilamentMaterialDescriptor filamentMaterialDescriptor(
    const MaterialDB& material,
    float actorOpacity,
    const Vector3& authoredColor);

FilamentMaterialDescriptor filamentMaterialDescriptor(
    const ActorDB& actor,
    const Vector3& authoredColor);

std::vector<FilamentMaterialDescriptor> filamentMaterialDescriptors(
    const ActorDB& actor,
    const FilamentGeometry& geometry);

} // namespace GPlatform::Rendering
