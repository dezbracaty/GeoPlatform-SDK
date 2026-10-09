#pragma once

#include <QMatrix4x4>
#include <QPoint>
#include <QPointF>
#include <QVector3D>
#include <array>
#include <cstddef>
#include <cstdint>
#include <functional>
#include <limits>
#include <memory>
#include <set>
#include <unordered_map>
#include <vector>

/**
 * @brief OrcaSlicer single-point painting flow scaffold.
 *
 * This class mirrors the key function boundaries and core selection logic
 * of OrcaSlicer's FDM manual support painter. It is intentionally isolated
 * from UI code so behavior can be reviewed and evolved incrementally.
 */
class ManualSupportOrcaScaffold {
public:
    enum class CursorType {
        Circle,
        Square,
        Triangle,
        Sphere,
        HeightRange
    };

    enum class PaintState : std::uint8_t {
        None = 0,
        Enforcer = 1,
        Blocker = 2
    };

    // Generic annotation label used by the reusable facet painting core.
    // Model colors use stable region IDs here; they are not packed into the
    // legacy three-value manual-support enum.
    using FacetLabelId = std::uint32_t;
    static constexpr FacetLabelId NoLabel = 0;
    static constexpr FacetLabelId label(PaintState state) {
        return static_cast<FacetLabelId>(state);
    }

    enum class Button {
        None,
        Left,
        Right
    };

    struct MouseInput {
        QPoint screenPos;
        bool shiftDown{false};
        bool altDown{false};
        bool controlDown{false};
    };

    struct RaycastResult {
        int meshId{-1};
        int facetId{-1};
        QVector3D hit{0.0f, 0.0f, 0.0f};
        QVector3D cameraPos{0.0f, 0.0f, 1.0f};
    };

    struct ProjectedMousePosition {
        int meshIdx{-1};
        int facetIdx{-1};
        QVector3D meshHit{0.0f, 0.0f, 0.0f};
    };

    struct ClippingPlane {
        QVector3D normal{0.0f, 0.0f, 1.0f};
        float offset{std::numeric_limits<float>::max()};

        bool is_active() const;
        bool is_mesh_point_clipped(const QVector3D& point) const;
    };

    struct TriangleBitStreamMapping {
        int triangleIdx{-1};
        int bitstreamStartIdx{-1};
    };

    struct TriangleSplittingData {
        std::vector<TriangleBitStreamMapping> trianglesToSplit;
        std::vector<bool> bitstream;
        std::vector<FacetLabelId> leafLabels;
        std::array<bool, 32> usedStates{};

        void clear();
        void update_used_states(std::size_t bitstreamStartIdx = 0);
    };

    /** Exact screen-space brush projection supplied by the active viewport. */
    struct ScreenProjection {
        float radiusUiPx{0.0f};
        std::function<bool(const QVector3D&, QPointF*)> projectOffsetUi;

        bool isValid() const {
            return radiusUiPx > 0.0f && static_cast<bool>(projectOffsetUi);
        }
    };

    class Cursor {
    public:
        virtual ~Cursor() = default;

        bool is_pointer_in_triangle(const std::array<int, 3>& vertsIdxs,
                                    const std::vector<QVector3D>& vertices) const;
        virtual bool is_mesh_point_inside(const QVector3D& point) const = 0;
        virtual bool is_pointer_in_triangle(const QVector3D& p1,
                                            const QVector3D& p2,
                                            const QVector3D& p3) const = 0;
        virtual int vertices_inside(const std::array<int, 3>& vertsIdxs,
                                    const std::vector<QVector3D>& vertices) const;
        virtual bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                           const std::vector<QVector3D>& vertices) const = 0;
        virtual bool is_facet_visible(int facetIdx,
                                      const std::vector<QVector3D>& faceNormals) const = 0;
        static bool is_facet_visible(const Cursor& cursor,
                                     int facetIdx,
                                     const std::vector<QVector3D>& faceNormals);

        float radius() const { return m_radius; }
        float radius_sqr() const { return m_radiusSqr; }
        bool uniform_scaling() const { return m_uniformScaling; }
        const QMatrix4x4& trafo() const { return m_trafo; }
        const QVector3D& direction() const { return m_dir; }
        const QVector3D& source() const { return m_source; }
        bool has_screen_projection() const { return m_screenProjection.isValid(); }

    protected:
        explicit Cursor(const QVector3D& source,
                        float radiusWorld,
                        const QMatrix4x4& trafo,
                        const ClippingPlane& clippingPlane,
                        ScreenProjection screenProjection);

