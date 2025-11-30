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

// Container for every KCM page
Kirigami.Page {
    id: container
    property QtObject kcm
    property Item internalPage

    property bool kcmSupportsInstantApply: false
    property bool kcmNeedsSave: false

    signal applyClicked()

    title: internalPage.title

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    flickable: internalPage.flickable

    // Called once by initial kcm load (and not further pages in the KCM added to the stack)
    function loadKCM() {
        if (kcm && kcm.load !== undefined) {
            kcm.load();
            container.kcmSupportsInstantApply =  Qt.binding(() => kcm.supportsInstantApply);
        }
    }

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
                // When pushing kcm subpage, ensure it's created by pageStack so that the page stack handles deletion/cleanup.
                applicationWindow().pageStack.push(kcmContainer,
                    {"kcm": SettingsApp.activeModule.kcm, "internalPage": page});
            }
            function onPageRemoved() {
                applicationWindow().pageStack.pop();
            }
            function onNeedsSaveChanged() {
                container.kcmNeedsSave = kcm.needsSave;
                if (kcm.supportsInstantApply && kcm.needsSave) {
                    kcm.save()
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
                    visible: kcm && (kcm.buttons & KCM.ConfigModule.Apply)
                    enabled: container.kcmNeedsSave
                    onClicked: kcm.load()
                }
                Controls.Button {
                    text: i18nc("kcm button", "Defaults")
                    icon.name: "kt-restore-defaults"
                    visible: kcm && kcm.defaultsIndicatorsVisible && (kcm.buttons & KCM.ConfigModule.Default)
                    enabled: container.kcmNeedsSave
                    onClicked: kcm.defaults()
                }
                Item {
                    Layout.fillWidth: true
                }
                Controls.Button {
                    text: i18nc("kcm button", "Apply")
                    icon.name: "dialog-ok-apply"
                    visible: !container.kcmSupportsInstantApply && kcm && (kcm.buttons & KCM.ConfigModule.Apply)
                    enabled: container.kcmNeedsSave
                    onClicked: kcm.save()
                }
            }
        }
    }

    footer: Loader {
        sourceComponent: kcm && kcm.supportsInstantApply ? undefined : buttonToolbarComponent
    }
}
