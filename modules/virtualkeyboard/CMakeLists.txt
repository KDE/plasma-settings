set(MALIIT_KEYBOARD_LANGUAGES_DIR "${CMAKE_INSTALL_FULL_LIBDIR}/maliit/keyboard2/languages" CACHE PATH "Directory containing maliit-keyboard data")
set(MALIIT_KEYBOARD_THEMES_DIR "${CMAKE_INSTALL_FULL_DATADIR}/maliit/keyboard2/themes" CACHE PATH "Directory containing maliit themes")

add_definitions(-DQT_NO_KEYWORDS)

set(onscreenkeyboard_SRCS
    languagemodel.cpp
    gsettingsitem.cpp
    virtualkeyboard.cpp
)

add_library(kcm_mobile_onscreenkeyboard MODULE ${onscreenkeyboard_SRCS})

target_compile_definitions(kcm_mobile_onscreenkeyboard PRIVATE "MALIIT_KEYBOARD_LANGUAGES_DIR=\"${MALIIT_KEYBOARD_LANGUAGES_DIR}\"")
target_compile_definitions(kcm_mobile_onscreenkeyboard PRIVATE "MALIIT_KEYBOARD_THEMES_DIR=\"${MALIIT_KEYBOARD_THEMES_DIR}\"")

target_link_libraries(kcm_mobile_onscreenkeyboard
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
    PkgConfig::GIO
    PkgConfig::GOBJECT
)

install(TARGETS kcm_mobile_onscreenkeyboard DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)

kpackage_install_package(package kcm_mobile_virtualkeyboard kcms)
