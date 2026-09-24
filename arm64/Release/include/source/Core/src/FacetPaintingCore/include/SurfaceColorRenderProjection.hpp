#pragma once

#include "ManualSupportOrcaScaffold.hpp"
#include <Geometry.hpp>
#include <QVector3D>
#include <array>
#include <cstdint>
#include <functional>
#include <memory>
#include <string>
#include <vector>

struct SurfaceColorRenderProjectionInput {
    std::vector<GeomTriangle> sourceTriangles;
    std::string encodedState;
    std::string topologyFingerprint;
    int indexedTriangleCount{0};
};

struct SurfaceColorRenderProjectionResult {
    bool valid{false};
    std::string error;
    // Packed, immutable arrays let the render thread wrap the completed
    // result instead of rebuilding every VTK point and cell synchronously.
    std::vector<float> points;
    std::vector<float> normals;
    std::vector<std::uint32_t> labels;
    std::vector<std::int32_t> sourceFacets;
    std::vector<std::int64_t> cellOffsets;
    std::vector<std::int64_t> connectivity;
    std::uint32_t maximumLabel{0};
};

using SurfaceColorMatrix4 = std::array<float, 16>;

/** Packs an already-computed split surface without rebuilding the paint engine. */
SurfaceColorRenderProjectionResult packSurfaceColorRenderProjection(
    const std::vector<ManualSupportOrcaScaffold::LeafTriangle>& leaves,
    const std::vector<int>& sourceFacetToIndexedFacet,
    const SurfaceColorMatrix4& localFromInput);

/**
 * Builds the complete split-surface presentation from immutable values only.
 * Unpainted leaves are retained with label 0, allowing the result to replace
 * the base mesh in the same actor instead of being drawn as an overlay.
 * It has no document, actor, VTK or GUI dependency and is safe on a worker.
 */
SurfaceColorRenderProjectionResult buildSurfaceColorRenderProjection(
    SurfaceColorRenderProjectionInput input);

/**
 * Stable identity of an immutable derived surface. It deliberately contains
 * no document or renderer identity: equal mesh topology and encoded color
 * state must produce the same projection for every instance and backend.
 */
struct SurfaceColorRenderProjectionKey {
    std::array<std::uint8_t, 32> digest{};
    bool valid{false};

    bool operator==(const SurfaceColorRenderProjectionKey& other) const {
        return valid == other.valid && digest == other.digest;
    }
};

SurfaceColorRenderProjectionKey makeSurfaceColorRenderProjectionKey(
    const std::string& topologyFingerprint,
    const std::string& encodedState,
    int indexedTriangleCount);

std::string surfaceColorRenderProjectionKeyString(
    const SurfaceColorRenderProjectionKey& key);

using SurfaceColorRenderProjectionCallback = std::function<void(
    std::shared_ptr<const SurfaceColorRenderProjectionResult> projection)>;

enum class SurfaceColorRenderProjectionRequestDisposition {
    Scheduled,
    Coalesced,
    Cached,
    Rejected
};

struct SurfaceColorRenderProjectionRequest {
    SurfaceColorRenderProjectionKey key;
    // Invoked on the requesting thread only for the request that wins the
    // content-key race. This snapshots DB-owned source data before the task is
    // queued; coalesced and cached consumers never copy the source mesh.
    std::function<SurfaceColorRenderProjectionInput()> makeInput;
};

struct SurfaceColorRenderProjectionDiagnostics {
    std::uint64_t scheduled{0};
    std::uint64_t coalesced{0};
    std::uint64_t cacheHits{0};
    std::uint64_t completed{0};
    std::size_t inFlight{0};
};

/**
 * Content-addressed projection service shared by editing and every renderer.
 * It owns deduplication, bounded execution and immutable-result caching.
 * Callbacks may run on the requesting thread for a cache hit, or on a service
 * worker for an asynchronous result; consumers must marshal to their owner.
 */
SurfaceColorRenderProjectionRequestDisposition
requestSurfaceColorRenderProjection(
    SurfaceColorRenderProjectionRequest request,
    SurfaceColorRenderProjectionCallback callback);

void storeSurfaceColorRenderProjection(
    const SurfaceColorRenderProjectionKey& key,
    std::shared_ptr<const SurfaceColorRenderProjectionResult> projection);

std::shared_ptr<const SurfaceColorRenderProjectionResult>
findSurfaceColorRenderProjection(const SurfaceColorRenderProjectionKey& key);

SurfaceColorRenderProjectionDiagnostics
surfaceColorRenderProjectionDiagnostics();
