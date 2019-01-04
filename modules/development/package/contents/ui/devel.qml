// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.7
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.0 as Controls

import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcm 1.2

SimpleKCM {
    id: develModule
    objectName: "develModule"

    ColumnLayout {
        id: formLayout

        Controls.SwitchDelegate {
            id: ssh
            text: i18n("Allow remote SSH access:")
            checked: kcm.sshEnabled
            Layout.fillWidth: true
            onClicked: {
                kcm.sshEnabled = checked;
                // we have to check to se if it failed
                checked = kcm.sshEnabled;
            }
        }
    }
}
