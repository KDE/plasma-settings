/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.Page {
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    
    ColumnLayout {
        spacing: Kirigami.Units.gridUnit
        anchors.centerIn: parent
        Kirigami.Icon {
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Kirigami.Units.iconSizes.enormous
            implicitHeight: Kirigami.Units.iconSizes.enormous
            source: "org.kde.mobile.plasmasettings"
        }
        Kirigami.Heading {
            Layout.alignment: Qt.AlignCenter
            level: 1
            text: i18n("System Settings")
            type: Kirigami.Heading.Type.Primary
        }
        Kirigami.Heading {
            Layout.alignment: Qt.AlignCenter
            level: 2
            text: i18n("Open a configuration page from the sidebar.")
            type: Kirigami.Heading.Type.Secondary
        }
    }
}
