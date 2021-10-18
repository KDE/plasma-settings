/*

    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.8 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ScrollablePage {
    id: settingsRoot

    title: i18n("Settings")
    property alias currentIndex: listView.currentIndex

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
        currentIndex: -1 // no default highlight
    }
}
