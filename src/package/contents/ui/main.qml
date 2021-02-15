/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>                            *
 *   SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 ***************************************************************************/

import QtQuick 2.6
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ApplicationWindow {
    id: rootItem

    pageStack.initialPage: SettingsApp.singleModule ? null : modulesList
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.Breadcrumb

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    function openModule(moduleName) {
        module.name = moduleName
        while (pageStack.depth > 1) {
            pageStack.pop()
        }

        pageStack.push(kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi}));
    }

    Component.onCompleted: {
        if (SettingsApp.startModule.length > 0) {
            openModule(SettingsApp.startModule)
        }
    }

    Connections {
        target: SettingsApp
        onModuleRequested: {
            openModule(moduleName)
        }
    }

    Module {
        id: module
    }

    ModulesList {
        id: modulesList
    }

    Component {
        id: kcmContainer

        KCMContainer {}
    }
}
