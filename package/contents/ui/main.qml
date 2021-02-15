/***************************************************************************
 *                                                                         *
 *   Copyright 2017 Marco Martin <mart@kde.org>                            *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
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
            startupModuleTimer.restart()
        }
    }

    Timer {
        id: startupModuleTimer
        interval: 100
        onTriggered: openModule(SettingsApp.startModule)
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
