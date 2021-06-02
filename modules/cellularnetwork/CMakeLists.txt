add_library(kcm_mobile_cellularnetwork MODULE cellularnetwork.cpp)

target_link_libraries(kcm_mobile_cellularnetwork
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
)

kcoreaddons_desktop_to_json(kcm_mobile_cellularnetwork "cellularnetwork.desktop") # Convert our desktop file to json

install(TARGETS kcm_mobile_cellularnetwork DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms) # Install the library to the kcm location

install(FILES cellularnetwork.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR}) # Install the desktop file
kpackage_install_package(package kcm_mobile_cellularnetwork kcms) # Finally install our QML kpackage.

