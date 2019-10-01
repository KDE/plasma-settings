# Install the packages, also make it known to the system

add_subdirectory(theme)
if (${KF5KDELibs4Support_FOUND})
    add_subdirectory(time)
endif()

# Power
add_subdirectory(powermanagement)

# Info
add_subdirectory(info)
