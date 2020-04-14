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
