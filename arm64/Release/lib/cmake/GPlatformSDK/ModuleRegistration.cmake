include_guard(GLOBAL)

# Repository-wide module registration protocol. A module publishes one public
# entry point without knowing which executable will consume it.
function(gplatform_register_module)
    cmake_parse_arguments(
        MODULE
        ""
        "TARGET;HEADER;FUNCTION"
        ""
        ${ARGN}
    )

    if(NOT MODULE_TARGET OR NOT TARGET ${MODULE_TARGET})
        message(FATAL_ERROR
            "gplatform_register_module requires an existing TARGET")
    endif()
    if(NOT MODULE_HEADER OR NOT MODULE_FUNCTION)
        message(FATAL_ERROR
            "gplatform_register_module requires HEADER and FUNCTION")
    endif()

    get_property(_registered_targets GLOBAL PROPERTY
        GPLATFORM_REGISTERED_MODULE_TARGETS)
    if(MODULE_TARGET IN_LIST _registered_targets)
        message(FATAL_ERROR
            "Module target is already registered: ${MODULE_TARGET}")
    endif()

    get_property(_registered_functions GLOBAL PROPERTY
        GPLATFORM_REGISTERED_MODULE_FUNCTIONS)
    if(MODULE_FUNCTION IN_LIST _registered_functions)
        message(FATAL_ERROR
            "Module function is already registered: ${MODULE_FUNCTION}")
    endif()

    set_property(GLOBAL APPEND PROPERTY
        GPLATFORM_REGISTERED_MODULE_TARGETS "${MODULE_TARGET}")
    set_property(GLOBAL APPEND PROPERTY
        GPLATFORM_REGISTERED_MODULE_HEADERS "${MODULE_HEADER}")
    set_property(GLOBAL APPEND PROPERTY
        GPLATFORM_REGISTERED_MODULE_FUNCTIONS "${MODULE_FUNCTION}")
endfunction()

function(gplatform_link_self_registering_modules consumer_target)
    if(NOT TARGET ${consumer_target})
        message(FATAL_ERROR
            "Registration consumer target does not exist: ${consumer_target}")
    endif()

    foreach(_module_target IN LISTS ARGN)
        if(NOT TARGET ${_module_target})
            message(FATAL_ERROR
                "Self-registering module target does not exist: ${_module_target}")
        endif()
        if(NOT _module_target STREQUAL consumer_target)
            # Registration is also composition: a published module must enter
            # the consumer's link graph without a second Application-side list.
            get_target_property(_consumer_type ${consumer_target} TYPE)
            get_target_property(_module_type ${_module_target} TYPE)
            if(_module_type STREQUAL "STATIC_LIBRARY" AND
               _consumer_type STREQUAL "STATIC_LIBRARY")
                # A static library has no link step of its own. Preserve the
                # whole-archive feature in its link interface so the eventual
                # executable also retains every registration translation unit.
                target_link_libraries(${consumer_target} PRIVATE
                    "$<LINK_LIBRARY:WHOLE_ARCHIVE,${_module_target}>")
            else()
                target_link_libraries(${consumer_target} PRIVATE ${_module_target})
                if(_module_type STREQUAL "STATIC_LIBRARY")
                    set_property(TARGET ${consumer_target} PROPERTY
                        "LINK_LIBRARY_OVERRIDE_${_module_target}" WHOLE_ARCHIVE)
                endif()
            endif()
        endif()
    endforeach()
endfunction()

function(gplatform_link_registered_modules consumer_target)
    set(_module_targets ${ARGN})
    if(NOT _module_targets)
        get_property(_module_targets GLOBAL PROPERTY
            GPLATFORM_REGISTERED_MODULE_TARGETS)
    endif()

    # CMake maps WHOLE_ARCHIVE to the native Apple, GNU/Clang and MSVC linker
    # option, preserving translation units that contain static registrars.
    gplatform_link_self_registering_modules(
        ${consumer_target} ${_module_targets})
endfunction()
