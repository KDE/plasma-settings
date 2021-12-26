set(info_SRCS # Specify source files for the library
    info.cpp
    distroinfo.cpp
    softwareinfo.cpp
    hardwareinfo.cpp
)

add_library(kcm_mobile_info MODULE ${info_SRCS})

target_link_libraries(kcm_mobile_info
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
    KF5::Solid
)

install(TARGETS kcm_mobile_info DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms) # Install the library to the kcm location

kpackage_install_package(package kcm_mobile_info kcms) # Finally install our QML kpackage.

