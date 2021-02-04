# Install the packages, also make it known to the system

add_subdirectory(time)

# Power
# The port to C++ is happening, this is just
# a quick and dirty hack so we have this fast
# while the real powermanagement is being rewritten for plasma 5.22
add_subdirectory(powermanagement)

# Info
add_subdirectory(info)

# Cellular Network
add_subdirectory(cellularnetwork)

# Virtual Keyboard (maliit)
add_subdirectory(virtualkeyboard)

add_subdirectory(password)
