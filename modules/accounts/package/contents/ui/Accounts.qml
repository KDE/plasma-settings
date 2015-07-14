/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.active.settings 2.0 as ActiveSettings
import org.kde.kaccounts 1.0
import Ubuntu.OnlineAccounts 0.1 as OA

Item {
    id: kaccountsRoot
    objectName: "kaccountsModule"

    width: 800; height: 500

    StackView {
        id: mainView
        anchors.fill: parent

        initialItem: ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: units.smallSpacing

                model: OA.AccountServiceModel {
                    id: accountsModel
                    service: "global"
                    includeDisabled: true
                }

                delegate: RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: model.displayName

                        onClicked: {
                            mainView.push(availableServices)
                            servicesModel.accountId = model.accountId
                        }
                    }
                    PlasmaComponents.Button {
                        iconSource: "list-remove"
                        
                        OA.Account {
                            id: account
                            objectHandle: model.accountHandle
                        }

                        onClicked: {
                            account.remove();
                        }
                    }
                }
            }
            
            PlasmaComponents.Button {
                Layout.fillWidth: true
                text: "Add new Account"
                onClicked: mainView.push(availableAccounts)
            }
        }
    }

    Component {
        id: availableAccounts

        ColumnLayout {
            RowLayout {
                PlasmaComponents.Button {
                    text: "<"

                    onClicked: {
                        mainView.push(mainView.initialItem);
                    }
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Available Accounts"
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 3

                Repeater {
                    model: OA.ProviderModel {}

                    // We don't have a button that has text under icon _and_ looks like a button
                    // so this creates one
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: units.smallSpacing

                            PlasmaCore.IconItem {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                source: model.iconName
                            }

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter

                                text: model.displayName
                            }
                        }

                        Component {
                            id: jobComponent
                            CreateAccount {}
                        }

                        onClicked: {
                            var job = jobComponent.createObject(mainView, { providerName: providerId})
                            job.start()
                        }
                    }
                }
            }
        }
    }

    OA.AccountServiceModel {
        id: servicesModel
    }

    Component {
        id: availableServices

        ColumnLayout {
            RowLayout {
                Layout.maximumHeight: backButton.height
                PlasmaComponents.Button {
                    id: backButton
                    text: "<"

                    onClicked: {
                        mainView.push(mainView.initialItem);
                    }
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: "Available Services"
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: units.smallSpacing

                Repeater {
                    model: servicesModel

                    PlasmaComponents.CheckBox {
                        text: model.serviceName
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
