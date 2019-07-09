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

import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.2 as Kirigami
import org.kde.active.settings 2.0 as ActiveSettings

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
        Kirigami.AbstractListItem {
            id: delegateItem

            enabled: true
            checked: listView.currentIndex == index && !rootItem.compactMode
            leftPadding: Kirigami.Units.largeSpacing
            RowLayout {
                id: bah
                spacing: Kirigami.Units.largeSpacing
                Kirigami.Icon {
                    id: iconItem
                    selected: delegateItem.down
                    Layout.maximumWidth: Layout.preferredWidth
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Layout.preferredWidth
                    source: iconName
                }
                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    Controls.Label {
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        text: name
                    }
                    Controls.Label {
                        text: description
                        Layout.fillWidth: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize -1
                        opacity: 0.6
                        elide: Text.ElideRight
                    }
                }
                Connections {
                    target: settingsApp
                    onModuleRequested: {
                        if (rootItem.currentModule == model.module) {
                            listView.currentIndex = index;
                        }
                    }
                }
            }

            onClicked: {
                print("Clicked ndex: " + index + " current: " + listView.currentIndex + " " + name + " curr: " + rootItem.currentModule);
                pageStack.push(mainUi, {})
            }
        }
    }

    ListView {
        id: listView
        model: ModulesModel{}
        delegate: settingsModuleDelegate
    }
}
