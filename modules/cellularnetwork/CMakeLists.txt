set (cellularnetworksettings_SRCS 
    cellularnetworksettings.cpp 
    modem.cpp
    modemdetails.cpp
    sim.cpp
    mobileproviders.cpp
    profilesettings.cpp
)

add_library(kcm_cellular_network MODULE ${cellularnetworksettings_SRCS})

target_link_libraries(kcm_cellular_network
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Qt::Qml
    Qt::Xml
    KF5::Plasma
    KF5::I18n
    KF5::NetworkManagerQt
    KF5::ModemManagerQt
    KF5::QuickAddons
)

install(TARGETS kcm_cellular_network DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_cellular_network kcms)
