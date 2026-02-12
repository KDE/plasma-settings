# SPDX-FileCopyrightText: 2025 Carl Schwan <carlschwan@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

add_executable(plasma-settings
    main.cpp
    settingsapp.cpp settingsapp.h
    modulesmodel.cpp modulesmodel.h
    modulesproxymodel.cpp modulesproxymodel.h
    module.cpp module.h
    menuitem.cpp menuitem.h
)

ecm_add_qml_module(plasma-settings GENERATE_PLUGIN_SOURCE URI org.kde.plasma.settings)

qt_target_qml_sources(plasma-settings
    QML_FILES
        qml/DefaultPage.qml
        qml/KCMContainer.qml
        qml/KCMPageContainer.qml
        qml/Sidebar.qml
        qml/SidebarCategoriesPage.qml
        qml/SidebarDelegate.qml
        qml/SidebarSubCategoryPage.qml
        qml/Main.qml
        qml/components/PageContainer.qml
        qml/components/PageHeader.qml
        qml/components/PageStack.qml
)

target_include_directories(plasma-settings PRIVATE ${CMAKE_BINARY_DIR})

target_link_libraries(plasma-settings PRIVATE
    Qt::Quick
    Qt::QuickControls2
    Qt::Gui
    Qt::Widgets
    KF6::DBusAddons
    KF6::KCMUtilsQuick
    KF6::I18n
    KF6::Crash
    KF6::Service
    KF6::ItemViews
    KF6::ItemModels
    KF6::I18nQml
)

install(TARGETS plasma-settings ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
