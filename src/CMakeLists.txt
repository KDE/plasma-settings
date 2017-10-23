
# These are only needed here, consider porting away from both!
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Gui)

set(plasma-settings_SRCS
    main.cpp
)

add_executable(plasma-settings ${plasma-settings_SRCS})

target_link_libraries(plasma-settings
    Qt5::Quick
    Qt5::Gui
    KF5::Package
    KF5::DBusAddons
    KF5::Declarative
    KF5::I18n
    KF5::WindowSystem
)

install( TARGETS plasma-settings ${INSTALL_TARGETS_DEFAULT_ARGS} )
