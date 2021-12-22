/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.19 as Kirigami

Controls.Control {
    property var model
    property bool show: false
    
    onShowChanged: {
        if (show) {
            searchField.forceActiveFocus();
        } else {
            searchField.text = "";
        }
    }
    
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false
    
    background: Rectangle { color: Kirigami.Theme.backgroundColor }
    
    height: opacity != 0 ? implicitHeight : 0
    opacity: show ? 1 : 0
    
    Behavior on height {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    
    contentItem: Kirigami.SearchField {
        id: searchField
        autoAccept: true
        onAccepted: model.filterString = searchField.text
    }
    
    Kirigami.Separator {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
