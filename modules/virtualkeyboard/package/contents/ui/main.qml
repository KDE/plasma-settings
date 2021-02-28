/*
 *   SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kitemmodels 1.0 as KItemModel

KCM.SimpleKCM {
    id: root

    title: i18n("Virtual Keyboard")

    Kirigami.FormLayout {

        Item {
            Kirigami.FormData.label: i18n("Text correction:")
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            text: i18n("Check spelling of entered text")
            checked: kcm.spellCheck
            onCheckStateChanged: {
                kcm.spellCheck = checked;
            }
        }

        QQC2.CheckBox {
            text: i18n("Capitalize the first letter of each sentence")
            checked: kcm.autoCapitalize
            onCheckStateChanged: {
                kcm.autoCapitalize = checked;
            }
        }

        QQC2.CheckBox {
            text: i18n("Complete current word with first suggestion when hitting space")
            checked: kcm.autoCompleteOnSpace
            onCheckStateChanged: {
                kcm.autoCompleteOnSpace = checked;
            }
        }

        QQC2.CheckBox {
            text: i18n("Suggest potential words in word ribbon")
            checked: kcm.showSuggestions
            onCheckStateChanged: {
                kcm.showSuggestions = checked;
            }
        }

        QQC2.CheckBox {
            text: i18n("Insert a full-stop when space is pressed twice")
            checked: kcm.fullStopOnDoubleSpace
            onCheckStateChanged: {
                kcm.fullStopOnDoubleSpace = checked;
            }
        }

        Item {
            Kirigami.FormData.label: i18n("Feedback:")
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            text: i18n("Emit sound on key press")
            checked: kcm.soundFeedback
            onCheckStateChanged: {
                kcm.soundFeedback = checked;
            }
        }

        QQC2.CheckBox {
            text: i18n("Vibrate on key press")
            checked: kcm.vibrateFeedback
            onCheckStateChanged: {
                kcm.vibrateFeedback = checked;
            }
        }
        
        Item {
            Kirigami.FormData.label: i18n("Other:")
            Kirigami.FormData.isSection: true
        }
        
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Theme:")
            currentIndex: kcm.availableThemes.indexOf(kcm.theme)
            model: kcm.availableThemes
            onActivated: {
                kcm.theme = currentText;
            }
        }

        Item {
            Kirigami.FormData.label: i18n("Languages:")
            Kirigami.FormData.isSection: true
        }

        QQC2.Button {
            text: i18n("Configure Languages")
            onClicked: kcm.push("languages.qml")
            icon.name: "set-language"
        }
    }
}
