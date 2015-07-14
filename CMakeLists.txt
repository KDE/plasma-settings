project(plasma-settings)

cmake_minimum_required(VERSION 2.8.10.1)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "plasma-mobile requires an out of source build. Please create a separate build directory and run 'cmake path_to_plasma-mobile [options]' there.")
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

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui)

################# now find all used packages #################

set (QT_MIN_VERSION "5.4.0")

find_package(KF5 REQUIRED COMPONENTS
    WindowSystem CoreAddons Solid Config Auth DBusAddons
    I18n Plasma PlasmaQuick Declarative KIO KDELibs4Support
    )

find_package(KAccounts)
find_package(AccountsQt5 1.10 CONFIG)
find_package(SignOnQt5 8.55 CONFIG)

if (KAccounts_FOUND AND AccountsQt5_FOUND AND SignOnQt5_FOUND)
    find_package(KF5GAPI REQUIRED)
    find_package(Qt5WebKitWidgets REQUIRED) #needed for kgapi apparently
    include_directories(${ACCOUNTSQT_INCLUDE_DIRS} ${SIGNONQT_INCLUDE_DIRS})
endif()

add_subdirectory(src)
add_subdirectory(import)
add_subdirectory(modules)

plasma_install_package(package org.kde.active.settings packages package)


install(FILES active-settings.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

