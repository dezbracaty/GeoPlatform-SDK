include_guard(GLOBAL)

function(_gplatform_resolve_renderer_target output_variable target_name)
    get_target_property(_aliased_target ${target_name} ALIASED_TARGET)
    if(_aliased_target)
        set(${output_variable} "${_aliased_target}" PARENT_SCOPE)
    else()
        set(${output_variable} "${target_name}" PARENT_SCOPE)
    endif()
endfunction()

function(_gplatform_assert_target_sources_hide_renderer_internals target_name forbid_vtk)
    get_target_property(_source_dir ${target_name} SOURCE_DIR)
    get_target_property(_sources ${target_name} SOURCES)
    if(NOT _sources)
        return()
    endif()

    foreach(_source IN LISTS _sources)
        if(_source MATCHES "^\\$<")
            continue()
        endif()
        if(IS_ABSOLUTE "${_source}")
            set(_absolute_source "${_source}")
        else()
            get_filename_component(
                _absolute_source "${_source}" ABSOLUTE BASE_DIR "${_source_dir}")
        endif()
        if(NOT EXISTS "${_absolute_source}" OR IS_DIRECTORY "${_absolute_source}")
            continue()
        endif()
        if(NOT _absolute_source MATCHES "\\.(c|cc|cpp|cxx|h|hh|hpp|hxx)$")
            continue()
        endif()

        file(READ "${_absolute_source}" _contents)
        if(_contents MATCHES
           "(RendererBackendVtk|VtkRendererSession|RendererBackendFilament|FilamentRendererSession|FilamentRenderThread)")
            message(FATAL_ERROR
                "Target ${target_name} references a concrete renderer backend: ${_absolute_source}")
        endif()
        if(_contents MATCHES
           "#include[ \t]*[<\"]([^\">]*/)?(renderThread|DBRenderAdapter|PickExecutor|RenderingContext|VtkDBSyncFactory|IDBSync)\\.hpp[\">]")
            message(FATAL_ERROR
                "Target ${target_name} includes a private renderer header: ${_absolute_source}")
        endif()
        if(forbid_vtk AND
           _contents MATCHES "#include[ \t]*[<\"]vtk[^\">]*[\">]")
            message(FATAL_ERROR
                "Target ${target_name} includes VTK directly: ${_absolute_source}")
        endif()
    endforeach()
endfunction()

function(_gplatform_assert_backend_uses_document_read_view target_name)
    get_target_property(_source_dir ${target_name} SOURCE_DIR)
    file(GLOB_RECURSE _sources CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE
        "${_source_dir}/src/*.c"
        "${_source_dir}/src/*.cc"
        "${_source_dir}/src/*.cpp"
        "${_source_dir}/src/*.cxx"
        "${_source_dir}/src/*.h"
        "${_source_dir}/src/*.hh"
        "${_source_dir}/src/*.hpp"
        "${_source_dir}/src/*.hxx")

    foreach(_source IN LISTS _sources)
        file(READ "${_source}" _contents)
        if(_contents MATCHES
           "#include[ \t]*[<\"]([^\">]*/)?(DocumentManager|Transaction|TransactionManager|UndoRedoManager|IDocumentRegistry)\\.hpp[\">]" OR
           _contents MATCHES "(DocumentManager|TransactionManager|UndoRedoManager)[ \t\n]*::" OR
           _contents MATCHES "(registerDBInstance|unregisterDBInstance|restoreObject|clearAllGeometry|setActiveWindow|attachOwnershipRelation|detachOwnershipRelation|attachDependencyRelation|detachDependencyRelation|flushPendingChanges|processBatchChanges|beginTransaction|commitTransaction|rollbackTransaction|undo|redo)[ \t\n]*\\(" OR
           _contents MATCHES "trans::TransDB[ \t\n]*::[ \t\n]*(create|destroy|remove|setProperty|setPropertyAny)[ \t\n]*\\(" OR
           _contents MATCHES "(->|\\.)[ \t\n]*(setProperty|setPropertyAny)[ \t\n]*\\(")
            message(FATAL_ERROR
                "Renderer backend ${target_name} bypasses the read-only Document boundary: ${_source}")
        endif()
    endforeach()
