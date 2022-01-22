/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.Page {
    id: container
    property QtObject kcm
    property Item internalPage

    title: internalPage.title

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    flickable: internalPage.flickable
    actions.main: internalPage.actions.main
    actions.contextualActions: internalPage.contextualActions

    onInternalPageChanged: {
        internalPage.parent = contentItem;
        internalPage.anchors.fill = contentItem;
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            internalPage.forceActiveFocus();
        }
    }

    Component.onCompleted: kcm.load()

    data: [
        Connections {
            target: kcm
            function onPagePushed(page) {
                pageStack.push(kcmContainer.createObject(pageStack, {
                    internalPage: page,
                    kcm: kcm,
                }));
            }
            function onPageRemoved() {
                pageStack.pop();
            }
            function onNeedsSaveChanged () {
                if (kcm.needsSave) {
                    kcm.save()
                }
            }
        },
        Connections {
            target: pageStack
            function onPageRemoved(page) {
                if (kcm.needsSave) {
                    kcm.save()
                }
                if (page == container) {
                    page.destroy();
                }
            }
        },
        Connections {
            target: kcm
            function onCurrentIndexChanged(index) {
                const index_with_offset = index + 1;
                if (index_with_offset !== pageStack.currentIndex) {
                    pageStack.currentIndex = index_with_offset;
                }
            }
        }
    ]
}
