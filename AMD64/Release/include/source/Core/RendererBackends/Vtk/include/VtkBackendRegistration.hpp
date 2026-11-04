#pragma once

#include "ModuleRegistration.hpp"

namespace GPlatform::Rendering {

ModuleRegistrationList& vtkBackendModuleRegistrations();
// Registers every VTK DBSync factory entry exactly once.
void registerVtkBackendModule();

} // namespace GPlatform::Rendering

#define REGISTER_VTK_BACKEND_ENTRY(RegistrationCall)                             \
    GPLATFORM_ADD_MODULE_REGISTRATION(                                            \
        GPlatform::Rendering::vtkBackendModuleRegistrations, RegistrationCall)
