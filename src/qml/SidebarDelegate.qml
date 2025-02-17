/*
 * SPDX-FileCopyrightText: 2021-2025 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Controls.ItemDelegate {
    id: root

    // Avoids annoying hover feedback being left behind when scrolling with touch
    hoverEnabled: !Kirigami.Settings.isMobile

    property bool showArrow: false

    readonly property bool selected: delegate.highlighted || delegate.pressed

    width: ListView.view?.width ?? 0

    Accessible.name: text
    Accessible.onPressAction: clicked()

    padding: Kirigami.Settings.isMobile ? Kirigami.Units.largeSpacing : Kirigami.Units.mediumSpacing
    topInset: Kirigami.Units.smallSpacing / 2
    bottomInset: Kirigami.Units.smallSpacing / 2

    contentItem: RowLayout {
        spacing: Kirigami.Units.gridUnit

        Kirigami.Icon {
            Layout.leftMargin: Kirigami.Units.largeSpacing
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            source: root.icon.name ? root.icon.name : "question"
        }

        Controls.Label {
            id: label
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.text
            opacity: root.display !== Controls.AbstractButton.TextOnly ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Kirigami.Icon {
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small

            opacity: delegate.showArrow ? 0.7 : 0.0
            source: LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic"
            selected: delegate.selected
        }
    }
}
