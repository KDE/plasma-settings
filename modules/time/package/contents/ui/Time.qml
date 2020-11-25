// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls

import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.2
import org.kde.timesettings 1.0

SimpleKCM {
    id: timeModule

    Component {
        id: listDelegateComponent

        Kirigami.BasicListItem {
            text: {
                if (model) {
                    if (model.region) {
                        return "%1 / %2".arg(model.region).arg(model.city)
                    } else {
                        return model.city
                    }
                }
                return ""
            }
            onClicked: {
                timeZonePickerSheet.close()
                kcm.saveTimeZone(model.timeZoneId)
            }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 0
        id: formLayout

        Kirigami.ListSectionHeader {
            label: i18n("Time Display")
        }

        Kirigami.BasicListItem {
            label: i18n("Use 24-hour clock:")
            icon: "clock"
            onClicked: {
                twentyFourSwitch.checked = !twentyFourSwitch.checked
                twentyFourSwitch.clicked()
            }
            Controls.Switch {
                id: twentyFourSwitch
                checked: kcm.twentyFour
                onClicked: {
                    kcm.twentyFour = checked
                    print(kcm.timeZone);
                }
            }
        }

        Kirigami.BasicListItem {
            label: "Timezone:"
            onClicked: timeZonePickerSheet.open()
            Controls.Label {
                id: timeZoneButton
                text: kcm.timeZone
            }
        }

        Kirigami.ListSectionHeader {
            label: i18n("Set Time and Date")
        }

        Kirigami.BasicListItem {
            label: i18n("Set time automatically:")
            onClicked: {
                ntpCheckBox.checked = !ntpCheckBox.checked
                ntpCheckBox.clicked()
            }

            Controls.Switch {
                id: ntpCheckBox
                checked: kcm.useNtp
                onClicked: {
                    kcm.useNtp = checked;
                    if (!checked) {
                        kcm.ntpServer = ""
                        kcm.saveTime()
                    }
                }
            }
        }

        Kirigami.BasicListItem {
            label: i18n("Time")
            icon: "clock"
            onClicked: timePickerSheet.open()
            Controls.Label {
                text: {
                    Qt.formatTime(kcm.currentTime)
                }
            }
        }

        Kirigami.BasicListItem {
            label: i18n("Date")
            icon: "view-calendar"
            onClicked: datePickerSheet.open()

            Controls.Label {
                text: {
                    Qt.formatDate(kcm.currentDate);
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: timeZonePickerSheet
        header: ColumnLayout {
            Kirigami.Heading {
                text: i18nc("@title:window", "Pick Timezone")
            }
            Kirigami.SearchField {
                Layout.fillWidth: true
                width: parent.width
                onTextChanged: {
                    kcm.timeZonesModel.filterString = text
                }
            }
        }

        footer: RowLayout {
            Controls.Button {
                Layout.alignment: Qt.AlignHCenter

                text: i18nc("@action:button", "Close")

                onClicked: timeZonePickerSheet.close()
            }
        }
        ListView {
            clip: true
            anchors.fill: parent
            implicitWidth: 18 * Kirigami.Units.gridUnit
            model: kcm.timeZonesModel
            delegate: Kirigami.DelegateRecycler {
                width: parent.width

                sourceComponent: listDelegateComponent
            }
        }
    }

    Kirigami.OverlaySheet {
        id: timePickerSheet
        header:  Kirigami.Heading { text: i18n("Pick Time") }
        TimePicker {
            id: timePicker
            enabled: !ntpCheckBox.checked
            twentyFour: twentyFourSwitch.checked

            implicitWidth: width > Kirigami.Units.gridUnit * 15 ? width : Kirigami.Units.gridUnit * 15

            Component.onCompleted: {
                var date = new Date(kcm.currentTime);
                timePicker.hours = date.getHours();
                timePicker.minutes = date.getMinutes();
                timePicker.seconds = date.getSeconds();
            }
            Connections {
                target: kcm
                onCurrentTimeChanged: {
                    if (timePicker.userConfiguring) {
                        return;
                    }

                    var date = new Date(kcm.currentTime);
                    timePicker.hours = date.getHours();
                    timePicker.minutes = date.getMinutes();
                    timePicker.seconds = date.getSeconds();
                }
            }
            onUserConfiguringChanged: {
                kcm.currentTime = timeString
                kcm.saveTime()
            }
        }
        footer: RowLayout {
            Controls.Button {
                Layout.alignment: Qt.AlignRight

                text: i18nc("@action:button", "Close")

                onClicked: timePickerSheet.close()
            }
        }
    }

    Kirigami.OverlaySheet {
        id: datePickerSheet
        header: Kirigami.Heading { text: i18n("Pick Date") }
        DatePicker {
            id: datePicker
            enabled: !ntpCheckBox.checked

            implicitWidth: width > Kirigami.Units.gridUnit * 15 ? width : Kirigami.Units.gridUnit * 15

            Component.onCompleted: {
                var date = new Date(kcm.currentDate)
                datePicker.day = date.getDate()
                datePicker.month = date.getMonth()+1
                datePicker.year = date.getFullYear()
            }
            Connections {
                target: kcm
                onCurrentDateChanged: {
                    if (datePicker.userConfiguring) {
                        return
                    }

                    var date = new Date(kcm.currentDate)

                    datePicker.day = date.getDate()
                    datePicker.month = date.getMonth()+1
                    datePicker.year = date.getFullYear()
                }
            }
            onUserConfiguringChanged: {
                kcm.currentDate = isoDate
                kcm.saveTime()
            }
        }
        footer: RowLayout {
            Controls.Button {
                Layout.alignment: Qt.AlignRight

                text: i18nc("@action:button", "Close")

                onClicked: datePickerSheet.close()
            }
        }
    }
}
