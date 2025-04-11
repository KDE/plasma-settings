/*
 * SPDX-FileCopyrightText: 2021-2025 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

import org.kde.plasma.settings

Kirigami.ScrollablePage {
    id: root
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    title: SettingsApp.subCategoryModel.title

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    signal popPage()

    header: QQC2.ToolBar {
        Layout.fillWidth: true
        implicitHeight: applicationWindow().pageStack.globalToolBar.preferredHeight

        QQC2.ToolButton {
            id: backButton

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            padding: 0

            contentItem: RowLayout {
                Kirigami.Icon {
                    source: 'go-previous'
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                }
                Kirigami.Heading {
                    level: 1
                    text: root.title
                    elide: Text.ElideRight
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                root.popPage();
            }
        }
    }

    ListView {
        id: listView
        model: SettingsApp.subCategoryModel

        activeFocusOnTab: true

        Accessible.role: Accessible.List

        // Bind active index of listview
        Binding {
            target: listView
            property: "currentIndex"
            // Don't need active indexes when page takes up the whole screen
            value: applicationWindow().isWidescreen ? SettingsApp.activeSubCategoryRow : -1
        }

        delegate: SidebarDelegate {
            id: delegate

            required property int index
            required property string pluginId
            required property var name
            required property string iconName

            text: name
            icon.name: iconName

            highlighted: ListView.isCurrentItem

            showArrow: false

            property bool pageInView: pluginId === applicationWindow().currentModuleName
            onClicked: {
                if (!pageInView || !applicationWindow().isWidescreen) {
                    applicationWindow().openModule(delegate.ListView.view.model.index(index, 0));
                }
            }

            Keys.onEnterPressed: clicked();
            Keys.onReturnPressed: clicked();

            Keys.onLeftPressed: {
                if (LayoutMirroring.enabled) {
                    clicked();
                }
            }
            Keys.onRightPressed: {
                if (!LayoutMirroring.enabled) {
                    clicked();
                }
            }
        }
    }
}
