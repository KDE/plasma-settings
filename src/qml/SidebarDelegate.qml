/*
 * SPDX-FileCopyrightText: 2021-2025 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates as Delegates

Delegates.RoundedItemDelegate {
    id: root

    // Avoids annoying hover feedback being left behind when scrolling with touch
    hoverEnabled: !Kirigami.Settings.isMobile

    property bool showArrow: false

    padding: Kirigami.Units.largeSpacing
    spacing: Kirigami.Units.largeSpacing * 2
    icon.width: Kirigami.Units.iconSizes.smallMedium
    icon.height: Kirigami.Units.iconSizes.smallMedium

    contentItem: RowLayout {
        spacing: root.spacing

        Kirigami.Icon {
            implicitWidth: root.icon.width
            implicitHeight: root.icon.height
            source: root.icon.name ?? "question"

            Accessible.ignored: true

            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        }

        Controls.Label {
            id: label

            text: root.text
            opacity: root.display !== Controls.AbstractButton.TextOnly ? 1 : 0

            Accessible.ignored: true

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Kirigami.Icon {
            opacity: delegate.showArrow ? 0.7 : 0.0
            source: LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic"

            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }
    }
}
