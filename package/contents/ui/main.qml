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

    property alias currentModule: moduleItem.module

    pageStack.initialPage: modulesList

    Connections {
        target: settingsApp
        onActivateRequested: rootItem.requestActivate();
        onModuleRequested: {
            pageStack.currentIndex = 0;
            rootItem.currentModule = module;
        }
    }
    onCurrentModuleChanged: {
        if (currentModule.length > 0) {
            pageStack.push(moduleItem);
        }
        pageStack.currentIndex = 1;
    }

    Component.onCompleted: {
        if (startModule.length > 0) {
            rootItem.currentModule = startModule;
        }
    }
    ModulesList {
        id: modulesList
    }

    ModuleItem {
        id: moduleItem
        visible: false
    }
}
