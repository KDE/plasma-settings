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

import org.kde.kcm 1.2 as KCM
import QtQuick 2.7
import QtQuick.Layouts 1.1

import QtQuick.Controls 2.14 as Controls
import org.kde.kirigami 2.10 as Kirigami

KCM.SimpleKCM {

    title: i18n("Virtual Keyboard")
    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.gridUnit * 0.5

        Repeater {
            model: kcm.languageModel
            delegate: Controls.CheckDelegate {
                Layout.fillWidth: true
                text: model.name
                checked: model.enabled
                onCheckedChanged: {
                    model.enabled = checked
                }
            }
        }
    }
}
