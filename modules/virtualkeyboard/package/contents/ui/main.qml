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

KCM.SimpleKCM {
    id: root

    title: i18n("Virtual Keyboard")

    Kirigami.FormLayout {
        Layout.fillHeight: true
        anchors.margins: Kirigami.Units.largeSpacing

        QQC2.Label {
            text: i18n("Text correction:")
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
            Layout.preferredHeight: Kirigami.Units.gridUnit
        }

        QQC2.Label {
            text: i18n("Feedback:")
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
            Layout.preferredHeight: Kirigami.Units.gridUnit
        }

        QQC2.Label {
            text: i18n("Keyboard Languages:")
        }

        QQC2.ScrollView {
            id: bgObject
            Component.onCompleted: bgObject.background.visible = true
            Layout.fillWidth: true

            ListView {
                id: languageList

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
        }
    }
}