        bool screen_offset(const QVector3D& point, QPointF* offsetUi) const;

        QVector3D m_source{0.0f, 0.0f, 0.0f};
        QMatrix4x4 m_trafo;
        QMatrix3x3 m_trafoNormal;
        bool m_uniformScaling{true};
        float m_radius{0.0f};
        float m_radiusSqr{0.0f};
        QVector3D m_dir{0.0f, 0.0f, 1.0f};
        ClippingPlane m_clippingPlane;
        ScreenProjection m_screenProjection;
    };

    class SinglePointCursor : public Cursor {
    public:
        SinglePointCursor(const QVector3D& center,
                          const QVector3D& source,
                          float radiusMm,
                          const QMatrix4x4& trafo,
                          const ClippingPlane& clippingPlane,
                          ScreenProjection screenProjection);

        static std::unique_ptr<Cursor> cursor_factory(const QVector3D& center,
                                                      const QVector3D& cameraPos,
                                                      float radiusMm,
                                                      CursorType cursorType,
                                                      const QMatrix4x4& trafo,
                                                      const ClippingPlane& clippingPlane,
                                                      ScreenProjection screenProjection);

        bool is_pointer_in_triangle(const QVector3D& p1,
                                    const QVector3D& p2,
                                    const QVector3D& p3) const override;

    protected:
        QVector3D m_center;
    };

    class DoublePointCursor : public Cursor {
    public:
        DoublePointCursor(const QVector3D& firstCenter,
                          const QVector3D& secondCenter,
                          const QVector3D& source,
                          float radiusMm,
                          const QMatrix4x4& trafo,
                          const ClippingPlane& clippingPlane);

        static std::unique_ptr<Cursor> cursor_factory(const QVector3D& firstCenter,
                                                      const QVector3D& secondCenter,
                                                      const QVector3D& cameraPos,
                                                      float radiusMm,
                                                      CursorType cursorType,
                                                      const QMatrix4x4& trafo,
                                                      const ClippingPlane& clippingPlane);

        bool is_pointer_in_triangle(const QVector3D& p1,
                                    const QVector3D& p2,
                                    const QVector3D& p3) const override;

    protected:
        QVector3D m_firstCenter;
        QVector3D m_secondCenter;
    };

    class CircleCursor : public SinglePointCursor {
    public:
        using SinglePointCursor::SinglePointCursor;
        bool is_mesh_point_inside(const QVector3D& point) const override;
        bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                   const std::vector<QVector3D>& vertices) const override;
        bool is_facet_visible(int facetIdx,
                              const std::vector<QVector3D>& faceNormals) const override;
    };

    class SphereCursor : public SinglePointCursor {
    public:
        using SinglePointCursor::SinglePointCursor;
        bool is_mesh_point_inside(const QVector3D& point) const override;
        bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                   const std::vector<QVector3D>& vertices) const override;
        bool is_facet_visible(int facetIdx,
                              const std::vector<QVector3D>& faceNormals) const override;
    };

    class HeightRangeCursor : public SinglePointCursor {
    public:
        HeightRangeCursor(float zWorld,
                          const QVector3D& source,
                          float height,
                          const QMatrix4x4& trafo,
                          const ClippingPlane& clippingPlane);

        bool is_mesh_point_inside(const QVector3D& point) const override;
        bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                   const std::vector<QVector3D>& vertices) const override;
        bool is_pointer_in_triangle(const QVector3D&,
                                    const QVector3D&,
                                    const QVector3D&) const override;
        bool is_facet_visible(int,
                              const std::vector<QVector3D>&) const override;

    private:
        float m_zWorld{0.0f};
        float m_height{0.1f};
    };

    class PlanarPolygonCursor : public SinglePointCursor {
    public:
        PlanarPolygonCursor(const QVector3D& center,
                            const QVector3D& source,
                            float radiusWorld,
                            const QMatrix4x4& trafo,
                            const ClippingPlane& clippingPlane,
                            std::vector<QPointF> polygonLocal,
                            ScreenProjection screenProjection);

        bool is_mesh_point_inside(const QVector3D& point) const override;
        bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                   const std::vector<QVector3D>& vertices) const override;
        bool is_pointer_in_triangle(const QVector3D& p1,
                                    const QVector3D& p2,
                                    const QVector3D& p3) const override;
        bool is_facet_visible(int facetIdx,
                              const std::vector<QVector3D>& faceNormals) const override;

    protected:
        bool point_to_local(const QVector3D& point, QPointF* local) const;
        bool contains_local(const QPointF& local) const;

    protected:
        QVector3D m_tangent{1.0f, 0.0f, 0.0f};
        QVector3D m_bitangent{0.0f, 1.0f, 0.0f};
        std::vector<QPointF> m_polygonLocal;
    };

    class SquareCursor : public PlanarPolygonCursor {
    public:
        SquareCursor(const QVector3D& center,
                     const QVector3D& source,
                     float radiusWorld,
                     const QMatrix4x4& trafo,
                     const ClippingPlane& clippingPlane,
                     ScreenProjection screenProjection);
    };

    class TriangleCursor : public PlanarPolygonCursor {
    public:
        TriangleCursor(const QVector3D& center,
                       const QVector3D& source,
                       float radiusWorld,
                       const QMatrix4x4& trafo,
                       const ClippingPlane& clippingPlane,
                       ScreenProjection screenProjection);
    };

    class Capsule3DCursor : public DoublePointCursor {
    public:
        using DoublePointCursor::DoublePointCursor;
        bool is_mesh_point_inside(const QVector3D& point) const override;
        bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                   const std::vector<QVector3D>& vertices) const override;
        bool is_facet_visible(int facetIdx,
                              const std::vector<QVector3D>& faceNormals) const override;
    };

    class Capsule2DCursor : public DoublePointCursor {
    public:
        using DoublePointCursor::DoublePointCursor;
        bool is_mesh_point_inside(const QVector3D& point) const override;
        bool is_edge_inside_cursor(const std::array<int, 3>& vertsIdxs,
                                   const std::vector<QVector3D>& vertices) const override;
        bool is_facet_visible(int facetIdx,
                              const std::vector<QVector3D>& faceNormals) const override;
    };

    struct ExternalHit {
        bool valid{false};
        QPoint screenPos;
        int meshId{-1};
        int facetId{-1};
        QVector3D worldHit{0.0f, 0.0f, 0.0f};
        QVector3D cameraPos{0.0f, 0.0f, 1.0f};
    };

    struct LeafTriangle {
        std::array<QVector3D, 3> vertices;
        FacetLabelId state{NoLabel};
        int sourceTriangle{-1};
    };

    struct SelectedSurfaceMesh {
        std::vector<QVector3D> vertices;
        std::vector<std::array<int, 3>> strictTriangles;
        std::vector<std::vector<int>> outerBoundaryLoops;
    };

