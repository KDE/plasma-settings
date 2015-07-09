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
import QtQuick.Controls 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kcm 1.0

Item {
    id: timeModule
    objectName: "timeModule"

    ExclusiveGroup { id: themeGroup }
    ColumnLayout {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            rightMargin: units.gridUnit
        }
        spacing: units.gridUnit / 2

        PlasmaExtras.Heading {
            text: i18n("Font")
            level: 3
        }

        PlasmaComponents.Slider {
            id: fontSizeSlider
            Layout.preferredWidth: timeModule.width - units.gridUnit
            stepSize: 1.0
            minimumValue: 3
            maximumValue: 12
            value: kcm.fontSize

            onValueChanged: {
                if (pressed) {
                    print("Setting font size to " + value);
                    kcm.fontSize = value;
                }

            }
        }

        PlasmaExtras.Heading {
            text: i18n("Theme")
            level: 3
        }

        Repeater {
            model: kcm.themeListModel
            delegate: RowLayout {
                PlasmaComponents.Label {
                    text: model.display
                    Layout.fillWidth: true
                }
                RadioButton {
                    exclusiveGroup: themeGroup
                    checked: kcm.themeName == model.packageNameRole
                    onCheckedChanged: {
                        if (checked) {
                            kcm.themeName = model.packageNameRole;
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        print("KCM.fontSize: " + kcm.fontSize);
    }

}
