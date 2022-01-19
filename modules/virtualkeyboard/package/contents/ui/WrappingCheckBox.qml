/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

QQC2.CheckBox {
    id: root
    contentItem: QQC2.Label {
        text: root.text
        font: root.font
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator.width + root.spacing
        wrapMode: QQC2.Label.Wrap
    }
}
