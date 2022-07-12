/*
 * SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

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
        
        Column {
            width: listView.width
            
            MobileForm.FormDelegateSeparator {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                visible: model.index !== 0
                above: listView.children[model.index]
                below: delegateItem
            }
            
            MobileForm.AbstractFormDelegate {
                id: delegateItem
                property string name: model.name
                property string description: model.description
                property string iconName: model.iconName ? model.iconName : "question"
                
                onClicked: {
                    print("Clicked index: " + index + " current: " + listView.currentIndex + " " + name + " curr: " + rootItem.currentModule);
                    // Only the first main page has a kcm property
                    applicationWindow().openModule(model.id);
                }
                
                width: listView.width
                contentItem: RowLayout {
                    Kirigami.Icon {
                        source: delegateItem.iconName
                        Layout.rightMargin: Kirigami.Units.largeSpacing
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        
                        Controls.Label {
                            Layout.fillWidth: true
                            text: delegateItem.name
                            elide: Text.ElideRight
                        }
                        
                        Controls.Label {
                            Layout.fillWidth: true
                            text: delegateItem.description
                            color: Kirigami.Theme.disabledTextColor
                            font: Kirigami.Theme.smallFont
                            elide: Text.ElideRight
                        }
                    }
                    
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignRight
                        source: "arrow-right"
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                    }
                }
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
