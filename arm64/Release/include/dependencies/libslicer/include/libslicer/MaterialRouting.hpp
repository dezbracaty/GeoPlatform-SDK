#pragma once
#include "Export.hpp"
#include <algorithm>
#include <cstddef>
#include <string>
#include <vector>

namespace libslicer {
class ConfigSnapshot;
enum class ModelMaterialPolicy { PreserveAssignments, UseSelectedOrdinaryMaterial };
enum class MaterialRole { Ordinary, ContinuousFiber };
struct MaterialRoute {
    int filament_slot{1}; // Serialized model labels are one-based.
    int physical_tool{0}; // Tools and channels are zero-based.
    int supply_channel{0};
    MaterialRole role{MaterialRole::Ordinary};
};
struct SourceMaterialBinding {
    std::string source_group;
    int source_label{1};
    int filament_slot{1};
};
struct MaterialRoutingPlan {
    ModelMaterialPolicy policy{ModelMaterialPolicy::PreserveAssignments};
    int selected_ordinary_slot{1};
    std::string protocol;
    std::vector<MaterialRoute> routes;
    std::vector<std::string> diagnostics;
    bool valid() const { return diagnostics.empty() && !routes.empty(); }
    bool uses_source_paint() const { return policy == ModelMaterialPolicy::PreserveAssignments; }
    const MaterialRoute* route(int slot) const {
        const auto it = std::find_if(routes.begin(), routes.end(), [slot](const auto& r) { return r.filament_slot == slot; });
        return it == routes.end() ? nullptr : &*it;
    }
    // Explicit source bindings are scoped to an imported material group; they
    // never re-interpret a source label as another group's material identity.
    int ordinary_slot(int source_label, const std::string& group = {},
                      const std::vector<SourceMaterialBinding>& bindings = {}) const {
        int slot = selected_ordinary_slot;
        if (uses_source_paint()) {
            slot = source_label;
            if (!bindings.empty()) {
                const auto it = std::find_if(bindings.begin(), bindings.end(), [&](const auto& b) {
                    return b.source_group == group && b.source_label == source_label;
                });
                if (it == bindings.end()) return 0;
                slot = it->filament_slot;
            }
        }
        const auto* r = route(slot);
        return r && r->role == MaterialRole::Ordinary ? slot : 0;
    }
};
struct MaterialRoutingInput {
    ModelMaterialPolicy policy{ModelMaterialPolicy::PreserveAssignments};
    int selected_ordinary_slot{1};
    int physical_tool_count{1};
    std::string protocol{"none"};
    std::vector<MaterialRole> tool_roles; // Empty for legacy ordinary printers.
    std::vector<MaterialRoute> routes;
};
inline MaterialRoutingPlan resolve_material_routing(const MaterialRoutingInput& input) {
    MaterialRoutingPlan p;
    p.policy = input.policy; p.selected_ordinary_slot = input.selected_ordinary_slot;
    p.protocol = input.protocol; p.routes = input.routes;
    const auto fail = [&](std::string message) { p.diagnostics.push_back(std::move(message)); };
    for (std::size_t i = 0; i < p.routes.size(); ++i) {
        const auto& r = p.routes[i];
        const std::string name = "Material " + std::to_string(r.filament_slot);
        if (r.filament_slot != int(i) + 1) fail(name + ": material slots must be contiguous");
        if (r.physical_tool < 0 || r.physical_tool >= input.physical_tool_count) {
            fail(name + ": physical tool is unavailable"); continue;
        }
        if (!input.tool_roles.empty() && (std::size_t(r.physical_tool) >= input.tool_roles.size() ||
            input.tool_roles[r.physical_tool] != r.role))
            fail(name + ": material purpose is incompatible with the physical tool");
        if (r.supply_channel < 0) fail(name + ": supply channel is unavailable");
        for (std::size_t j = 0; j < i; ++j) if (p.routes[j].physical_tool == r.physical_tool) {
            if (r.role == MaterialRole::ContinuousFiber || p.routes[j].role == MaterialRole::ContinuousFiber)
                fail(name + ": a continuous-fiber tool must have one dedicated material");
            if (r.supply_channel == p.routes[j].supply_channel) fail(name + ": supply channel is already assigned");
            if (!input.tool_roles.empty() && p.protocol != "logical_t_v1")
                fail(name + ": shared physical tool requires a declared material-change protocol");
        }
        if (!input.tool_roles.empty() && p.protocol != "logical_t_v1" && r.physical_tool != int(i))
            fail(name + ": non-identity tool mapping requires a declared material-change protocol");
        if (p.protocol == "logical_t_v1" && r.supply_channel != int(i))
            fail(name + ": logical T protocol requires channel aliases matching logical material IDs");
    }
    if (p.routes.empty()) fail("No materials are configured");
    if (p.policy == ModelMaterialPolicy::UseSelectedOrdinaryMaterial && !p.ordinary_slot(1))
        fail("Selected model material must use an ordinary-material tool");
    if (p.protocol != "none" && p.protocol != "logical_t_v1") fail("Unknown material-change protocol");
    return p;
}
LIBSLICER_API MaterialRoutingPlan resolve_material_routing(const ConfigSnapshot& config);
} // namespace libslicer
