set(accountsettings_SRCS
    accounts.cpp
)

add_library(kcm_mobile_kaccounts MODULE ${accountsettings_SRCS})

target_link_libraries(kcm_mobile_kaccounts
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    )
kcoreaddons_desktop_to_json(kcm_mobile_kaccounts "accountssettings.desktop")

install(TARGETS kcm_mobile_kaccounts DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)

install(FILES accountssettings.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
kpackage_install_package(package kcm_mobile_kaccounts kcms)
