/*
 *   SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.kcm 1.2 as KCM
import QtQuick 2.7
import org.kde.kirigami 2.10 as Kirigami
import MeeGo.QOfono 0.2

KCM.SimpleKCM {

    property string modems: i18n("Modems")
    property string sims: i18n("SIM Cards")
    property string registrations: i18n("Networks")
    property string contexts: i18n("Access Points")
    property var entries: [ { name: modems, page: "Modems.qml", icon: "network-modem" } , { name: sims, page: "SimCards.qml", icon: "auth-sim-symbolic" }, { name: registrations, page: "Registrations.qml", icon: "" }, { name: contexts, page: "Contexts.qml", icon: "network-wireless-hotspot" } ]

    title: i18n("Cellular Networks")

    ListView {
        model: entries

        delegate: Kirigami.BasicListItem {
            label: modelData.name
            icon: modelData.icon

            onClicked: kcm.push(modelData.page)
        }
    }
}
