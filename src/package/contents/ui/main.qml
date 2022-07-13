/*

    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.5 as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ApplicationWindow {
    id: rootItem
    
    pageStack.defaultColumnWidth: Kirigami.Units.gridUnit * 35
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;
    
    property alias currentModule: module
    property string currentModuleName
    
    // pop pages when not in use
    Connections {
        target: applicationWindow().pageStack
        function onCurrentIndexChanged() {
            timer.restart();
        }
    }
    
    // wait for animation to finish before popping pages
    Timer {
        id: timer
        interval: 300
        onTriggered: {
            let currentIndex = applicationWindow().pageStack.currentIndex;
            while (applicationWindow().pageStack.depth > (currentIndex + 1) && currentIndex >= 0) {
                applicationWindow().pageStack.pop();
            }
        }
    }
    
    // initialize context drawer
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    readonly property real widescreenThreshold: 720
    property bool isWidescreen: width >= widescreenThreshold
    onIsWidescreenChanged: changeNav(isWidescreen);
    
    // change between sidebar and single page listview
    function changeNav(toWidescreen) {
        if (SettingsApp.singleModule) return;
        
        if (toWidescreen) {
            // load sidebars
            sidebarLoader.active = true;
            globalDrawer = sidebarLoader.item;
            
            // remove the listview page, and restore all other pages
            listViewPageLoader.active = false;
            if (pageStack.currentItem == defaultPage) return;
            
            if (pageStack.depth == 0) {
                pageStack.push(defaultPage);
            } else {
                while (pageStack.depth > 0) {
                    pageStack.pop();
                }
                if (module.name) {
                    openModule(module.name);
                }
            }
        } else {
            // unload sidebar
            sidebarLoader.active = false;
            globalDrawer = null;
            
            // insert listview page in beginning
            listViewPageLoader.active = true;
            while (pageStack.depth > 0) {
                pageStack.pop()
            }
            pageStack.push(listViewPageLoader.item);
            
            if (module.name) {
                openModule(module.name);
            }
        }
    }
    
    Loader {
        id: listViewPageLoader
        active: false
        sourceComponent: ModulesListPage {
            model: proxyModel
        }
    }
    Loader {
        id: sidebarLoader
        active: false
        sourceComponent: Sidebar {
            model: proxyModel
        }
    }
    
    function openModule(path) {
        module.path = path;
        while (pageStack.depth > ((isWidescreen || SettingsApp.singleModule) ? 0 : 1)) {
            pageStack.pop();
        }
        pageStack.push(kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi}));
        
        currentModuleName = module.name;
    }
    
    // if module is specified to be opened, load it
    Component.onCompleted: {
        changeNav(isWidescreen)
        if (SettingsApp.startModule.length > 0) {
            openModule(SettingsApp.startModule)
        }
    }

    Connections {
        target: SettingsApp
        function onModuleRequested(moduleName) {
            openModule(moduleName);
            
            // HACK: raise window when module is requested; 
            // requestActivate() by itself doesn't seem to work
            applicationWindow().hide();
            applicationWindow().show();
            applicationWindow().requestActivate();
        }
    }
    
    Module {
        id: module
    }
    
    ModulesProxyModel {
        id: proxyModel
    }
    
    DefaultPage {
        id: defaultPage
        visible: false
    }

    Component {
        id: kcmContainer
        KCMContainer {}
    }
}
