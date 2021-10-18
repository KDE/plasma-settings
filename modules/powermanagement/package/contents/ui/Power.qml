/*
    SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Controls 2.10 as QQC2
import QtQuick.Layouts 1.11

import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcm 1.2

SimpleKCM {
    id: powermanagementModule
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit

    Kirigami.FormLayout {
        id: mainItem

        QQC2.ComboBox {
            id: sleepCombo
            Kirigami.FormData.label: i18nc("Part of a sentence like 'Dim Display after 5 minutes'", "Dim Display")
            model: kcm.timeOptions()
            currentIndex: kcm.sleepScreenIdx
            onActivated: kcm.sleepScreenIdx = currentIndex
            onCurrentIndexChanged: print(currentIndex)
        }

        QQC2.ComboBox {
            id: suspendCombo
            Kirigami.FormData.label: i18nc("Part of a sentence like 'Suspend Session after 5 minutes'", "Suspend Session")
            model: kcm.timeOptions()
            currentIndex: kcm.suspendSessionIdx
            onActivated: kcm.suspendSessionIdx = currentIndex
            onCurrentIndexChanged: print(currentIndex)
        }
    }
}
