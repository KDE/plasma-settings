/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import org.kde.plasma.settings

Kirigami.Page {
    id: container
    property QtObject kcm
    property Item internalPage
    property bool suppressDeletion: false
    
    title: internalPage.title
    
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    
    flickable: internalPage.flickable
    actions: [
        internalPage.actions.main,
        internalPage.contextualActions
    ]

    onInternalPageChanged: {
        internalPage.parent = contentItem;
        internalPage.anchors.fill = contentItem;
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            internalPage.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        // setting a binding seems to not work, add them manually
        for (let action of internalPage.actions) {
            actions.push(action);
        }
        if (kcm.load !== undefined) {
            kcm.load();
        }
    }

    data: [
        Connections {
            target: internalPage
            function onActionsChanged() {
                root.actions.clear();
                for (let action of internalPage.actions) {
                    root.actions.push(action);
                }
            }
        },
        Connections {
            target: kcm
            function onPagePushed(page) {
                pageStack.push(kcmContainer.createObject(pageStack, {"internalPage": page}));
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
                if (page == container && !container.suppressDeletion) {
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
