set(themesettings_SRCS
    themesettings.cpp
    themelistmodel.cpp
)


add_library(kcm_mobile_theme MODULE ${themesettings_SRCS})

target_link_libraries(kcm_mobile_theme
    Qt5::DBus
    Qt5::Gui
    Qt5::Quick
    Qt5::Qml
    KF5::Plasma
    KF5::I18n
    KF5::QuickAddons
    )
kcoreaddons_desktop_to_json(kcm_mobile_theme "themesettings.desktop")

# Time and Date

install(FILES themesettings.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
install(TARGETS kcm_mobile_theme DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_mobile_theme kcms)
