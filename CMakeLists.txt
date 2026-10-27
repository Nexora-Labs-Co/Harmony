cmake_minimum_required(VERSION 3.16)
project(Nexora
    VERSION 0.1.0
    DESCRIPTION "Nexora - Reproductor de música multiplataforma"
    LANGUAGES C CXX
)

# Opciones configurables
option(NEXORA_BUILD_TESTS "Construir tests" OFF)
option(NEXORA_USE_QT "Usar Qt6 para la UI" ON)
option(NEXORA_USE_MINIAUDIO "Usar miniaudio como backend de audio" ON)

# Estandar C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Políticas útiles
if(POLICY CMP0074)
    cmake_policy(SET CMP0074 NEW)
endif()
if(POLICY CMP0063)
    cmake_policy(SET CMP0063 NEW)
endif()

# Rutas
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Detección de plataforma
if(WIN32)
    add_definitions(-DNEXORA_PLATFORM_WINDOWS)
    set(NEXORA_OS_NAME "Windows")
elseif(UNIX AND NOT APPLE)
    add_definitions(-DNEXORA_PLATFORM_LINUX)
    set(NEXORA_OS_NAME "Linux")
else()
    message(FATAL_ERROR "Plataforma no soportada por este proyecto inicial")
endif()

# Dependencias
if(NEXORA_USE_QT)
    find_package(Qt6 QUIET COMPONENTS Core Gui Widgets Qml Quick)
    if(Qt6_FOUND)
        set(NEXORA_HAS_QT ON)
        set(CMAKE_AUTOMOC ON)
        set(CMAKE_AUTOUIC ON)
        set(CMAKE_AUTORCC ON)
    else()
        message(WARNING "Qt6 no encontrado. Se construirá sin soporte Qt.")
        set(NEXORA_HAS_QT OFF)
    endif()
else()
    set(NEXORA_HAS_QT OFF)
endif()

# Incluir directorios
include_directories(
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/third_party
)

# Subdirectorios
add_subdirectory(src/core)
add_subdirectory(src/backend)
add_subdirectory(src/ui)
add_subdirectory(src/app)

# Tests opcionales
if(NEXORA_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Configuración CPack para .deb (Linux) y .exe/.installer (Windows)
include(CPack)

# Configuración específica por plataforma
if(UNIX AND NOT APPLE)
    # Linux / Debian family
    set(CPACK_GENERATOR "DEB")
    set(CPACK_PACKAGE_NAME "nexora")
    set(CPACK_PACKAGE_VENDOR "Nexora Labs Co.")
    set(CPACK_PACKAGE_CONTACT "contact@nexora-labs.example")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Reproductor de música ligero y modular")
    set(CPACK_PACKAGE_DESCRIPTION "Nexora es un reproductor de música multiplataforma con arquitectura modular, enfocado a eficiencia y extensibilidad.")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Nexora Labs Co. <contact@nexora-labs.example>")
    set(CPACK_DEBIAN_PACKAGE_SECTION "sound")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt6core6, libqt6gui6, libqt6widgets6, libasound2, libpulse0, pipewire-bin | pipewire")
    set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "/opt/nexora")
    if(EXISTS "${CMAKE_SOURCE_DIR}/packaging/linux/nexora.desktop")
        install(FILES ${CMAKE_SOURCE_DIR}/packaging/linux/nexora.desktop DESTINATION /usr/share/applications)
    endif()
    if(EXISTS "${CMAKE_SOURCE_DIR}/assets/icons/nexora.png")
        install(FILES ${CMAKE_SOURCE_DIR}/assets/icons/nexora.png DESTINATION /usr/share/icons/hicolor/256x256/apps)
    endif()
elseif(WIN32)
    # Windows - NSIS recomendado para instalador .exe amigable
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_PACKAGE_NAME "Nexora")
    set(CPACK_PACKAGE_VENDOR "Nexora Labs Co.")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "Nexora")
    set(CPACK_NSIS_DISPLAY_NAME "Nexora Music Player")
    set(CPACK_NSIS_PACKAGE_NAME "Nexora Setup")
    set(CPACK_NSIS_CONTACT "contact@nexora-labs.example")
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    set(CPACK_NSIS_MODIFY_PATH ON)
    if(EXISTS "${CMAKE_SOURCE_DIR}/assets/icons/nexora.ico")
        set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/assets/icons/nexora.ico")
        set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/assets/icons/nexora.ico")
    endif()
endif()

set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PROJECT_VERSION}-${NEXORA_OS_NAME}")
