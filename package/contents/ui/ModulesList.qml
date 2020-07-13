/***************************************************************************
 *                                                                         *
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

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.8 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ScrollablePage {
    id: settingsRoot

    title: i18n("Settings")
    property alias currentIndex: listView.currentIndex

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    Component {
        id: settingsModuleDelegate
        Kirigami.BasicListItem {
            id: delegateItem

            icon: model.iconName
            iconSize: Kirigami.Units.iconSizes.medium
            text: model.name
            subtitle: model.description
            checked: listView.currentIndex == index && !rootItem.compactMode

            onClicked: {
                print("Clicked index: " + index + " current: " + listView.currentIndex + " " + name + " curr: " + rootItem.currentModule);
                // Only the first main page has a kcm property
                pageStack.push(kcmContainer.createObject(pageStack, {"kcm": model.kcm, "internalPage": model.kcm.mainUi}));
            }
        }
    }

    // This is pretty much a placeholder of what will be the sandboxing mechanism: this element will be a wayland compositor that will contain off-process kcm pages
    Component {
        id: kcmContainer

        KCMContainer {}
    }

    ListView {
        id: listView
        focus: true
        activeFocusOnTab: true
        keyNavigationEnabled: true
        model: ModulesModel{}
        delegate: settingsModuleDelegate
    }
}
