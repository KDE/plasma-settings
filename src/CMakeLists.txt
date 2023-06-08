set(plasma-settings_SRCS
    main.cpp
    settingsapp.cpp
    modulesmodel.cpp
    modulesproxymodel.cpp
    module.cpp
    resources.qrc
)

add_executable(plasma-settings ${plasma-settings_SRCS})

target_include_directories(plasma-settings PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(plasma-settings
    Qt::Quick
    Qt::Gui
    Qt::Widgets
    KF6::DBusAddons
    KF6::KCMUtilsQuick
    KF6::I18n
)

install(TARGETS plasma-settings ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
