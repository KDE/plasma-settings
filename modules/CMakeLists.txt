# Install the packages, also make it known to the system

add_subdirectory(theme)
add_subdirectory(time)

# Power
# needs porting to C++ / QML KCM api or a rewrite
#add_subdirectory(powermanagement)

# Info
add_subdirectory(info)

# Cellular Network
add_subdirectory(cellularnetwork)

# Virtual Keyboard (maliit)
add_subdirectory(virtualkeyboard)

add_subdirectory(password)
