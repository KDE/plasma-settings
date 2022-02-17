/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kitemmodels 1.0 as KItemModel

KCM.SimpleKCM {
    id: root

    title: i18n("On-Screen Keyboard")

    leftPadding: Kirigami.Units.largeSpacing 
    rightPadding: Kirigami.Units.largeSpacing 
    
    Kirigami.FormLayout {
        id: form
        wideMode: false
        
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Test keyboard:")
            placeholderText: i18n("Type anything here…")
        }
        
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Theme:")
            currentIndex: kcm.availableThemes.indexOf(kcm.theme)
            model: kcm.availableThemes
            onActivated: {
                kcm.theme = currentText
            }
        }
        
        WrappingCheckBox {
            Kirigami.FormData.label: i18n("Feedback:")
            Kirigami.FormData.buddyFor: firstFeedbackCheckBox
            Layout.maximumWidth: form.width
            id: firstFeedbackCheckBox
            text: i18n("Emit sound on key press")
            checked: kcm.soundFeedback
            onCheckStateChanged: {
                kcm.soundFeedback = checked;
            }
        }

        WrappingCheckBox {
            Layout.maximumWidth: form.width
            text: i18n("Vibrate on key press")
            checked: kcm.vibrateFeedback
            onCheckStateChanged: {
                kcm.vibrateFeedback = checked;
            }
        }
        
        WrappingCheckBox {
            Kirigami.FormData.label: i18n("Text correction:")
            Kirigami.FormData.buddyFor: firstTextCorrectionCheckBox
            Layout.maximumWidth: form.width
            id: firstTextCorrectionCheckBox
            text: i18n("Check spelling of entered text")
            checked: kcm.spellCheck
            onCheckStateChanged: kcm.spellCheck = checked;
        }

        WrappingCheckBox {
            Layout.maximumWidth: form.width
            text: i18n("Capitalize the first letter of each sentence")
            checked: kcm.autoCapitalize
            onCheckStateChanged: kcm.autoCapitalize = checked;
        }

        WrappingCheckBox {
            Layout.maximumWidth: form.width
            text: i18n("Complete current word with first suggestion when hitting space")
            checked: kcm.autoCompleteOnSpace
            onCheckStateChanged: kcm.autoCompleteOnSpace = checked;
        }

        WrappingCheckBox {
            Layout.maximumWidth: form.width
            text: i18n("Suggest potential words in word ribbon")
            checked: kcm.showSuggestions
            onCheckStateChanged: {
                kcm.showSuggestions = checked;
            }
        }

        WrappingCheckBox {
            Layout.maximumWidth: form.width
            text: i18n("Insert a full-stop when space is pressed twice")
            checked: kcm.fullStopOnDoubleSpace
            onCheckStateChanged: {
                kcm.fullStopOnDoubleSpace = checked;
            }
        }

        QQC2.Button {
            Kirigami.FormData.label: i18n("Languages:")
            text: i18n("Configure Languages")
            onClicked: kcm.push("languages.qml")
            icon.name: "set-language"
        }
    }
}
