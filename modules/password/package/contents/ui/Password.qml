/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.10 as QQC2

import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.2

SimpleKCM {
    title: i18n("Change Lockscreen Pin")

    RegExpValidator {
        id: pinValidator
        regExp: /[0-9]+/
    }

    ColumnLayout {
        Kirigami.InlineMessage {
            type: Kirigami.MessageType.Information
            Layout.fillWidth: true
            text: i18n("Pin can only contain numbers")
            visible: !pin.acceptableInput && pin.text.length != 0
        }
        Kirigami.InlineMessage {
            type: Kirigami.MessageType.Warning
            Layout.fillWidth: true
            text: i18n("Pins do not match")
            visible: pin.text !== confirmPin.text
        }

        Kirigami.FormLayout {
            QQC2.TextField {
                id: pin
                Kirigami.FormData.label: i18n("New Pin:")
                echoMode: TextInput.PasswordEchoOnEdit
                validator: pinValidator
                inputMethodHints: Qt.ImhDigitsOnly
            }
            QQC2.TextField {
                id: confirmPin
                Kirigami.FormData.label: i18n("Confirm new Pin:")
                echoMode: TextInput.PasswordEchoOnEdit
                validator: pinValidator
                inputMethodHints: Qt.ImhDigitsOnly
            }
            QQC2.Button {
                text: i18n("Apply")
                enabled: pin.text === confirmPin.text && pin.acceptableInput
                onClicked: kcm.setPassword(pin.text)
            }
        }
    }
}

