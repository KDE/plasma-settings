project(plasma-settings)

set(PROJECT_VERSION "22.06")

cmake_minimum_required(VERSION 3.16)

include(FeatureSummary)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set (QT_MIN_VERSION "5.15.0")
set (KF5_MIN_VERSION "5.86")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(ECMQMLModules)
include(ECMSetupVersion)
include(KDEClangFormat)
include(KDEGitCommitHooks)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX PLASMA_SETTINGS
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    CoreAddons
    Solid
    Config
    Auth
    DBusAddons
    I18n
    Plasma
    Service
    Declarative
    KIO
    ModemManagerQt
    NetworkManagerQt
)

find_package(PkgConfig REQUIRED)

pkg_check_modules(GOBJECT gobject-2.0 REQUIRED IMPORTED_TARGET)
pkg_check_modules(GIO gio-2.0 REQUIRED IMPORTED_TARGET)

ecm_find_qmlmodule(org.kde.kcm 1.0)

add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0x060000)

add_subdirectory(src)
add_subdirectory(modules)

ki18n_install(po)

install(FILES org.kde.mobile.plasmasettings.desktop DESTINATION ${KDE_INSTALL_APPDIR})

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
