project( kcm_mobile_theme )


set(themesettings_SRCS
    themesettings.cpp
)


add_library(kcm_mobile_theme MODULE ${themesettings_SRCS})

target_link_libraries(kcm_mobile_theme
    Qt5::Quick
    Qt5::Qml
    KF5::Plasma
    KF5::I18n
    KF5::QuickAddons
    )
kcoreaddons_desktop_to_json(kcm_mobile_theme "themesettings.desktop")

# Time and Date

install(FILES themesettings.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(TARGETS kcm_mobile_theme DESTINATION ${PLUGIN_INSTALL_DIR}/kcms)
kpackage_install_package(package kcm_mobile_theme kcms)
