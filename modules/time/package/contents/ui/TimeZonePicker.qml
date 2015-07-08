// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.active.settings 2.0
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: timeZonePicker
    objectName: "timeZonePicker"
    anchors.fill: parent

    signal filterChanged(string filter)

    function focusTextInput()
    {
        focusTimer.running = true
    }

    Timer {
        id: focusTimer
        interval: 100
        onTriggered: {
            tzFilter.forceActiveFocus()
        }
    }

    PlasmaComponents.TextField {
        id: tzFilter
        width: parent.width
        placeholderText: "Filter..."
//         clearButtonShown: true // FIXME: screws up text layout inside filter field
        //Keys.onTabPressed: tf2.forceActiveFocus();
        anchors {
            //verticalCenter: parent.verticalCenter
            topMargin: units.smallSpacing
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: kcm.timeZonesModel
        filterRole: "display"
        filterRegExp: ".*"+tzFilter.text+".*"
        sortRole: "display"
        sortOrder: "AscendingOrder"
    }

    ListView {
        id: timeZonesList
        currentIndex: -1
        clip: true
        //cacheBuffer: 90000
        anchors {
            //verticalCenter: parent.verticalCenter
            top: tzFilter.bottom
            topMargin: units.gridUnit / 2
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        section {
            property: "continent"
            criteria: ViewSection.FullString
            delegate: PlasmaComponents.ListItem {
                sectionDelegate: true
                PlasmaExtras.Heading {
                    text: section
                    level: 4
                    horizontalAlignment: Text.AlignLeft
                    //font { bold: true; }
                }
            }
        }

        model: filterModel

        delegate: timeZoneDelegate
        highlight: PlasmaCore.FrameSvgItem {
            id: highlightFrame
            imagePath: "widgets/viewitem"
            prefix: "selected+hover"
        }

    }
    PlasmaComponents.SectionScroller {
        id: sectionScroller
        listView: timeZonesList
    }

    Component {
        id: timeZoneDelegate
        PlasmaComponents.ListItem {
            PlasmaComponents.Label {
                text: display
            }
            enabled: true
            checked: kcm.timeZone == display
            onClicked: {
                print (" save: " + display);
                kcm.saveTimeZone(display)
                timeZonePickerDialog.close()
            }
        }
    }
}
