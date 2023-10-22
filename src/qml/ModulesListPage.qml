/*
 * SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard

import org.kde.plasma.settings 0.1

Kirigami.ScrollablePage {
    id: settingsRoot

    title: i18n("Settings")
    
    property alias model: repeater.model
    
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false
            
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    
    Component {
        id: settingsModuleDelegate
        
        Column {
            Layout.fillWidth: true
            
            FormCard.FormDelegateSeparator {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                visible: model.index !== 0
                above: settingsCard.children[model.index]
                below: delegateItem
            }
            
            FormCard.AbstractFormDelegate {
                id: delegateItem
                width: parent.width
                property string name: model.name
                property string description: model.description
                property string iconName: model.iconName ? model.iconName : "question"
                
                onClicked: {
                    // Only the first main page has a kcm property
                    applicationWindow().openModule(model.id);
                }
                
                // width: cardColumn.width

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
                        implicitWidth: Math.round(Kirigami.Units.iconSizes.small * 0.75)
                        implicitHeight: Math.round(Kirigami.Units.iconSizes.small * 0.75)
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

    ColumnLayout {
        spacing: 0
        width: settingsRoot.width
        
        // search bar
        FormCard.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            FormCard.AbstractFormDelegate {
                Layout.fillWidth: true
                background: Item {}

                contentItem: RowLayout {
                    Kirigami.SearchField {
                        id: searchField
                        Layout.fillWidth: true
                        autoAccept: true
                        onAccepted: settingsRoot.model.filterString = searchField.text
                    }
                }
            }
        }

        FormCard.FormHeader {
            title: i18n("Settings")
        }
        
        // settings categories
        FormCard.FormCard {
            id: settingsCard
            Repeater {
                id: repeater
                delegate: settingsModuleDelegate
            }
        }
    }
}
