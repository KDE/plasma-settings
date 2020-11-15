set(kcm_password_SRCS password.cpp)

set_source_files_properties(org.freedesktop.Accounts.xml
                        PROPERTIES NO_NAMESPACE TRUE)

set_source_files_properties(org.freedesktop.Accounts.User.xml
                        PROPERTIES NO_NAMESPACE TRUE)

qt5_add_dbus_interface(kcm_password_SRCS
    org.freedesktop.Accounts.User.xml
    user_interface
)

qt5_add_dbus_interface(kcm_password_SRCS
    org.freedesktop.Accounts.xml
    accounts_interface
)

add_library(kcm_password MODULE ${kcm_password_SRCS})

target_link_libraries(kcm_password
    Qt5::Gui
    Qt5::Qml
    Qt5::DBus
    KF5::CoreAddons
    KF5::QuickAddons
    KF5::I18n
    crypt
    )
kcoreaddons_desktop_to_json(kcm_password "package/metadata.desktop")

install(FILES package/metadata.desktop RENAME kcm_password.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})
install(TARGETS kcm_password DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_password kcms)
