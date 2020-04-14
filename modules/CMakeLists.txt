# Install the packages, also make it known to the system

add_subdirectory(theme)
if (${KF5KDELibs4Support_FOUND})
    add_subdirectory(time)
endif()

# Power
# needs porting to C++ / QML KCM api or a rewrite
#add_subdirectory(powermanagement)

# Info
add_subdirectory(info)

# Cellular Network
add_subdirectory(cellularnetwork)
