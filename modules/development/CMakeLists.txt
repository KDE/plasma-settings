project(kcm_settings_devel)

set(developmentsettings_SRCS develsettingsplugin.cpp)

add_library(kcm_settings_devel MODULE ${developmentsettings_SRCS})

target_link_libraries(kcm_settings_devel
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
    KF5::Auth
    KF5::Plasma
)

install(TARGETS kcm_settings_devel DESTINATION ${PLUGIN_INSTALL_DIR})

install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.development)
install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.development.desktop)


########### helper ###############

add_executable(active-sshd-helper sshdhelper.cpp ${helper_mocs})
target_link_libraries(active-sshd-helper
    Qt5::Core
    KF5::Auth

)
install(TARGETS active-sshd-helper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})

kauth_install_helper_files(active-sshd-helper org.kde.active.sshdcontrol root)
kauth_install_actions(org.kde.active.sshdcontrol active_dev_sshd.actions)


add_executable(active-integration-helper integrationhelper.cpp ${helper_mocs})
target_link_libraries(active-integration-helper
    Qt5::Core
    KF5::Auth

)
install(TARGETS active-integration-helper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})

kauth_install_helper_files(active-integration-helper org.kde.active.integration root)
kauth_install_actions(org.kde.active.integration active_dev_integration.actions)
