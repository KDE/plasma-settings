/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.5 

import org.kde.kirigami 2.19 as Kirigami

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
            source: "applications-system"
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
