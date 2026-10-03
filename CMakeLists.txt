cmake_minimum_required(VERSION 3.21)
cmake_policy(SET CMP0091 NEW)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
project(CaptionMod LANGUAGES C CXX RC)

if(NOT WIN32 OR NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 4)
    message(FATAL_ERROR "CaptionMod requires Windows MSVC x86. Configure with -A Win32.")
endif()
get_property(multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(multi_config)
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Supported configurations" FORCE)
elseif(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release)$")
    message(FATAL_ERROR "Select Debug or Release.")
endif()

include(cmake/Dependencies.cmake)
captionmod_prepare_dependencies()
include("${VC_LTL_Root}/VC-LTL helper for cmake.cmake")

add_library(captionmod_settings INTERFACE)
target_compile_features(captionmod_settings INTERFACE cxx_std_20)
target_include_directories(captionmod_settings INTERFACE
    src
    include/Interface
    "${VGUI2EXTENSION_SOURCE_PATH}/include/Interface"
    "${VGUI2EXTENSION_SOURCE_PATH}/include/Interface/VGUI"
    "${METAHOOK_SOURCE_PATH}/include"
    "${METAHOOK_SOURCE_PATH}/include/Interface"
    "${METAHOOK_SOURCE_PATH}/include/Interface/VGUI"
    "${METAHOOK_SOURCE_PATH}/include/HLSDK/cl_dll"
    "${METAHOOK_SOURCE_PATH}/include/HLSDK/common"
    "${METAHOOK_SOURCE_PATH}/include/HLSDK/engine"
    "${METAHOOK_SOURCE_PATH}/include/HLSDK/pm_shared"
    "${METAHOOK_SOURCE_PATH}/include/HLSDK/public"
    "${METAHOOK_SOURCE_PATH}/include/VGUI"
    "${METAHOOK_SOURCE_PATH}/include/vgui_controls"
    "${METAHOOK_SOURCE_PATH}/include/SourceSDK"
    "${METAHOOK_SOURCE_PATH}/include/SourceSDK/tier0"
    "${METAHOOK_SOURCE_PATH}/include/SourceSDK/tier1"
    "${METAHOOK_SOURCE_PATH}/include/SourceSDK/vstdlib"
    # Matches the original project's CSVParserDirectory: the csv.hpp consumer
    # includes <single_include/csv.hpp>.
    "${PROJECT_SOURCE_DIR}/thirdparty/csv-parser-fork"
    "${METAHOOK_SOURCE_PATH}/include/SteamSDK"
)
target_compile_definitions(captionmod_settings INTERFACE WIN32 _WINDOWS _USRDLL _MBCS
    STEAM_API_NODLL VGUI_USE_SURFACE2 VGUI_USE_SCHEME2 VGUI_USE_INPUT2
    NO_MALLOC_OVERRIDE NO_TIER0_MINIDUMP NO_VCR)
target_compile_options(captionmod_settings INTERFACE /permissive /W3
    /wd4291 /wd4311 /wd4312 /wd4819 /wd4996
    $<$<CONFIG:Release>:/wd4091>)

include(cmake/Sources.cmake)
add_library(CaptionMod SHARED ${CAPTIONMOD_SOURCES})
target_link_libraries(CaptionMod PRIVATE captionmod_settings)
target_compile_definitions(CaptionMod PRIVATE $<$<CONFIG:Debug>:_DEBUG>)
target_compile_options(CaptionMod PRIVATE /MP /Zi)
target_link_options(CaptionMod PRIVATE /DEBUG /SUBSYSTEM:WINDOWS
    $<$<CONFIG:Debug>:/INCREMENTAL>
    $<$<CONFIG:Release>:/INCREMENTAL:NO;/OPT:REF;/OPT:ICF>)
set_target_properties(CaptionMod PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)

# Runtime resources are installed to the prefix root. Each assets/<mod>/ overlay
# keeps the mod directory name the source repository used, so merging it into the
# game is a recursive copy of one directory into the mod directory of the same
# name (svencoop, svencoop_hidpi, svencoop_schinese, gearbox, echoes).
install(TARGETS CaptionMod RUNTIME DESTINATION svencoop/metahook/plugins)
install(FILES "$<TARGET_PDB_FILE:CaptionMod>" DESTINATION svencoop/metahook/plugins)
foreach(mod svencoop svencoop_hidpi svencoop_schinese gearbox echoes)
    install(DIRECTORY "assets/${mod}/" DESTINATION "${mod}")
endforeach()
install(DIRECTORY include/ DESTINATION include)

# CaptionMod ships its own gamedata catalog, pruned to the symbols it resolves,
# in a nested directory the launcher's catalog loader merges
# (metahook/gamedata/captionmod). The manifest lists those symbols; the
# synchronizer downloads the upstream catalog into a persistent cache, prunes
# it, and publishes the result.
option(CAPTIONMOD_SYNC_GAMEDATA "Download and prune CaptionMod's gamedata catalog before building" ON)
set(CAPTIONMOD_GAMEDATA_DIR "${CMAKE_BINARY_DIR}/assets/svencoop/metahook/gamedata/captionmod" CACHE PATH "CaptionMod gamedata catalog directory")
if(CAPTIONMOD_SYNC_GAMEDATA)
    find_package(Python3 REQUIRED COMPONENTS Interpreter)
    add_custom_target(CaptionModGameData
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/scripts/sync-gamedata.py"
            --manifest "${CMAKE_CURRENT_SOURCE_DIR}/scripts/manifests/captionmod.json"
            --target-dir "${CAPTIONMOD_GAMEDATA_DIR}" --temp-root "${CMAKE_BINARY_DIR}/gamedata-sync"
        COMMENT "Synchronizing and validating CaptionMod gamedata"
        VERBATIM
    )
    add_custom_target(CaptionModGameDataValidate
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/scripts/validate-gamedata.py"
            "${CAPTIONMOD_GAMEDATA_DIR}" --manifest "${CMAKE_CURRENT_SOURCE_DIR}/scripts/manifests/captionmod.json"
        COMMENT "Validating CaptionMod gamedata against the manifest"
        VERBATIM
    )
    add_dependencies(CaptionModGameDataValidate CaptionModGameData)
    add_dependencies(CaptionMod CaptionModGameDataValidate)
endif()
install(DIRECTORY "${CAPTIONMOD_GAMEDATA_DIR}/" DESTINATION svencoop/metahook/gamedata/captionmod OPTIONAL)
