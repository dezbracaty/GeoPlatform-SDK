#pragma once

#include <QVector3D>

#include <array>
#include <vector>

// Pure geometry for the Flatten ("place on face") tool: cluster a triangle soup into connected,
// near-coplanar face groups — the set of selectable faces. Deliberately free of VTK / DB / Qt-Gui-
// widget dependencies (only QVector3D for vector math) so it can be unit-tested with known meshes
// (see tests/Placement/validation/PlaneGroupingCheck.cpp). FlattenHandler feeds it the model's
// triangles and consumes the groups; the tested code is therefore the production code.
namespace placement {

// One triangle as 9 floats: v0(x,y,z), v1(x,y,z), v2(x,y,z).
using Tri = std::array<float, 9>;

// A connected run of near-coplanar triangles — one logical placeable face.
struct PlaneGroup {
    QVector3D normal;          // area-weighted, outward-oriented, normalized
    std::vector<int> cellIds;  // indices into the input triangle array
};

struct PlaneGroupingResult {
    std::vector<PlaneGroup> groups;
    std::vector<int> cellToGroup; // per input triangle → surviving group index, or -1 (filtered/degenerate)
};

// Orca-style selectable overlays. Each logical plane is represented by one
// inset, rounded boundary polygon. The triangles below are only the final
// rendering/picking tessellation and are never independent choices.
struct PlaneOverlayMesh {
    std::vector<std::vector<QVector3D>> groupPolygons;
    std::vector<Tri> triangles;
    std::vector<int> triangleToGroup;
};

// Cluster `tris` into connected, near-coplanar face groups:
//   - each triangle's normal is taken from its winding and flipped to point away from `outwardRef`
//     (pass the mesh centre) so coplanar inner/outer faces orient consistently;
//   - coincident vertices are welded on a `weldGridMm` grid so independently-stored STL facets share
//     edges (without this, STL triangles have no shared vertices and never become neighbours);
//   - triangles are grown by BFS over shared welded edges, joined only when every normal component
//     differs from the seed by less than `normalComponentTol`, matching OrcaSlicer's flatten gizmo;
//   - any group whose total area is below `minAreaMm2` is dropped.
// Defaults mirror OrcaSlicer's flatten gizmo (0.001 component tolerance, 5 mm² minimum face).
PlaneGroupingResult groupCoplanarFaces(const std::vector<Tri>& tris,
                                       const QVector3D& outwardRef,
                                       float normalComponentTol = 0.001f,
                                       float minAreaMm2   = 5.0f,
                                       float weldGridMm   = 0.001f);

// Convert grouped hull facets into Orca-style complete plane patches: project
// each group to 2D, take its convex outline, reject tiny/needle-like polygons,
// inset it, round its corners, lift it off the surface, then tessellate it.
PlaneOverlayMesh buildPlaneOverlay(const std::vector<Tri>& tris,
                                   const PlaneGroupingResult& grouping,
                                   float insetScale = 0.9f,
                                   float surfaceOffsetMm = 0.1f,
                                   int smoothingIterations = 10,
                                   float minimalSideMm = 1.0f,
                                   float minimalAngleDegrees = 1.0f);

// Exact 3D convex hull of `points`, returned as a triangle soup (each Tri = 9 floats). The hull is the
// set of supporting faces a body can rest on, so it is the right input for "place on face": feeding the
// result to groupCoplanarFaces yields the placeable faces, free of the interior/concave detail that
// makes raw-mesh clustering over-segment organic models.
//
// Implementation is QuickHull on the (de-duplicated) point set. Triangle winding is NOT guaranteed
// outward — callers re-derive normals via groupCoplanarFaces(outwardRef), which only needs positions.
// Returns an empty vector for degenerate input (fewer than 4 non-coplanar points: coincident, collinear
// or planar) — a body with volume always has a valid hull, so real models never hit this. `weldGridMm`
// de-dupes coincident input points; `epsilon` is the distance tolerance for visibility/coplanarity (mm).
std::vector<Tri> convexHull3D(const std::vector<QVector3D>& points,
                              float epsilon    = 1e-4f,
                              float weldGridMm = 1e-4f);

// Reorder face groups largest-first (by total triangle area over `tris`, which must be the same soup
// the groups index into) and, if maxFaces > 0, keep only the largest `maxFaces`. cellToGroup is remapped
// to the new ordering; cells of dropped groups become -1. Puts the easiest faces to click first and
// bounds the overlay for pathological meshes.
PlaneGroupingResult rankFaceGroups(PlaneGroupingResult in,
                                   const std::vector<Tri>& tris,
                                   int maxFaces = 0);

} // namespace placement
