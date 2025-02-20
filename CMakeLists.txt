cmake_minimum_required(VERSION 3.16)

set(PROJECT_VERSION "25.02.0")
project(plasma-settings VERSION ${PROJECT_VERSION})

include(FeatureSummary)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set (QT_MIN_VERSION "6.6.0")
set (KF6_MIN_VERSION "6.0.0")
set(KDE_COMPILERSETTINGS_LEVEL "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(KDEClangFormat)
include(KDEGitCommitHooks)

include(ECMQMLModules)
include(ECMSetupVersion)
include(ECMDeprecationSettings)
include(ECMQmlModule)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX PLASMA_SETTINGS
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets)
find_package(KF6KirigamiAddons 1.0 REQUIRED)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    CoreAddons
    DBusAddons
    I18n
    KCMUtils
    Crash
    Service
    ItemViews
    ItemModels
)

ecm_set_disabled_deprecation_versions(QT 6.7.2  KF 6.5.0)

add_subdirectory(categories)
add_subdirectory(src)

ki18n_install(po)

install(FILES org.kde.mobile.plasmasettings.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps/)
install(FILES org.kde.mobile.plasmasettings.desktop DESTINATION ${KDE_INSTALL_APPDIR})

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
