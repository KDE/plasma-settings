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

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    function goToMainPage(): void {
        pageRow.currentIndex = 0;
    }

    function goToSubCategoryPage(): void {
        if (pageRow.depth == 1) {
            pageRow.push(subCategoryPage);
        }
        pageRow.currentIndex = 1;
    }

    contentItem: Kirigami.PageRow {
        id: pageRow

        height: drawer.height
        width: drawer.width
        initialPage: mainPage

        SidebarCategoriesPage {
            id: mainPage
            focus: true

            onDelegateClicked: (index, pluginId, isCategory) => {
                const pageInView = pluginId === applicationWindow().currentModuleName;

                if (!pageInView || isCategory) {
                    applicationWindow().openModule(index);
                }

                if (isCategory) {
                    if (pageRow.depth == 1) {
                        pageRow.push(subCategoryPage);
                    } else {
                        pageRow.currentIndex = 1;
                    }
                }
            }
        }

        SidebarSubCategoryPage {
            id: subCategoryPage

            onPopPage: {
                // Don't pop, just change the page index
                pageRow.currentIndex = 0;
            }
        }
    }
}
