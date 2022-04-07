/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcm 1.2

import cellularnetworkkcm 1.0

import "mobileform" as MobileForm

Kirigami.ScrollablePage {
    id: simPage
    title: i18n("SIM") + " " + sim.displayId
    
    property Sim sim
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }
    
    ColumnLayout {
        spacing: 0
        width: simPage.width
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            Layout.bottomMargin: visible && !messagesList.visible ? Kirigami.Units.largeSpacing : 0
            visible: !sim.enabled
            type: Kirigami.MessageType.Error
            text: qsTr("This SIM slot is empty, a SIM card needs to be inserted in order for it to be used.")
        }
        
        MessagesList {
            id: messagesList
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            model: kcm.messages
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormSwitchDelegate {
                    id: dataRoamingCheckBox
                    text: i18n("Data Roaming")
                    description: i18n("Allow your device to use networks other than your carrier.")
                    enabled: sim.enabled
                    checked: sim.modem.isRoaming
                    onCheckedChanged: sim.modem.isRoaming = checked
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!dataRoamingCheckBox.controlHovered && !apnButton.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormButtonDelegate {
                    id: apnButton
                    iconName: "globe"
                    text: i18n("Modify APNs")
                    description: i18n("Configure access point names for your carrier.")
                    enabled: sim.enabled && enabledConnections.wwanEnabled
                    onClicked: kcm.push("ProfileList.qml", {"modem": sim.modem});
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!apnButton.controlHovered && !networksButton.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormButtonDelegate {
                    id: networksButton
                    iconName: "network-mobile-available"
                    text: i18n("Networks")
                    description: i18n("Select a network operator.")
                    enabled: sim.enabled
                    onClicked: kcm.push("AvailableNetworks.qml", { "modem": sim.modem, "sim": sim });
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!networksButton.controlHovered && !simLockButton.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormButtonDelegate {
                    id: simLockButton
                    iconName: "unlock"
                    text: i18n("SIM Lock")
                    description: i18n("Modify SIM lock settings.")
                    enabled: sim.enabled
                    onClicked: kcm.push("SimLock.qml", { "sim": sim });
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!simLockButton.controlHovered && !modemDetailsButton.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormButtonDelegate {
                    id: modemDetailsButton
                    iconName: "network-modem"
                    text: i18n("Modem Details")
                    description: i18n("View the details of the modem this SIM is connected to.")
                    onClicked: kcm.push("Modem.qml", { "modem": sim.modem })
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("SIM Details")
                }
                
                MobileForm.FormTextDelegate {
                    id: lockedText
                    text: i18n("Locked")
                    description: sim.locked ? i18n("Yes") : i18n("No")
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!lockedText.controlHovered && !imsiText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate  {
                    id: imsiText
                    text: i18n("IMSI")
                    description: sim.imsi
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!imsiText.controlHovered && !eidText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate  {
                    id: eidText
                    text: i18n("EID")
                    description: sim.eid
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!eidText.controlHovered && !opCodeModemText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate  {
                    id: opCodeModemText
                    text: i18n("Operator Code (modem)")
                    description: sim.modem.details.operatorCode
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!opCodeModemText.controlHovered && !opNameModemText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate  {
                    id: opNameModemText
                    text: i18n("Operator Name (modem)")
                    description: sim.modem.details.operatorName
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!opNameModemText.controlHovered && !opCodeSimText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate  {
                    id: opCodeSimText
                    text: i18n("Operator Code (provided by SIM)")
                    description: sim.operatorIdentifier
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!opCodeSimText.controlHovered && !opNameSimText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: opNameSimText
                    text: i18n("Operator Name (provided by SIM)")
                    description: sim.operatorName
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!opNameSimText.controlHovered && !simIdText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: simIdText
                    text: i18n("SIM ID")
                    description: sim.simIdentifier
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!simIdText.controlHovered && !emergencyNumbersText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.AbstractFormDelegate {
                    id: emergencyNumbersText
                    Layout.fillWidth: true
                    
                    background: Item {}
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Emergency Numbers")
                            elide: Text.ElideRight
                        }
                        
                        Repeater {
                            model: sim.emergencyNumbers
                            Controls.Label {
                                Layout.fillWidth: true
                                text: modelData
                                color: Kirigami.Theme.disabledTextColor
                                font: Kirigami.Theme.smallFont
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
