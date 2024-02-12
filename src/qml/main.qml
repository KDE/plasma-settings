/*

    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import org.kde.plasma.settings 0.1

Kirigami.ApplicationWindow {
    id: root
    
    pageStack.defaultColumnWidth: Kirigami.Units.gridUnit * 35
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;

    // HACK: popHiddenPages seems to popup the kcm module at launch, will need to fix in Kirigami
    Timer {
        interval: 200
        running: true
        onTriggered: root.pageStack.popHiddenPages = true;
    }

    property alias currentModule: module
    property string currentModuleName
    
    // initialize context drawer
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    readonly property real widescreenThreshold: 720
    property bool isWidescreen: width >= widescreenThreshold
    onIsWidescreenChanged: changeNav(isWidescreen);

    property var loadedKCMPage: null
    
    // change between sidebar and single page listview
    function changeNav(toWidescreen) {
        if (SettingsApp.singleModule) return;

        if (toWidescreen) {
            sidebarLoader.active = true;
            root.globalDrawer = sidebarLoader.item;

            // remove the listview page, and restore all other pages
            listViewPageLoader.active = false;
            if (pageStack.currentItem == defaultPage) return;

            if (pageStack.depth == 0) {
                pageStack.push(defaultPage);
            }
        } else {
            sidebarLoader.active = false;
            root.globalDrawer = null;

            // prevent kcm page from getting deleted when popped
            if (root.loadedKCMPage) {
                root.loadedKCMPage.suppressDeletion = true;
            }

            // pop all pages
            while (pageStack.depth > 0) {
                pageStack.pop()
            }

            if (root.loadedKCMPage) {
                root.loadedKCMPage.suppressDeletion = false;
            }

            // insert listview page at beginning
            listViewPageLoader.active = true;
            pageStack.push(listViewPageLoader.item);

            // restore the kcm page
            if (module.name) {
                root.pageStack.push(root.loadedKCMPage);
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

        // only add the page if it is valid
        if (module.valid) {
            loadedKCMPage = kcmContainer.createObject(pageStack, {"kcm": module.kcm, "internalPage": module.kcm.mainUi});
            pageStack.push(loadedKCMPage);
            currentModuleName = module.name;
        } else if (isWidescreen) {
            pageStack.push(defaultPage);
        }
    }
    
    // if module is specified to be opened, load it
    Component.onCompleted: {
        changeNav(isWidescreen);

        if (SettingsApp.startModule.length > 0) {
            openModule(SettingsApp.startModule);
        }
    }

    Connections {
        target: SettingsApp
        function onModuleRequested(moduleName) {
            openModule(moduleName);
        }

        function onActivateRequested() {
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