endfunction()

function(_gplatform_assert_public_contract_has_no_vtk target_name)
    set(_pending_targets ${target_name})
    set(_visited_targets "")
    while(_pending_targets)
        list(POP_FRONT _pending_targets _candidate)
        if(NOT TARGET ${_candidate})
            if(_candidate MATCHES "(^|::)(vtk|VTK|filament|Filament)")
                message(FATAL_ERROR
                    "Public renderer contract ${target_name} links a concrete renderer library through ${_candidate}")
            endif()
            continue()
        endif()

        _gplatform_resolve_renderer_target(_resolved_candidate ${_candidate})
        if(_resolved_candidate IN_LIST _visited_targets)
            continue()
        endif()
        list(APPEND _visited_targets ${_resolved_candidate})
        if(_resolved_candidate MATCHES "(^|::)(vtk|VTK|filament|Filament)")
            message(FATAL_ERROR
                "Public renderer contract ${target_name} links a concrete renderer library through ${_resolved_candidate}")
        endif()

        # Scan declared public-contract headers in every target in the usage
        # requirement closure. Do not recursively scan include directories:
        # AppDB has separate domain headers with VTK data; only declared
        # contract sources belong to this renderer-neutral validation.
        get_target_property(_candidate_source_dir ${_resolved_candidate} SOURCE_DIR)
        get_target_property(_candidate_sources ${_resolved_candidate} SOURCES)
        foreach(_source IN LISTS _candidate_sources)
            if(_source MATCHES "^\\$<" OR
               NOT _source MATCHES "\\.(h|hh|hpp|hxx)$")
                continue()
            endif()
            if(IS_ABSOLUTE "${_source}")
                set(_header "${_source}")
            else()
                get_filename_component(
                    _header "${_source}" ABSOLUTE
                    BASE_DIR "${_candidate_source_dir}")
            endif()
            if(NOT EXISTS "${_header}")
                continue()
            endif()
            file(READ "${_header}" _contents)
            if(_contents MATCHES "#include[ \t]*[<\"]vtk[^\">]*[\">]")
                message(FATAL_ERROR
                    "Public renderer contract ${target_name} exposes VTK in ${_header}")
            endif()
            if(_contents MATCHES
               "#include[ \t]*[<\"](filament|backend|utils)/[^\">]*[\">]")
                message(FATAL_ERROR
                    "Public renderer contract ${target_name} exposes Filament in ${_header}")
            endif()
        endforeach()

        get_target_property(
            _candidate_links ${_resolved_candidate} INTERFACE_LINK_LIBRARIES)
        foreach(_link IN LISTS _candidate_links)
            if(_link MATCHES "^\\$<LINK_ONLY:([^>]+)>$")
                set(_link "${CMAKE_MATCH_1}")
            elseif(_link MATCHES "^\\$<BUILD_INTERFACE:([^>]+)>$")
                set(_link "${CMAKE_MATCH_1}")
            elseif(_link MATCHES "^\\$<")
                continue()
            endif()
            if(_link MATCHES "(^|::)(vtk|VTK|filament|Filament)")
                message(FATAL_ERROR
                    "Public renderer contract ${target_name} links a concrete renderer library through ${_link}")
            endif()
            if(TARGET ${_link})
                list(APPEND _pending_targets ${_link})
            endif()
        endforeach()
    endwhile()

endfunction()

