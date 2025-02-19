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

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    property bool searchMode: false

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    signal delegateClicked(index: var, pluginId: string, isCategory: bool)

    header: QQC2.ToolBar {
        Layout.fillWidth: true
        implicitHeight: applicationWindow().pageStack.globalToolBar.preferredHeight

        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            anchors.fill: parent

            Kirigami.SearchField {
                id: searchField
                Layout.fillWidth: true
                autoAccept: true
                placeholderText: i18n('Search…')
                onAccepted: SettingsApp.filterString = searchField.text
            }

            QQC2.ToolButton {
                icon.name: 'application-menu'

                Accessible.role: Accessible.ButtonMenu
                Accessible.name: i18n("Show menu")
                QQC2.ToolTip.text: Accessible.name
                QQC2.ToolTip.visible: hovered && !pressed
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

                onClicked: {
                    if (!menu.visible) {
                        menu.open()
                    }
                }

                QQC2.Menu {
                    id: menu
                    y: parent.height
                    QQC2.MenuItem {
                        text: i18n('About Plasma Settings')
                        icon.name: 'org.kde.mobile.plasmasettings'
                        onTriggered: applicationWindow().pageStack.push(Qt.createComponent("org.kde.kirigamiaddons.formcard", "AboutPage"))
                    }
                    QQC2.MenuItem {
                        text: i18n('About KDE')
                        icon.name: 'kde'
                        onTriggered: applicationWindow().pageStack.push(Qt.createComponent("org.kde.kirigamiaddons.formcard", "AboutKDEPage"))
                    }
                }
            }
        }
    }

    // Bind active index of listview
    Binding {
        target: listView
        property: "currentIndex"
        value: applicationWindow().isWidescreen
                    ? ((SettingsApp.filterString.length > 0) ? SettingsApp.activeSearchRow : SettingsApp.activeCategoryRow)
                    : -1 // Don't need active indexes when page takes up the whole screen
    }

    ListView {
        id: listView
        reuseItems: true
        model: (SettingsApp.filterString.length > 0) ? SettingsApp.searchModel : SettingsApp.categoryModel

        activeFocusOnTab: true
        keyNavigationWraps: true

        Accessible.role: Accessible.List

        section {
            property: "categoryDisplayRole"
            delegate: Kirigami.ListSectionHeader {
                required property string section

                width: ListView.view.width
                label: section
            }
        }

        delegate: SidebarDelegate {
            id: delegate

            required property int index
            required property string pluginId
            required property string name
            required property string iconName
            required property bool isCategory
            required property bool isKCM
            property string categoryDisplayRole

            text: name
            icon.name: iconName

            highlighted: ListView.isCurrentItem

            showArrow: isCategory;

            onClicked: {
                root.delegateClicked(delegate.ListView.view.model.index(index, 0), pluginId, isCategory);
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
