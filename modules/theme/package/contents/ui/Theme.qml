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

    GridLayout {
        id: formLayout

        anchors.fill: parent

        columns: 2
        rowSpacing: units.gridUnit / 2

        ExclusiveGroup { id: themeGroup }


        PlasmaComponents.Label {
            text: i18n("Light")
            Layout.fillWidth: true
        }
        RadioButton {
            checked: kcm.themeName == "default"
            exclusiveGroup: themeGroup
            onCheckedChanged: {
                if (checked) {
                    kcm.themeName = "default";
                }
            }
        }


        PlasmaComponents.Label {
            text: i18n("Dark")
            Layout.fillWidth: true
        }
        RadioButton {
            exclusiveGroup: themeGroup
            onCheckedChanged: {
                if (checked) {
                    kcm.themeName = "breeze-dark";
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

    }

}
