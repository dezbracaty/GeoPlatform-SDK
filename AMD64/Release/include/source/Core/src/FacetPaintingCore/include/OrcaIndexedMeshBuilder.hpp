#pragma once

#include "OrcaIndexedMesh.hpp"
#include <QString>
#include <vector>

struct GeomTriangle;

namespace orca_compat {
struct stl_file;
struct indexed_triangle_set;
}

bool build_orca_indexed_mesh_for_manual_support(const std::vector<GeomTriangle>& triangles,
                                                OrcaIndexedMesh& outMesh,
                                                QString* errorMessage = nullptr);
