/*
 *   Copyright 2015 Martin Klapetek <mklapetek@kde.org>
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



import QtQuick 2.7
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.0 as Controls

import org.kde.kirigami 2.4 as Kirigami

import org.kde.active.settings 2.0 as ActiveSettings
import org.kde.kaccounts 1.0
import org.kde.kcm 1.2

import Ubuntu.OnlineAccounts 0.1 as OA

SimpleKCM {
    id: kaccountsRoot
    objectName: "kaccountsModule"

    // Existing accounts
    ListView {
        clip: true
        model: OA.AccountServiceModel {
            id: accountsModel
            service: "global"
            includeDisabled: true
        }

        delegate: Kirigami.SwipeListItem {
            Controls.Label {
                text: model.displayName + " (" + providerName + ")"

                OA.Account {
                    id: account
                    objectHandle: model.accountHandle
                }
            }
            actions: [
                Kirigami.Action {
                    iconName: "bookmark-remove"
                    onTriggered: {
                        account.remove()
                    }
                }
            ]
            onClicked: {
                availableServicesSheet.open()
                servicesModel.accountId = model.accountId
            }
        }
    }

    footer: RowLayout {
        Controls.Button {
            Layout.alignment: Qt.AlignRight
            text: i18n("Add new Account")
            icon.name: "contact-new"
            onClicked: {
                availableAccountsSheet.open()
            }
        }
    }

    Kirigami.OverlaySheet {
        id: availableAccountsSheet
        parent: kaccountsRoot.parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: OA.ProviderModel {}

            delegate: Kirigami.BasicListItem {
                icon: model.iconName
                label: model.displayName
                Layout.fillWidth: true

                onClicked: {
                    var job = jobComponent.createObject(kaccountsRoot, { "providerName": providerId })
                    job.start()
                }
            }
        }
        Component {
            id: jobComponent
            CreateAccount {
                onFinished: {
                    availableAccountsSheet.close()
                }
            }
        }
    }

    OA.AccountServiceModel {
        id: servicesModel
    }

    Kirigami.OverlaySheet {
        id: availableServicesSheet
        parent: kaccountsRoot.parent

        ColumnLayout {
            Kirigami.Heading {
                Layout.fillWidth: true
                text: i18n("Available Services")
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    Layout.fillWidth: true
                    model: servicesModel

                    Controls.CheckDelegate {
                        Layout.fillWidth: true
                        text: model.serviceName
                        checked: model.enabled
                    }
                }
            }
        }
    }
}
