add_library(nexora_core
    audio/AudioEngine.cpp
    audio/backends/MiniaudioBackend.cpp
    models/LocalTrack.cpp
)

target_include_directories(nexora_core PUBLIC
    ${CMAKE_SOURCE_DIR}/src/core
    ${CMAKE_SOURCE_DIR}/third_party
)

# miniaudio needs to be defined in exactly one translation unit
# Also link system libraries on Linux for audio backends
if(UNIX AND NOT APPLE)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_check_modules(ALSA QUIET alsa)
        pkg_check_modules(PULSE QUIET libpulse)
    endif()
    target_link_libraries(nexora_core PUBLIC ${ALSA_LIBRARIES} ${PULSE_LIBRARIES} dl pthread m)
    target_include_directories(nexora_core PUBLIC ${ALSA_INCLUDE_DIRS} ${PULSE_INCLUDE_DIRS})
elseif(WIN32)
    target_link_libraries(nexora_core PUBLIC winmm)
endif()

if(NEXORA_USE_MINIAUDIO)
    target_compile_definitions(nexora_core PUBLIC NEXORA_USE_MINIAUDIO)
endif()
