/*
 *   SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
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
