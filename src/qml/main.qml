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

    readonly property var currentModule: SettingsApp.activeModule
    readonly property string currentModuleName: SettingsApp.activeModule.name

    readonly property real widescreenThreshold: 720
    readonly property bool isWidescreen: width >= widescreenThreshold
    onIsWidescreenChanged: changeNav(isWidescreen);

    property var loadedKCMPage: null

    // When resetting the view, how far to pop (without popping the KCM list page)
    function popKCMDepth() {
        if (isWidescreen || SettingsApp.singleModule) {
            return 0;
        }
        // If the sub category page is open, the pop depth is 2 instead of 1
        return SettingsApp.activeModule.isInSubCategory ? 2 : 1;
    }

    pageStack.defaultColumnWidth: Kirigami.Units.gridUnit * 35
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;

    // initialize context drawer
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    // change between sidebar and single page listview
    function changeNav(toWidescreen) {
        if (SettingsApp.singleModule) return;

        if (toWidescreen) {
            sidebarLoader.active = true;
            root.globalDrawer = sidebarLoader.item;

            // remove the listview page, and restore all other pages
            listViewPageLoader.active = false;
            if (pageStack.currentItem == defaultPage) return;

            // go to correct sidebar page
            if (SettingsApp.activeModule.isInSubCategory) {
                sidebarLoader.item.goToSubCategoryPage();
            } else if (sidebarLoader.item) {
                sidebarLoader.item.goToMainPage();
            }

            // push default page if no kcm is loaded
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

            // insert subcategory page if necessary
            if (SettingsApp.activeModule.isInSubCategory) {
                narrowSubCategoryPageLoader.pushSubCategoryPage();
            }

            // restore the kcm page
            if (SettingsApp.activeModule.name && root.loadedKCMPage) {
                root.pageStack.push(root.loadedKCMPage);
            }
        }
    }

    // Narrow mode (sidebar becomes a page)
    Loader {
        id: listViewPageLoader
        active: false

        sourceComponent: SidebarCategoriesPage {
            onDelegateClicked: (index, pluginId, isCategory) => {
                if (isCategory) {
                    // Load module, but don't show page
                    SettingsApp.loadModule(index);
                    narrowSubCategoryPageLoader.pushSubCategoryPage();
                } else {
                    applicationWindow().openModule(index);
                }
            }
        }
    }

    Loader {
        id: narrowSubCategoryPageLoader
        active: listViewPageLoader.active

        function pushSubCategoryPage() {
            if (applicationWindow().pageStack.items.includes(narrowSubCategoryPageLoader.item)) {
                applicationWindow().pageStack.currentIndex = 1;
            } else {
                applicationWindow().pageStack.push(item);
            }
        }

        sourceComponent: SidebarSubCategoryPage {
            onPopPage: applicationWindow().pageStack.currentIndex = 0;
        }
    }

    // Widescreen mode
    Loader {
        id: sidebarLoader
        active: false
        sourceComponent: Sidebar {}
    }

    function openModule(index) {
        SettingsApp.loadModule(index);
        console.log('load new module ' + index);

        clearKCMPages();
        loadActiveKCMPage();
    }

    function clearKCMPages() {
        while (pageStack.depth > root.popKCMDepth()) {
            pageStack.pop();
        }
    }

    function loadActiveKCMPage() {

        // Push category page if it is a subcategory
        if (!SettingsApp.singleModule) {
            if (SettingsApp.activeModule.isInSubCategory) {
                if (root.isWidescreen) {
                    sidebarLoader.item.goToSubCategoryPage();
                } else {
                    narrowSubCategoryPageLoader.pushSubCategoryPage();
                }
            } else {
                if (root.isWidescreen) {
                    sidebarLoader.item.goToMainPage();
                }
            }
        }

        // only add the page if it is valid
        if (SettingsApp.activeModule.valid) {
            loadedKCMPage = kcmContainer.createObject(
                pageStack,
                {"kcm": SettingsApp.activeModule.kcm, "internalPage": SettingsApp.activeModule.kcm.mainUi}
            );
            pageStack.push(loadedKCMPage);
        } else if (isWidescreen) {
            pageStack.push(defaultPage);
        }
    }

    // if module is specified to be opened, load it
    Component.onCompleted: {
        changeNav(isWidescreen);

        if (SettingsApp.startModule.length > 0) {
            clearKCMPages();
            loadActiveKCMPage();
        }
    }

    Connections {
        target: SettingsApp

        function onModuleChangeRequested() {
            clearKCMPages();
            loadActiveKCMPage();
        }

        function onActivateRequested() {
            // HACK: raise window when module is requested;
            // requestActivate() by itself doesn't seem to work
            applicationWindow().hide();
            applicationWindow().show();
            applicationWindow().requestActivate();
        }
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
