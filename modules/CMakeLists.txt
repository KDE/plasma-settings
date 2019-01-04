# Install the packages, also make it known to the system

add_subdirectory(theme)
add_subdirectory(development)
if (${KF5KDELibs4Support_FOUND})
    add_subdirectory(time)
endif()

# Web
#install(DIRECTORY web/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.web)
#install(FILES web/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.web.desktop)

# Power
add_subdirectory(powermanagement)

# Accounts
if (KAccounts_FOUND AND AccountsQt5_FOUND AND SignOnQt5_FOUND)
    add_subdirectory(accounts)
endif()
