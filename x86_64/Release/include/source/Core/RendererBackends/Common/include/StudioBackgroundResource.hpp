#pragma once

#include <string_view>

namespace GPlatform::Rendering {

inline constexpr std::string_view kPrintStudioEnvironmentUri =
    "builtin://gplatform/environment/print-studio";
inline constexpr std::string_view kStudioLightBackgroundResource =
    ":/startup-tests/renderers/studio_light.png";
inline constexpr std::string_view kStudioDarkBackgroundResource =
    ":/startup-tests/renderers/studio_dark.png";

// Resolve only the built-in visible background. Stored URIs and lighting
// resources remain independent of the application's current theme.
constexpr std::string_view resolveStudioBackgroundResource(
    std::string_view source, bool darkTheme) noexcept {
    return source == kPrintStudioEnvironmentUri
        ? (darkTheme ? kStudioDarkBackgroundResource
                     : kStudioLightBackgroundResource)
        : source;
}

} // namespace GPlatform::Rendering
