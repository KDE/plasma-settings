/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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

import org.kde.kcm 1.2 as KCM
import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.10 as Kirigami
import MeeGo.QOfono 0.2

KCM.SimpleKCM {
    title: i18n("Access Points")

    OfonoManager {
        id: ofonoManager
    }

    ListView {
        width: parent.width
        model: ofonoManager.modems.length
        delegate: ColumnLayout {
            property int modemId: model.index

            width: parent.width

            Repeater {
                Layout.fillWidth: true
                model: ofonoConnManager.contexts.length
                delegate: Kirigami.AbstractCard {
                    property int contextId: model.index

                    Layout.fillWidth: true
                    visible: context.accessPointName != ""

                    header: Kirigami.Heading {
                        text: context.name
                        level: 2
                        horizontalAlignment: Text.AlignHCenter
                    }

                    contentItem: Kirigami.FormLayout {
                        Layout.fillWidth: true

                        RowLayout {
                            Layout.fillWidth: true
                            Kirigami.FormData.label: i18n("Active:")

                            Controls.CheckBox {
                                enabled: false
                                checked: context.active
                            }
                        }

                        Controls.Label {
                            visible: context.protocol != ""
                            wrapMode: Text.WordWrap
                            text: context.protocol
                            Kirigami.FormData.label: i18n("Protocol:")
                            Layout.fillWidth: true
                        }

                        Controls.Label {
                            visible: context.type != ""
                            wrapMode: Text.WordWrap
                            text: context.type
                            Kirigami.FormData.label: i18n("Type:")
                            Layout.fillWidth: true
                        }


                        Controls.Label {
                            visible: context.accessPointName != ""
                            wrapMode: Text.WordWrap
                            text: context.accessPointName
                            Kirigami.FormData.label: i18n("APN:")
                            Layout.fillWidth: true
                        }

                    }

                    OfonoContextConnection {
                        id: context

                        contextPath: ofonoConnManager.contexts[contextId]
                    }
                }
            }
            OfonoConnMan {
                id: ofonoConnManager

                modemPath: ofonoManager.modems[modemId]
            }
        }
    }
}
