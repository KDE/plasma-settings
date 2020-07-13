project(plasma-settings)

cmake_minimum_required(VERSION 2.8.12)
cmake_policy(SET CMP0063 NEW)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "plasma-settings requires an out of source build. Please create a separate build directory and run 'cmake path_to_plasma-settings [options]' there.")
endif()

include(CPack)
include(FeatureSummary)

################# set KDE specific information #################

set (QT_MIN_VERSION "5.14.0")
set (KF5_MIN_VERSION "5.70")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(ECMQMLModules)

################# now find all used packages #################

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    CoreAddons
    Solid
    Config
    Auth
    DBusAddons
    I18n
    Plasma
    Declarative
    KIO
    KDELibs4Support
)

ecm_find_qmlmodule(org.kde.kcm 1.0)

add_subdirectory(src)
add_subdirectory(modules)

install(FILES org.kde.mobile.plasmasettings.desktop DESTINATION ${KDE_INSTALL_APPDIR})
