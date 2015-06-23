# Install the packages, also make it known to the system


add_subdirectory(theme)
add_subdirectory(development)
if (${KF5KDELibs4Support_FOUND})
    add_subdirectory(time)
endif()
#add_subdirectory(locale)

# Web
#install(DIRECTORY web/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.web)
#install(FILES web/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.web.desktop)

#Power
add_subdirectory(powermanagement)

#install(DIRECTORY powermanagement/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.powermanagement)
#install(FILES powermanagement/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.powermanagement.desktop)

# ConfigTest
#install(DIRECTORY configtest/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.configtest)
#install(FILES configtest/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.configtest.desktop)
kpackage_install_package(configtest kcm_configtest kcms)

