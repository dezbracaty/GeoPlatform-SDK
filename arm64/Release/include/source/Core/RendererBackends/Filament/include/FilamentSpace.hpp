#pragma once

#include <Geometry.hpp>
#include <Transform.hpp>

#include <math/mat4.h>
#include <math/quat.h>
#include <math/vec3.h>

namespace GPlatform::Rendering {

filament::math::float3 toFilamentSpace(const Vector3& value);
filament::math::quatf toFilamentTangentFrame(const Vector3& sourceNormal);
filament::math::mat4f toFilamentTransform(
    const Transform::Matrix4& matrix);

} // namespace GPlatform::Rendering
