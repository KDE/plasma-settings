/*
 *   Copyright 2020 Bhushan Shah <bshah@kde.org>
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kitemmodels 1.0 as KItemModel

KCM.ScrollViewKCM {
    id: root

    title: i18n("Languages")

    view: ListView {
        id: languageList

        clip: true

        model: KItemModel.KSortFilterProxyModel {
            sourceModel: kcm.languageModel
            sortRole: "name"
            sortOrder: Qt.Ascending
        }

        delegate: QQC2.CheckDelegate {
            text: model.name
            width: languageList.width
            checked: model.enabled
            onCheckedChanged: {
                model.enabled = checked
            }
        }
    }

    footer: RowLayout {
        QQC2.Button {
            text: i18n("Apply")
            icon.name: "dialog-ok"
            onClicked: kcm.pop()
            Layout.alignment: Qt.AlignRight
        }
    }
}
