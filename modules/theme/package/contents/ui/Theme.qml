/*
 *   Copyright 2015 Sebastian Kügler <sebas@kde.org>
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

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls

import org.kde.kirigami 2.1 as Kirigami
import org.kde.kcm 1.2

SimpleKCM {
    id: themeModule
    topPadding: Kirigami.Units.gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.gridUnit * 0.5

        Kirigami.Heading {
            text: i18n("Font")
            level: 3
        }

        Controls.Slider {
            id: fontSizeSlider
            Layout.preferredWidth: parent.width - Kirigami.Units.gridUnit * 2
            stepSize: 1.0
            from: 3
            to: 12
            value: kcm.fontSize

            onValueChanged: {
                if (pressed) {
                    print("Setting font size to " + value);
                    kcm.fontSize = value;
                }

            }
        }

        Kirigami.Heading {
            text: i18n("Theme")
            level: 3
        }

        Repeater {
            model: kcm.themeListModel
            delegate: Controls.RadioDelegate {
                Layout.fillWidth: true
                text: model.display
                checked: kcm.themeName === model.packageNameRole
                onCheckedChanged: {
                    if (checked) {
                        kcm.themeName = model.packageNameRole;
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        print("KCM.fontSize: " + kcm.fontSize);
    }
}