public:
    void load_mesh(const std::vector<QVector3D>& vertices,
                   const std::vector<std::array<int, 3>>& triangles,
                   const std::vector<std::array<int, 3>>& neighbors = {},
                   const std::vector<QVector3D>& faceNormals = {});
    void clear_mesh();
    bool has_mesh() const;

    void update_external_hit(const ExternalHit& hit);
    void set_cursor_type(CursorType type);
    void set_cursor_radius(float radiusMm);
    void set_triangle_splitting_enabled(bool enabled);
    void set_cancellation_check(std::function<bool()> check);
    void set_active_paint_state(FacetLabelId state);
    void set_screen_projection(ScreenProjection projection);
    void set_projection_seed_facets(std::vector<int> facets);
    int projection_seed_component_count() const;
    FacetLabelId active_paint_state() const noexcept { return m_activePaintState; }

    bool on_mouse_left_down(const MouseInput& input);
    bool on_mouse_dragging(const MouseInput& input);
    bool on_mouse_left_up(const MouseInput& input);
    void reset_session();
    std::vector<LeafTriangle> collect_leaf_triangles() const;
    /** Complete split surface, including leaves with NoLabel. */
    std::vector<LeafTriangle> collect_all_leaf_triangles() const;
    std::vector<LeafTriangle> collect_projected_preview(int facetStart,
                                                        const QVector3D& worldHit,
                                                        const QVector3D& cameraPos,
                                                        float radiusWorld) const;
    std::vector<LeafTriangle> collect_triangle_preview(int facetStart,
                                                       const QVector3D& worldHit) const;
    std::vector<LeafTriangle> collect_fill_preview(int facetStart,
                                                   const QVector3D& worldHit,
                                                   float angleDeg,
                                                   bool edgeDetection) const;
    std::vector<LeafTriangle> collect_height_range_preview(float zWorld,
                                                           float height) const;
    std::vector<LeafTriangle> collect_gap_fill_preview(float maxArea) const;
    bool paint_triangle(int facetStart,
                        const QVector3D& worldHit,
                        FacetLabelId newState);
    bool paint_fill(int facetStart,
                    const QVector3D& worldHit,
                    FacetLabelId newState,
                    float angleDeg,
                    bool edgeDetection);
    bool paint_height_range(float zWorld,
                            float height,
                            FacetLabelId newState,
                            bool triangleSplitting);
    bool fill_small_gaps(float maxArea);
    bool remap_labels(const std::vector<FacetLabelId>& mapping);
    SelectedSurfaceMesh collect_selected_surface_mesh() const;
    std::vector<std::vector<QVector3D>> collect_selected_outer_boundary_loops() const;
    void set_highlight_by_angle_deg(float angleDeg);
    bool select_all_overhang_triangles(float angleDeg,
                                       FacetLabelId newState = label(PaintState::Enforcer),
                                       bool replaceExistingSelection = true);
    TriangleSplittingData snapshot_state() const;
    void restore_state_snapshot(const TriangleSplittingData& data);

    std::size_t triangle_storage_size() const noexcept { return m_triangles.size(); }
    std::size_t triangle_storage_capacity() const noexcept { return m_triangles.capacity(); }
    std::size_t invalid_triangle_count() const noexcept {
        return static_cast<std::size_t>(m_invalidTriangleCount);
    }
    std::size_t vertex_storage_size() const noexcept { return m_vertices.size(); }
    std::size_t free_vertex_count() const noexcept {
        return static_cast<std::size_t>(m_freeVertexCount);
    }

    const RaycastResult& raycast_cache() const noexcept { return m_rr; }
    const TriangleSplittingData& serialized_cache() const noexcept { return m_serializedCache; }

