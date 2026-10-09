#pragma once

#include <QVector3D>
#include <array>
#include <vector>

struct OrcaIndexedMesh {
    std::vector<QVector3D> vertices;
    std::vector<std::array<int, 3>> triangles;
    std::vector<std::array<int, 3>> neighbors;
    std::vector<QVector3D> faceNormals;
    // Model/VTK picks use source triangle indices. The indexed mesh may omit
    // degenerate source facets, so painting needs an explicit stable mapping.
    std::vector<int> sourceFacetToIndexedFacet;
};
