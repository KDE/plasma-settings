/*
 * SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.19 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ScrollablePage {
    id: settingsRoot

    title: i18n("Settings")
    
    property alias model: listView.model

    mainAction: Kirigami.Action {
        id: searchAction
        text: i18n("Search")
        iconName: "search"
        shortcut: "Ctrl+F"
        
        checkable: true
        onCheckedChanged: {
            if (!checked) {
                settingsRoot.model.filterString = "";
            }
        }
    }
    
    
    Component {
        id: settingsModuleDelegate
        Kirigami.BasicListItem {
            id: delegateItem

            icon: model.iconName ? model.iconName : "question"
            iconSize: Kirigami.Units.iconSizes.medium
            text: model.name
            subtitle: model.description
            checked: listView.currentIndex == index && !rootItem.compactMode

            onClicked: {
                print("Clicked index: " + index + " current: " + listView.currentIndex + " " + name + " curr: " + rootItem.currentModule);
                // Only the first main page has a kcm property
                applicationWindow().openModule(model.id);
            }
        }
    }

    // This is pretty much a placeholder of what will be the sandboxing mechanism: this element will be a wayland compositor that will contain off-process kcm pages
    Component {
        id: kcmContainer

        KCMContainer {}
    }

    // search bar
    header: HeaderSearchBar {
        model: settingsRoot.model
        show: searchAction.checked
    }
    
    ListView {
        id: listView
        focus: true
        activeFocusOnTab: true
        keyNavigationEnabled: true
        delegate: settingsModuleDelegate
        currentIndex: -1 // no default highlight
    }
}
