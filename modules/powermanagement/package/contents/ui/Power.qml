/*
 *   SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
 *   SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
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
            id: lockCombo
            Kirigami.FormData.label: i18nc("Part of a sentence like 'Lock screen and sleep after 5 minutes'", "Lock Screen and Sleep")
            model: kcm.timeOptions()
            currentIndex: kcm.lockScreenIdx
            onActivated: kcm.lockScreenIdx = currentIndex
        }

        QQC2.ComboBox {
            id: sleepCombo
            Kirigami.FormData.label: i18n("Part of a sentence like 'Turn off the Screen after 5 minutes'", "Turn off the Screen")
            model: kcm.timeOptions()
            currentIndex: kcm.sleepScreenIdx
            onActivated: kcm.sleepScreenIdx = currentIndex
        }
    }
}