private:
    struct TriangleNode {
        std::array<int, 3> vertsIdxs{0, 0, 0};
        std::array<int, 4> children{-1, -1, -1, -1};
        int sourceTriangle{-1};
        int numberOfSplits{0};
        int specialSideIdx{0};
        FacetLabelId state{NoLabel};
        bool selectedBySeedFill{false};
        bool valid{true};

        bool is_split() const { return numberOfSplits != 0; }
        int number_of_split_sides() const { return numberOfSplits; }
        int child_count() const { return numberOfSplits == 0 ? 1 : numberOfSplits + 1; }
        int special_side() const { return specialSideIdx; }
        void set_division(int sidesToSplit, int specialSide);
        void set_state(FacetLabelId newState) { state = newState; }
    };

    struct LeafTopology {
        std::vector<int> triangleIndices;
        std::vector<std::vector<int>> neighbors;
        std::unordered_map<int, int> positionByTriangle;
    };

    struct GapFillCandidate {
        std::vector<int> triangleIndices;
        FacetLabelId replacement{NoLabel};
    };

    enum class Partition {
        First,
        Second
    };

    bool gizmo_event_left_down(const MouseInput& input);
    bool gizmo_event_dragging(const MouseInput& input);
    bool gizmo_event_left_up(const MouseInput& input);

    FacetLabelId resolve_new_state(const MouseInput& input, Button activeButton) const;

    void update_raycast_cache(const QPoint& mousePosition);
    std::vector<std::vector<ProjectedMousePosition>> get_projected_mouse_positions(const QPoint& mousePosition,
                                                                                    double resolution);

    bool process_single_point_branch(const ProjectedMousePosition& firstPosition, FacetLabelId newState);
    bool process_double_point_branch(const std::vector<ProjectedMousePosition>& positions, FacetLabelId newState);

    void select_patch(int facetStart,
                      std::unique_ptr<Cursor> cursor,
                      FacetLabelId newState,
                      bool triangleSplitting,
                      float highlightByAngleDeg);
    bool select_triangle(int facetIdx,
                         FacetLabelId newState,
                         bool triangleSplitting);
    bool select_triangle_recursive(int facetIdx,
                                   const std::array<int, 3>& neighbors,
                                   FacetLabelId newState,
                                   bool triangleSplitting);
    void split_triangle(int facetIdx,
                        const std::array<int, 3>& neighbors);
    void perform_split(int facetIdx,
                       const std::array<int, 3>& neighbors,
                       FacetLabelId oldState);
    int neighbor_child(const TriangleNode& triangle,
                       int vertexI,
                       int vertexJ,
                       Partition partition) const;
    int neighbor_child(int triangleIdx,
                       int vertexI,
                       int vertexJ,
                       Partition partition) const;
    int triangle_midpoint(const TriangleNode& triangle,
                          int vertexI,
                          int vertexJ) const;
    int triangle_midpoint(int triangleIdx,
                          int vertexI,
                          int vertexJ) const;
    std::array<int, 3> child_neighbors(const TriangleNode& triangle,
                                       const std::array<int, 3>& neighbors,
                                       int childIdx) const;
    void undivide_triangle(int facetIdx);
    void remove_useless_children(int facetIdx);
    void compact_subtree(int facetIdx);
    void invalidate_subtree(int facetIdx);
    void release_vertex(int vertexIdx);
    int allocate_midpoint_vertex(const QVector3D& point, std::uint64_t edgeKey);
    void garbage_collect_if_needed();
    void garbage_collect();
    void rebuild_edge_midpoint_cache();
    int push_triangle(int a, int b, int c, int sourceTriangle, FacetLabelId state);
    int triangle_midpoint_or_allocate(int triangleIdx, int v1, int v2);
    LeafTopology build_leaf_topology() const;
    int find_leaf_triangle(int rootIdx, const QVector3D& worldHit) const;
    std::vector<int> collect_fill_leaf_indices(int facetStart,
                                               const QVector3D& worldHit,
                                               float angleDeg,
                                               bool edgeDetection) const;
    std::vector<GapFillCandidate> collect_gap_fill_candidates(float maxArea) const;
    std::vector<int> original_facets_in_height_range(float bottom, float top) const;

    void request_update_render_data(bool fullRefresh);
    void update_model_object();
    void serialize_triangle_selector();
    void deserialize_triangle_selector();
    TriangleSplittingData serialize_state() const;
    void deserialize_state(const TriangleSplittingData& data);
    void reset_to_original_mesh();
    std::vector<std::array<int, 3>> collect_selected_strict_triangles() const;
    void collect_selected_strict_triangles_recursive(int triangleIdx,
                                                     const std::array<int, 3>& neighbors,
                                                     std::vector<std::array<int, 3>>& outTriangles) const;
    void append_triangle_split_by_tjoints(const std::array<int, 3>& vertices,
                                          const std::array<int, 3>& neighbors,
                                          std::vector<std::array<int, 3>>& outTriangles) const;
    std::array<int, 3> compute_neighbors_for_triangle(int facetIdx) const;
    void compute_original_neighbors();
    void compute_face_normals_if_missing();
    bool cancellation_requested() const;

