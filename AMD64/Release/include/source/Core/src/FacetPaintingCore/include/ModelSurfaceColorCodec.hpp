#pragma once

#include "ManualSupportOrcaScaffold.hpp"
#include <string>
#include <vector>

struct GeomTriangle;

namespace ModelSurfaceColorCodec {

inline constexpr unsigned int DataVersion = 2u;

bool encode(const ManualSupportOrcaScaffold::TriangleSplittingData& state,
            std::string* blob);
bool decode(const std::string& blob,
            ManualSupportOrcaScaffold::TriangleSplittingData* state);
std::string topologyFingerprint(const std::vector<GeomTriangle>& triangles);

} // namespace ModelSurfaceColorCodec
