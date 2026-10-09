#pragma once

#include <memory>

namespace GPlatform::Rendering {

class IRenderViewLifecycleSink;

void configureGraphicsBeforeApplication();
void configureGraphicsAfterApplication();
void configureRenderViewLifecycleSink(
    std::shared_ptr<IRenderViewLifecycleSink> sink);

// Render-host internal access to the application-composed lifecycle port.
std::shared_ptr<IRenderViewLifecycleSink> renderViewLifecycleSink();

} // namespace GPlatform::Rendering
