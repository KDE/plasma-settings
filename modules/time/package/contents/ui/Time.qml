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

import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcm 1.2

SimpleKCM {
    id: timeModule
    objectName: "timeModule"

    ColumnLayout {
        width: parent.width
        spacing: 0
        id: formLayout

        Kirigami.Heading {
            leftPadding: Kirigami.Units.smallSpacing
            text: i18n("Time Display")
            level: 3
        }

        Kirigami.BasicListItem {
            label: i18n("Use 24-hour clock:")
            icon: "clock"
            Controls.Switch {
                id: twentyFourSwitch
                checked: kcm.twentyFour
                onClicked : {
                    kcm.twentyFour = checked
                    print(kcm.timeZone);
                }
            }
        }

        Kirigami.BasicListItem {
            label: "Timezone:"
            Controls.ToolButton {
                id: timeZoneButton
                text: kcm.timeZone
                onClicked: timeZonePickerDialog.open()
            }
        }

        Kirigami.Heading {
            leftPadding: Kirigami.Units.smallSpacing
            text: i18n("Set Time and Date")
            level: 3
        }

        Kirigami.BasicListItem {
            label: i18n("Set time automatically:")
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
            Controls.ToolButton {
                text: {
                    var date = new Date(kcm.currentTime);
                    return date.toTimeString()
                }
                onClicked: timePickerDialog.open()
            }
        }

        Kirigami.BasicListItem {
            label: i18n("Date")
            icon: "view-calendar"
            Controls.ToolButton {
                text: {
                    var date = new Date(kcm.currentDate);
                    return date.toDateString()
                }
                onClicked: datePickerDialog.open()
            }
        }
    }

    Controls.Dialog {
        id: timeZonePickerDialog
        title: i18n("Pick Timezone... (%1)", kcm.timeZone)
        modal: true
        standardButtons: Controls.Dialog.Ok
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: close()
        width: Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 25
        ListView {
            clip: true
            anchors.fill: parent
            delegate: Kirigami.BasicListItem {
                text: display

                onClicked: {
                    kcm.saveTimeZone(display)
                    timeZonePickerDialog.accept()
                }
            }
            model: kcm.timeZonesModel
        }
    }

    Controls.Dialog {
        id: timePickerDialog
        title: i18n("Pick Time")
        modal: true
        standardButtons: Controls.Dialog.Ok
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: close()
        width: Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 15
        contentItem: TimePicker {
            id: timePicker
            enabled: !ntpCheckBox.checked
            twentyFour: twentyFourSwitch.checked

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
    }

    Controls.Dialog {
        id: datePickerDialog
        title: i18n("Pick Date")
        modal: true
        standardButtons: Controls.Dialog.Ok
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: close()
        width: Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 15
        contentItem: DatePicker {
            id: datePicker
            enabled: !ntpCheckBox.checked

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
    }
}
