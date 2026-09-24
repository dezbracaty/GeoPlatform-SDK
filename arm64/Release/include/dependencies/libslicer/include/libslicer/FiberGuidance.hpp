#pragma once

#include <array>
#include <cstddef>
#include <string>
#include <vector>

namespace libslicer {

enum class FiberGuidanceRequirement { Preferred, Required };
enum class FiberGuidanceHeightMode { Interval, WholeObject };
enum class FiberGuidanceStatus {
    NotRequested, Satisfied, Unmet, Conflict, Unsupported,
    LayerScheduleExcluded, NoIntersection
};

struct FiberGuidanceRegionInput {
    std::string id;
    std::string name;
    bool enabled{true};
    std::array<double, 16> region_to_object{
        1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
    std::vector<std::array<double, 2>> polygon_uv_mm;
    FiberGuidanceHeightMode height_mode{FiberGuidanceHeightMode::Interval};
    double h_min_mm{0};
    double h_max_mm{0};
    std::array<double, 2> axis_uv{1,0};
    double spacing_mm{0};
    double angle_tolerance_deg{10};
    double minimum_spacing_coverage{0.95};
    FiberGuidanceRequirement requirement{FiberGuidanceRequirement::Preferred};
    int priority{0};
};

struct FiberGuidancePolygon {
    std::vector<std::array<double, 2>> contour;
    std::vector<std::vector<std::array<double, 2>>> holes;
};

struct FiberGuidanceLayerReport {
    std::string source_instance_id;
    std::string region_id;
    std::size_t layer_index{0};
    double slice_z_mm{0};
    FiberGuidanceStatus status{FiberGuidanceStatus::NoIntersection};
    bool required{false};
    double requested_area_mm2{0};
    double eligible_area_mm2{0};
    double actual_fiber_area_mm2{0};
    double aligned_fiber_area_mm2{0};
    double directional_spacing_coverage{0};
    double aligned_length_mm{0};
    std::vector<std::string> reason_codes;
    // Print-bed XY, millimetres; never machine/tool-offset coordinates.
    std::vector<FiberGuidancePolygon> requested;
    std::vector<FiberGuidancePolygon> uncovered;
    std::vector<FiberGuidancePolygon> excluded;
};

} // namespace libslicer