private:
    Button m_buttonDown{Button::None};
    QPoint m_lastMouseClick;
    bool m_hasLastMouseClick{false};
    RaycastResult m_rr;
    ExternalHit m_externalHit;

    CursorType m_cursorType{CursorType::Circle};
    float m_cursorRadiusMm{8.0f};
    bool m_triangleSplittingEnabled{true};
    FacetLabelId m_activePaintState{label(PaintState::Enforcer)};
    bool m_renderDataDirty{false};
    float m_oldCursorRadiusSqr{0.0f};
    float m_edgeLimit{0.05f};
    float m_edgeLimitSqr{0.0025f};
    float m_highlightByAngleDeg{-1.0f};

    std::vector<QVector3D> m_vertices;
    std::vector<int> m_vertexRefCount;
    std::vector<int> m_freeVertexNext;
    std::vector<std::uint64_t> m_vertexEdgeKeys;
    std::vector<TriangleNode> m_triangles;
    std::vector<TriangleNode> m_originalTriangles;
    std::vector<std::array<int, 3>> m_originalNeighbors;
    std::vector<float> m_originalFacetMinZ;
    std::vector<float> m_originalFacetMaxZ;
    std::vector<int> m_originalFacetsByMinZ;
    QPoint m_lastRaycastMousePos;
    bool m_hasRaycastCache{false};
    std::vector<QVector3D> m_faceNormals;
    int m_originalTriangleCount{0};
    int m_originalVertexCount{0};
    int m_freeTrianglesHead{-1};
    int m_invalidTriangleCount{0};
    int m_freeVerticesHead{-1};
    int m_freeVertexCount{0};

    std::unique_ptr<Cursor> m_cursor;
    ScreenProjection m_screenProjection;
    std::vector<int> m_projectionSeedFacets;
    TriangleSplittingData m_serializedCache;
    // Original triangle roots which currently contain a label or a split
    // subtree. Keeping this index avoids scanning the complete imported mesh
    // whenever a small painted region is serialized or rendered.
    std::set<int> m_statefulRootTriangles;
    std::unordered_map<std::uint64_t, int> m_edgeMidpointCache;
    std::function<bool()> m_cancellationCheck;
};
