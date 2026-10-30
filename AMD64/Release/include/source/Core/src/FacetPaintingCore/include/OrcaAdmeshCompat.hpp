#pragma once

#include <Eigen/Core>
#include <Eigen/Geometry>
#include <cstdint>
#include <limits>
#include <vector>

namespace orca_compat {

using stl_vertex = Eigen::Matrix<float, 3, 1, Eigen::DontAlign>;
using stl_normal = Eigen::Matrix<float, 3, 1, Eigen::DontAlign>;
using stl_triangle_vertex_indices = Eigen::Matrix<int, 3, 1, Eigen::DontAlign>;
using Vec2i32 = Eigen::Matrix<int, 2, 1, Eigen::DontAlign>;
using Vec3i32 = Eigen::Matrix<int, 3, 1, Eigen::DontAlign>;
using Vec3f = stl_vertex;

struct stl_facet {
    stl_normal normal{stl_normal::Zero()};
    stl_vertex vertex[3]{
        stl_vertex::Zero(),
        stl_vertex::Zero(),
        stl_vertex::Zero()
    };
    char extra[2]{0, 0};
};

struct stl_neighbors {
    stl_neighbors() { reset(); }

    void reset() {
        neighbor[0] = -1;
        neighbor[1] = -1;
        neighbor[2] = -1;
        which_vertex_not[0] = -1;
        which_vertex_not[1] = -1;
        which_vertex_not[2] = -1;
    }

    int num_neighbors() const {
        return 3 - ((neighbor[0] == -1) + (neighbor[1] == -1) + (neighbor[2] == -1));
    }

    int neighbor[3];
    int8_t which_vertex_not[3];
};

struct stl_stats {
    uint32_t number_of_facets = 0;
    stl_vertex max = stl_vertex::Zero();
    stl_vertex min = stl_vertex::Zero();
    stl_vertex size = stl_vertex::Zero();
    float bounding_diameter = 0.0f;
    float shortest_edge = std::numeric_limits<float>::max();
    int connected_edges = 0;
    int connected_facets_1_edge = 0;
    int connected_facets_2_edge = 0;
    int connected_facets_3_edge = 0;
    int facets_removed = 0;
    int degenerate_facets = 0;
    int edges_fixed = 0;
    int backwards_edges = 0;
};

struct stl_file {
    std::vector<stl_facet> facet_start;
    std::vector<stl_neighbors> neighbors_start;
    stl_stats stats;

    void clear() {
        facet_start.clear();
        neighbors_start.clear();
        stats = stl_stats{};
    }
};

struct FaceProperty {
};

struct indexed_triangle_set {
    std::vector<stl_triangle_vertex_indices> indices;
    std::vector<stl_vertex> vertices;
    std::vector<FaceProperty> properties;

    void clear() {
        indices.clear();
        vertices.clear();
        properties.clear();
    }

    bool empty() const {
        return indices.empty() || vertices.empty();
    }
};

bool vertex_equal(const stl_vertex& lhs, const stl_vertex& rhs);
bool vertex_lower(const stl_vertex& lhs, const stl_vertex& rhs);

inline int its_triangle_vertex_index(const stl_triangle_vertex_indices& triangle_indices, int vertex_idx) {
    return vertex_idx == triangle_indices[0] ? 0 :
           vertex_idx == triangle_indices[1] ? 1 :
           vertex_idx == triangle_indices[2] ? 2 : -1;
}

inline Vec2i32 its_triangle_edge(const stl_triangle_vertex_indices& triangle_indices, int edge_idx) {
    const int next_edge_idx = edge_idx == 2 ? 0 : edge_idx + 1;
    return { triangle_indices[edge_idx], triangle_indices[next_edge_idx] };
}

struct VertexFaceIndex {
    explicit VertexFaceIndex(const indexed_triangle_set& its) { create(its); }

    void create(const indexed_triangle_set& its);

    struct IteratorRange {
        const size_t* beginPtr = nullptr;
        const size_t* endPtr = nullptr;

        const size_t* begin() const { return beginPtr; }
        const size_t* end() const { return endPtr; }
    };

    IteratorRange operator[](int vertex_idx) const {
        if (vertex_idx < 0 || vertex_idx + 1 >= static_cast<int>(m_vertex_to_face_start.size())) {
            return {};
        }
        return IteratorRange{
            m_vertex_faces_all.data() + m_vertex_to_face_start[vertex_idx],
            m_vertex_faces_all.data() + m_vertex_to_face_start[vertex_idx + 1]
        };
    }

    std::vector<size_t> m_vertex_to_face_start;
    std::vector<size_t> m_vertex_faces_all;
};

void stl_check_facets_exact(stl_file* stl);
void stl_verify_neighbors(stl_file* stl);
void stl_generate_shared_vertices(stl_file* stl, indexed_triangle_set& its);
std::vector<Vec3i32> its_face_neighbors(const indexed_triangle_set& its);
std::vector<Vec3f> its_face_normals(const indexed_triangle_set& its);

} // namespace orca_compat
