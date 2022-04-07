/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.2

import cellularnetworkkcm 1.0

import "mobileform" as MobileForm

Kirigami.ScrollablePage {
    id: modemPage
    title: i18n("Modem %1", modem.displayId)
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    property Modem modem
    property bool showExtra: false
    
    ColumnLayout {
        MessagesList {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            visible: count != 0
            model: kcm.messages
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Modem Control")
                }
                
                MobileForm.AbstractFormDelegate {
                    id: toggleModemButton
                    Layout.fillWidth: true
                    contentItem: RowLayout {
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Modem State")
                        }
                        Controls.Button {
                            text: modem.details.isEnabled ? i18n("Disable Modem") : i18n("Enable Modem")
                            onClicked: modem.setEnabled(!modem.details.isEnabled)
                        }
                    }
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!toggleModemButton.controlHovered && !modemRestartButton.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.AbstractFormDelegate {
                    id: modemRestartButton
                    Layout.fillWidth: true
                    contentItem: RowLayout {
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Modem Restart")
                        }
                        Controls.Button {
                            text: i18n("Force Modem Restart")
                            onClicked: modem.reset()
                        }
                    }
                }
            }
        }
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Modem Details")
                }
                
                MobileForm.AbstractFormDelegate {
                    id: accessTechnologiesText
                    Layout.fillWidth: true
                    
                    background: Item {}
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Access Technologies")
                            elide: Text.ElideRight
                        }
                        Repeater {
                            model: modem.details.accessTechnologies
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
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!accessTechnologiesText.controlHovered && !imeiText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: imeiText
                    text: i18n("IMEI")
                    description: modem.details.equipmentIdentifier
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!imeiText.controlHovered && !enabledText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: enabledText
                    text: i18n("Enabled")
                    description: modem.details.isEnabled
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!enabledText.controlHovered && !manufacturerText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: manufacturerText
                    text: i18n("Manufacturer")
                    description: modem.details.manufacturer
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!manufacturerText.controlHovered && !modelText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: modelText
                    text: i18n("Model")
                    description: modem.details.model
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!modelText.controlHovered && !ownedNumbersText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.AbstractFormDelegate {
                    id: ownedNumbersText
                    Layout.fillWidth: true
                    
                    background: Item {}
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Owned Numbers:")
                            elide: Text.ElideRight
                        }
                        Repeater {
                            model: modem.details.ownNumbers
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
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!ownedNumbersText.controlHovered && !revisionText.controlHovered) ? 0.5 : 0
                }

                MobileForm.FormTextDelegate {
                    id: revisionText
                    text: i18n("Revision")
                    description: modem.details.revision
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!revisionText.controlHovered && !signalQualityText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: signalQualityText
                    text: i18n("Signal Quality")
                    description: modem.details.signalQuality
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!signalQualityText.controlHovered && !stateText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: stateText
                    text: i18n("State")
                    description: modem.details.state
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!stateText.controlHovered && !failureReasonText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: failureReasonText
                    text: i18n("Failure Reason")
                    description: modem.details.stateFailedReason
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!failureReasonText.controlHovered && !registrationStateText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: registrationStateText
                    text: i18n("Registration State")
                    description: modem.details.registrationState
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!registrationStateText.controlHovered && !roamingText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: roamingText
                    text: i18n("Roaming")
                    description: modem.isRoaming ? i18n("Yes") : i18n("No")
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!roamingText.controlHovered && !firmwareVersionText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: firmwareVersionText
                    text: i18n("Firmware Version")
                    description: modem.details.firmwareVersion
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!firmwareVersionText.controlHovered && !interfaceNameText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: interfaceNameText
                    text: i18n("Interface Name")
                    description: modem.details.interfaceName
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!interfaceNameText.controlHovered && !meteredText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: meteredText
                    text: i18n("Metered")
                    description: modem.details.metered
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!meteredText.controlHovered && !activeNMConnectionText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: activeNMConnectionText
                    text: i18n("Active NetworkManager Connection")
                    description: modem.activeConnectionUni
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!activeNMConnectionText.controlHovered && !deviceText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: deviceText
                    text: i18n("Device")
                    description: modem.details.device
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!deviceText.controlHovered && !imsiText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: deviceIdText
                    text: i18n("Device ID")
                    description: modem.details.deviceIdentifier
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!deviceIdText.controlHovered && !imsiText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.AbstractFormDelegate {
                    id: driversText
                    Layout.fillWidth: true
                    
                    background: Item {}
                    contentItem: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        Controls.Label {
                            Layout.fillWidth: true
                            text: i18n("Drivers:")
                            elide: Text.ElideRight
                        }
                        Repeater {
                            model: modem.details.drivers
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
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!driversText.controlHovered && !pluginText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: pluginText
                    text: i18n("Plugin")
                    description: modem.details.plugin
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!pluginText.controlHovered && !powerStateText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: powerStateText
                    text: i18n("Power State")
                    description: modem.details.powerState
                }
                
                Kirigami.Separator {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    opacity: (!powerStateText.controlHovered && !simPathText.controlHovered) ? 0.5 : 0
                }
                
                MobileForm.FormTextDelegate {
                    id: simPathText
                    text: i18n("SIM Path")
                    description: modem.details.simPath
                }
            }
        }
    }
}

