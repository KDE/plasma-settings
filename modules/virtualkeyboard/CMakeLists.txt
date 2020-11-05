set(MALIIT_KEYBOARD_LANGUAGES_DIR "${CMAKE_INSTALL_LIBDIR}/maliit/keyboard2/languages" CACHE PATH "Directory containing maliit-keyboard data")

add_definitions(-DQT_NO_KEYWORDS)

set(virtualkeyboard_SRCS
    languagemodel.cpp
    gsettingsitem.cpp
    virtualkeyboard.cpp
)

add_library(kcm_mobile_virtualkeyboard MODULE ${virtualkeyboard_SRCS})

target_compile_definitions(kcm_mobile_virtualkeyboard PRIVATE "MALIIT_KEYBOARD_LANGUAGES_DIR=\"${CMAKE_INSTALL_PREFIX}/${MALIIT_KEYBOARD_LANGUAGES_DIR}\"")

target_link_libraries(kcm_mobile_virtualkeyboard
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
    PkgConfig::GIO
    PkgConfig::GOBJECT
)

kcoreaddons_desktop_to_json(kcm_mobile_virtualkeyboard "package/metadata.desktop")

install(TARGETS kcm_mobile_virtualkeyboard DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)

install(FILES package/metadata.desktop RENAME kcm_mobile_virtualkeyboard.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
kpackage_install_package(package kcm_mobile_virtualkeyboard kcms)
