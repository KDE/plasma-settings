/*
 * Copyright 2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.11 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.OverlayDrawer {
    id: drawer
    modal: false
    height: applicationWindow().height
    width: 300
    handleVisible: false

    edge: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge
    parent: QQC2.Overlay.overlay
    x: 0

    property alias model: listView.model

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: ColumnLayout {
        spacing: 0

        QQC2.ToolBar {
            Layout.fillWidth: true
            implicitHeight: applicationWindow().pageStack.globalToolBar.preferredHeight
            visible: drawer.visible

            Item {
                anchors.fill: parent

                Kirigami.Heading {
                    level: 1
                    text: i18n("Settings")
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    anchors.verticalCenter: parent.verticalCenter
                }

                QQC2.ToolButton {
                    id: searchButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: i18n("Search")
                    icon.name: "search"
                    checkable: true

                    onCheckedChanged: {
                        if (!checked) {
                            drawer.model.filterString = "";
                        }
                    }
                }

            }
        }

        HeaderSearchBar {
            Layout.fillWidth: true

            model: drawer.model
            show: searchButton.checked
        }

        QQC2.ScrollView {
            id: scrollView
            Layout.fillHeight: true
            Layout.fillWidth: true
            z: -1

            property real scrollBarWidth: QQC2.ScrollBar.vertical.width
            QQC2.ScrollBar.horizontal.visible: false

            ListView {
                id: listView
                spacing: Kirigami.Units.smallSpacing
                topMargin: Kirigami.Units.smallSpacing
                bottomMargin: Kirigami.Units.smallSpacing

                delegate: SidebarButton {
                    width: listView.width - Kirigami.Units.smallSpacing * 2
                    height: Kirigami.Units.gridUnit * 2
                    x: Kirigami.Units.smallSpacing

                    property bool pageInView: model.id === applicationWindow().currentModuleName

                    text: model.name
                    icon.name: model.iconName
                    checked: pageInView

                    onClicked: {
                        if (!pageInView) {
                            applicationWindow().openModule(model.id);
                        }
                        checked = Qt.binding(function() { return pageInView; });
                    }
                }
            }
        }
    }
}
