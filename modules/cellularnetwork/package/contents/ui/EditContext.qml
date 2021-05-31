/*
 *   SPDX-FileCopyrightText: 2021 Bhushan Shah <bshah@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.kcm 1.2 as KCM
import QtQuick.Layouts 1.2
import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.10 as Kirigami
import MeeGo.QOfono 0.2

KCM.SimpleKCM {
    id: addPage
    property string mode: "add"
    property bool addContext: false
    property OfonoContextConnection ctx

    title: mode == "add" ? i18n("Add Access Point") : i18n("Edit Access Point")

    OfonoManager {
        id: ofonoManager
    }

    function saveContext() {
        if (ctx) {
            ctx.name = name.text;
            ctx.accessPointName = apn.text;
            ctx.username = username.text;
            ctx.password = password.text;
            ctx.authMethod = authMethod.currentText;
            addPage.addContext = false;
        }
    }

    OfonoConnMan {
        id: ofonoConnManager
        modemPath: ofonoManager.modems[0]
        onContextAdded: {
            if (addPage.addContext) {
                ctx = newContext.createObject(addPage, {contextPath: path});
                saveContext();
                kcm.pop();
            }
        }
    }

    Component {
        id: newContext
        OfonoContextConnection {
        }
    }

    Kirigami.FormLayout {
        Controls.TextField {
            id: name
            Kirigami.FormData.label: i18n("Name:")
            text: mode == "edit" ? ctx.name : ""
        }
        Controls.TextField {
            id: apn
            Kirigami.FormData.label: i18n("APN:")
            text: mode == "edit" ? ctx.accessPointName : ""
        }
        Controls.TextField {
            id: username
            Kirigami.FormData.label: i18n("Username:")
            text: mode == "edit" ? ctx.username : ""
        }
        Controls.TextField {
            id: password
            Kirigami.FormData.label: i18n("Password:")
            echoMode: TextInput.PasswordEchoOnEdit
            text: mode == "edit" ? ctx.password : ""
        }
        Controls.ComboBox {
            id: authMethod
            Kirigami.FormData.label: i18n("Authentication Method:")
            model: ["none", "pap", "chap"]
            Component.onCompleted: {
                if (mode == "edit") {
                    currentIndex = indexOfValue(ctx.authMethod);
                } else {
                    currentIndex = indexOfValue("chap");
                }
            }
        }

        Controls.Button {
            text: i18n("Apply")
            onClicked: {
                if (mode == "add") {
                    addPage.addContext = true;
                    ofonoConnManager.addContext("internet");
                } else {
                    saveContext();
                    kcm.pop();
                }
            }
        }

        Controls.Button {
            text: i18n("Delete")
            visible: mode == "edit"
            onClicked: {
                if (ctx) {
                    ofonoConnManager.removeContext(ctx.contextPath);
                    kcm.pop();
                }
            }
        }
    }

}
