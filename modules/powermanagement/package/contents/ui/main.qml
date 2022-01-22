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
        wideMode: false

        QQC2.ComboBox {
            id: dimScreenCombo
            Kirigami.FormData.label: i18nc("Part of a sentence like 'Dim screen after 5 minutes'", "Dim screen after:")
            model: kcm.timeOptions()
            currentIndex: kcm.dimScreenIdx
            onActivated: kcm.dimScreenIdx = currentIndex
            onCurrentIndexChanged: print(currentIndex)
        }
        
        QQC2.ComboBox {
            id: screenOffCombo
            Kirigami.FormData.label: i18nc("Part of a sentence like 'Turn off screen after 5 minutes'", "Turn off screen after:")
            model: kcm.timeOptions()
            currentIndex: kcm.screenOffIdx
            onActivated: kcm.screenOffIdx = currentIndex
            onCurrentIndexChanged: print(currentIndex)
        }

        QQC2.ComboBox {
            id: suspendCombo
            Kirigami.FormData.label: i18nc("Part of a sentence like 'Suspend device after 5 minutes'", "Suspend device after:")
            model: kcm.timeOptions()
            currentIndex: kcm.suspendSessionIdx
            onActivated: kcm.suspendSessionIdx = currentIndex
            onCurrentIndexChanged: print(currentIndex)
        }
    }
}
