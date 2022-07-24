set(kcm_password_SRCS password.cpp)

set_source_files_properties(org.freedesktop.Accounts.xml
                        PROPERTIES NO_NAMESPACE TRUE)

set_source_files_properties(org.freedesktop.Accounts.User.xml
                        PROPERTIES NO_NAMESPACE TRUE)

qt_add_dbus_interface(kcm_password_SRCS
    org.freedesktop.Accounts.User.xml
    user_interface
)

qt_add_dbus_interface(kcm_password_SRCS
    org.freedesktop.Accounts.xml
    accounts_interface
)

add_library(kcm_password MODULE ${kcm_password_SRCS})

target_link_libraries(kcm_password
    Qt::Gui
    Qt::Qml
    Qt::DBus
    KF5::CoreAddons
    KF5::QuickAddons
    KF5::I18n
    crypt
    )

install(TARGETS kcm_password DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
kpackage_install_package(package kcm_password kcms)