function(gplatform_assert_renderer_library_boundaries host_target backend_target)
    if(NOT TARGET ${host_target} OR NOT TARGET ${backend_target})
        message(FATAL_ERROR "Renderer boundary check received an unknown target")
    endif()

    get_target_property(_host_public_dirs ${host_target} INTERFACE_INCLUDE_DIRECTORIES)
    foreach(_dir IN LISTS _host_public_dirs)
        if(_dir MATCHES "/Render/(include|components|Backends)(/|$)")
            message(FATAL_ERROR
                "${host_target} exports a renderer implementation directory: ${_dir}")
        endif()
    endforeach()

    _gplatform_resolve_renderer_target(_backend_implementation ${backend_target})
    _gplatform_assert_backend_uses_document_read_view(${_backend_implementation})

    get_target_property(
        _backend_public_dirs ${_backend_implementation} INTERFACE_INCLUDE_DIRECTORIES)
    if(_backend_public_dirs AND
       NOT _backend_public_dirs MATCHES "-NOTFOUND$")
        message(FATAL_ERROR
            "${_backend_implementation} must not export include directories: ${_backend_public_dirs}")
    endif()

    get_target_property(
        _backend_public_links ${_backend_implementation} INTERFACE_LINK_LIBRARIES)
    foreach(_library IN LISTS _backend_public_links)
        # A static archive must forward its private link closure to the final
        # linker. LINK_ONLY does not add headers, definitions or compile-time
        # API to consumers, so it is still an implementation-only dependency.
        if(_library MATCHES "^\\$<LINK_ONLY:")
            continue()
        endif()
        if(_library MATCHES "(^|::)(vtk|VTK|filament|Filament)" OR
           _library STREQUAL "AppDB" OR
           _library STREQUAL "FacetPaintingCore")
            message(FATAL_ERROR
                "${_backend_implementation} exposes implementation dependency ${_library}")
        endif()
    endforeach()

    if(TARGET GPlatformRendererBackendSDK)
        get_target_property(
            _sdk_links GPlatformRendererBackendSDK INTERFACE_LINK_LIBRARIES)
        foreach(_library IN LISTS _sdk_links)
            if(_library MATCHES "(^|::)(vtk|VTK|filament|Filament)" OR
               _library STREQUAL "RendererBackendVtk" OR
               _library STREQUAL "RendererBackendFilament")
                message(FATAL_ERROR
                    "RendererBackendSDK exposes concrete backend dependency ${_library}")
            endif()
        endforeach()
    endif()

    _gplatform_assert_target_sources_hide_renderer_internals(BaseRender TRUE)
    _gplatform_assert_target_sources_hide_renderer_internals(${host_target} TRUE)
    _gplatform_assert_public_contract_has_no_vtk(BaseRender)
endfunction()

function(gplatform_assert_application_renderer_boundary application_target backend_target)
    if(NOT TARGET ${application_target} OR NOT TARGET ${backend_target})
        message(FATAL_ERROR "Application renderer boundary check received an unknown target")
    endif()

    _gplatform_resolve_renderer_target(_backend_implementation ${backend_target})
    get_target_property(_application_links ${application_target} LINK_LIBRARIES)
    foreach(_library IN LISTS _application_links)
        if(_library STREQUAL "${backend_target}" OR
           _library STREQUAL "${_backend_implementation}" OR
           _library STREQUAL "GPlatform::${_backend_implementation}")
            message(FATAL_ERROR
                "${application_target} must consume the renderer through Render, not ${_library}")
        endif()
    endforeach()

    # Some non-renderer domain/interaction code still carries legacy VTK data
    # types. This phase forbids backend implementation access from the app;
    # removing all domain-level VTK types is a separate migration.
    _gplatform_assert_target_sources_hide_renderer_internals(${application_target} FALSE)
endfunction()

function(gplatform_assert_registered_renderer_library_boundaries host_target)
    get_property(_backend_targets GLOBAL PROPERTY
        GPLATFORM_RENDERER_BACKEND_TARGETS)
    if(NOT _backend_targets)
        message(FATAL_ERROR "No registered renderer backends to validate")
    endif()
    foreach(_backend_target IN LISTS _backend_targets)
        gplatform_assert_renderer_library_boundaries(
            ${host_target} ${_backend_target})
    endforeach()
endfunction()

function(gplatform_assert_registered_renderer_application_boundary application_target)
    get_property(_backend_targets GLOBAL PROPERTY
        GPLATFORM_RENDERER_BACKEND_TARGETS)
    if(NOT _backend_targets)
        message(FATAL_ERROR "No registered renderer backends to validate")
    endif()
    foreach(_backend_target IN LISTS _backend_targets)
        gplatform_assert_application_renderer_boundary(
            ${application_target} ${_backend_target})
    endforeach()
endfunction()
