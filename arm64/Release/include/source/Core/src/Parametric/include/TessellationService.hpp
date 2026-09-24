#pragma once

#include "ParametricModelTypes.hpp"

namespace GPlatform::Parametric {

class TessellationService {
public:
    TessellationOutput tessellate(const FeatureBuildOutput& buildOutput) const;

private:
    QString computeMeshHash(const std::vector<GeomTriangle>& triangles) const;
};

} // namespace GPlatform::Parametric
