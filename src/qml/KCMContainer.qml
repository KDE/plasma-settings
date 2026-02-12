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

// Top-level container for a KCM (and its first page)
KCMPageContainer {
    id: container

    // Called once by initial kcm load (and not further pages in the KCM added to the stack)
    function loadKCM() {
        if (kcm && kcm.load !== undefined) {
            kcm.load();
            container.kcmSupportsInstantApply =  Qt.binding(() => kcm.supportsInstantApply);
        }
    }

    Component {
        id: kcmPageContainer
        KCMPageContainer {}
    }

    data: [
        Connections {
            target: kcm
            function onPagePushed(page) {
                // When pushing kcm subpage, ensure it's created by pageStack so that the page stack handles deletion/cleanup.
                applicationWindow().pageStack.push(kcmPageContainer,
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
}
