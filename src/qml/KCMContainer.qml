/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import org.kde.plasma.settings

Kirigami.Page {
    id: container
    property QtObject kcm
    property Item internalPage
    property bool suppressDeletion: false

    property bool kcmSupportsInstantApply: false
    property bool kcmNeedsSave: false

    signal applyClicked()
    
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
            container.kcmSupportsInstantApply =  Qt.binding(() => kcm.supportsInstantApply);
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
                container.kcmNeedsSave = kcm.needsSave;
                if (kcm.supportsInstantApply && kcm.needsSave) {
                    kcm.save()
                }
            }
        },
        Connections {
            target: pageStack
            function onPageRemoved(page) {
                if (kcm.supportsInstantApply && kcm.needsSave) {
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

    Component {
        id: buttonToolbarComponent
        Controls.ToolBar {
            visible: !container.kcmSupportsInstantApply
            position: Controls.ToolBar.Footer
            RowLayout {
                anchors.fill: parent
                Controls.Button {
                    text: i18nc("kcm button", "Reset")
                    icon.name: "edit-undo"
                    visible: kcm.buttons & KCM.ConfigModule.Apply
                    enabled: container.kcmNeedsSave
                    onClicked: kcm.load()
                }
                Controls.Button {
                    text: i18nc("kcm button", "Defaults")
                    icon.name: "kt-restore-defaults"
                    visible: kcm.defaultsIndicatorsVisible && (kcm.buttons & KCM.ConfigModule.Default)
                    enabled: container.kcmNeedsSave
                    onClicked: kcm.defaults()
                }
                Item {
                    Layout.fillWidth: true
                }
                Controls.Button {
                    text: i18nc("kcm button", "Apply")
                    icon.name: "dialog-ok-apply"
                    visible: !container.kcmSupportsInstantApply && (kcm.buttons & KCM.ConfigModule.Apply)
                    enabled: container.kcmNeedsSave
                    onClicked: kcm.save()
                }
            }
        }
    }

    footer: Loader {
        sourceComponent: kcm.supportsInstantApply ? undefined : buttonToolbarComponent
    }
}
