/*
    SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Controls 2.10 as QQC2
import QtQuick.Layouts 1.11

import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcm 1.2
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

SimpleKCM {
    id: powermanagementModule
    
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit

    ColumnLayout {
        width: parent.width
        spacing: 0
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormComboBoxDelegate {
                    id: dimScreenCombo
                    text: i18nc("Part of a sentence like 'Dim screen after 5 minutes'", "Dim screen after")
                    model: kcm.timeOptions()
                    currentValue: kcm.timeOptions()[kcm.dimScreenIdx]
                    dialog.parent: powermanagementModule
                    
                    dialogDelegate: QQC2.RadioDelegate {
                        implicitWidth: Kirigami.Units.gridUnit * 16
                        topPadding: Kirigami.Units.smallSpacing * 2
                        bottomPadding: Kirigami.Units.smallSpacing * 2
                        
                        text: modelData
                        checked: dimScreenCombo.currentValue == modelData
                        onCheckedChanged: {
                            if (checked) {
                                dimScreenCombo.currentValue = modelData;
                                kcm.dimScreenIdx = model.index;
                            }
                        }
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: dimScreenCombo; below: screenOffCombo }
                
                MobileForm.FormComboBoxDelegate {
                    id: screenOffCombo
                    text: i18nc("Part of a sentence like 'Turn off screen after 5 minutes'", "Turn off screen after")
                    model: kcm.timeOptions()
                    currentValue: kcm.timeOptions()[kcm.screenOffIdx]
                    dialog.parent: powermanagementModule
                    
                    dialogDelegate: QQC2.RadioDelegate {
                        implicitWidth: Kirigami.Units.gridUnit * 16
                        topPadding: Kirigami.Units.smallSpacing * 2
                        bottomPadding: Kirigami.Units.smallSpacing * 2
                        
                        text: modelData
                        checked: screenOffCombo.currentValue == modelData
                        onCheckedChanged: {
                            if (checked) {
                                screenOffCombo.currentValue = modelData;
                                kcm.screenOffIdx = model.index;
                            }
                        }
                    }
                }
                
                MobileForm.FormDelegateSeparator { above: screenOffCombo; below: suspendCombo }
                
                MobileForm.FormComboBoxDelegate {
                    id: suspendCombo
                    text: i18nc("Part of a sentence like 'Suspend device after 5 minutes'", "Suspend device after")
                    model: kcm.timeOptions()
                    currentValue: kcm.timeOptions()[kcm.screenOffIdx]
                    dialog.parent: powermanagementModule
                    
                    dialogDelegate: QQC2.RadioDelegate {
                        implicitWidth: Kirigami.Units.gridUnit * 16
                        topPadding: Kirigami.Units.smallSpacing * 2
                        bottomPadding: Kirigami.Units.smallSpacing * 2
                        
                        text: modelData
                        checked: dimScreenCombo.currentValue == modelData
                        onCheckedChanged: {
                            if (checked) {
                                dimScreenCombo.currentValue = modelData;
                                kcm.screenOffIdx = model.index;
                            }
                        }
                    }
                }
            }
        }
    }
}
