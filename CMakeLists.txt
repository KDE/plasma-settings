project(plasma-settings)

cmake_minimum_required(VERSION 2.8.12)
cmake_policy(SET CMP0063 NEW)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "plasma-settings requires an out of source build. Please create a separate build directory and run 'cmake path_to_plasma-settings [options]' there.")
endif()

include(CPack)
include(FeatureSummary)
find_package(PkgConfig)

################# set KDE specific information #################

find_package(ECM 0.0.8 REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(ECMQMLModules)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui)

################# now find all used packages #################

set (QT_MIN_VERSION "5.4.0")

find_package(KF5 REQUIRED COMPONENTS
    WindowSystem
    CoreAddons
    Solid
    Config
    Auth
    DBusAddons
    I18n
    Plasma
    PlasmaQuick
    Declarative
    KIO
    KDELibs4Support
)

ecm_find_qmlmodule(org.kde.kcm 1.0)

add_subdirectory(src)
add_subdirectory(modules)

install(DIRECTORY package/ DESTINATION ${KDE_INSTALL_DATAROOTDIR}/kpackage/genericqml/org.kde.plasma.settings)

install(FILES org.kde.mobile.plasmasettings.desktop DESTINATION ${KDE_INSTALL_APPDIR})
