set(CAPTIONMOD_DEPENDENCY_CACHE_DIR "${PROJECT_SOURCE_DIR}/thirdparty/cache" CACHE PATH "Downloaded dependency cache")
set(VC_LTL_Root "${CAPTIONMOD_DEPENDENCY_CACHE_DIR}/VC-LTL-5.3.1" CACHE PATH "VC-LTL binary package root")
set(METAHOOK_SOURCE_PATH "$ENV{METAHOOK_SOURCE_PATH}" CACHE PATH "MetaHook source tree; empty fetches the pinned SDK")
set(VGUI2EXTENSION_SOURCE_PATH "$ENV{VGUI2EXTENSION_SOURCE_PATH}" CACHE PATH "VGUI2Extension source tree providing its public interface headers; empty fetches the pinned commit")

function(captionmod_init_submodule name)
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/thirdparty/${name}/.git")
        find_package(Git REQUIRED)
        execute_process(COMMAND "${GIT_EXECUTABLE}" -C "${PROJECT_SOURCE_DIR}"
            submodule update --init -- "thirdparty/${name}" RESULT_VARIABLE result)
        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Cannot initialize thirdparty/${name}: ${result}")
        endif()
    endif()
endfunction()

# Download a pinned dependency into the build tree. Only the source is
# populated: the caller keeps its own consumption so external trees stay
# read-only inputs and configurable at the same point as an explicit path.
function(captionmod_fetch_source name url tag out_var)
    include(FetchContent)
    FetchContent_Populate(${name}
        GIT_REPOSITORY "${url}"
        GIT_TAG "${tag}"
        GIT_SUBMODULES ""
        GIT_SUBMODULES_RECURSE FALSE
        SOURCE_DIR "${CMAKE_BINARY_DIR}/_deps/${name}-src")
    string(TOLOWER "${name}" name_lower)
    set(${out_var} "${${name_lower}_SOURCE_DIR}" PARENT_SCOPE)
endfunction()

function(captionmod_validate_vgui2extension_source source)
    foreach(required include/Interface/IVGUI2Extension.h include/Interface/IDpiManager.h
        include/Interface/VGUI/IInput2.h include/Interface/VGUI/IScheme2.h include/Interface/VGUI/ISurface2.h)
        if(NOT EXISTS "${source}/${required}" OR IS_DIRECTORY "${source}/${required}")
            message(FATAL_ERROR "VGUI2EXTENSION_SOURCE_PATH is missing ${required}: ${source}")
        endif()
    endforeach()
endfunction()

function(captionmod_prepare_dependencies)
    # Validate explicit paths before doing any downloads. External trees are read-only inputs.
    if(VGUI2EXTENSION_SOURCE_PATH)
        get_filename_component(vgui2extension_source "${VGUI2EXTENSION_SOURCE_PATH}" ABSOLUTE BASE_DIR "${PROJECT_SOURCE_DIR}")
        captionmod_validate_vgui2extension_source("${vgui2extension_source}")
    endif()
    if(METAHOOK_SOURCE_PATH)
        get_filename_component(metahook_source "${METAHOOK_SOURCE_PATH}" ABSOLUTE BASE_DIR "${PROJECT_SOURCE_DIR}")
    else()
        include(FetchContent)
        FetchContent_Declare(captionmod_metahook
            GIT_REPOSITORY https://github.com/MetaHookSv/MetaHook
            # MetaHook is tracked as a branch: always fetch the latest main.
            GIT_TAG origin/main
            GIT_SUBMODULES ""
            GIT_SUBMODULES_RECURSE FALSE
            # This SDK directory has no CMakeLists.txt: populate without building the launcher.
            SOURCE_SUBDIR include
        )
        FetchContent_MakeAvailable(captionmod_metahook)
        set(metahook_source "${captionmod_metahook_SOURCE_DIR}")
    endif()
    foreach(required include/metahook.h include/HLSDK/common/interface.cpp include/HLSDK/common/parsemsg.cpp include/SourceSDK/filesystem.cpp include/vgui_controls/Panel.cpp)
        if(NOT EXISTS "${metahook_source}/${required}")
            message(FATAL_ERROR "METAHOOK_SOURCE_PATH is missing ${required}: ${metahook_source}")
        endif()
    endforeach()
    set(METAHOOK_SOURCE_PATH "${metahook_source}" PARENT_SCOPE)
    message(STATUS "METAHOOK_SOURCE_PATH: ${metahook_source}")

    if(NOT VGUI2EXTENSION_SOURCE_PATH)
        captionmod_fetch_source(captionmod_vgui2extension
            "https://github.com/MetaHookSv/VGUI2Extension"
            "b60ec0f03c60cb7c8c6d3e59c3c38f4753cf1d0d" vgui2extension_source)
        captionmod_validate_vgui2extension_source("${vgui2extension_source}")
    endif()
    set(VGUI2EXTENSION_SOURCE_PATH "${vgui2extension_source}" PARENT_SCOPE)
    message(STATUS "VGUI2EXTENSION_SOURCE_PATH: ${vgui2extension_source}")

    captionmod_init_submodule(csv-parser-fork)
    include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/VCLTL.cmake")
    captionmod_prepare_vcltl()
endfunction()
