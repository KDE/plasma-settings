/*

    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

import org.kde.plasma.settings
import "components"

Kirigami.AbstractApplicationWindow {
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

    pageStack: PageStack {}

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

            // pop all pages
            pageStack.clear();

            // remove the listview page
            listViewPageLoader.active = false;

            // restore the kcm page
            if (SettingsApp.activeModule.name && root.loadedKCMPage) {
                pageStack.push(root.loadedKCMPage, null, QQC2.StackView.Immediate);
            }

            // go to correct sidebar page
            if (SettingsApp.activeModule.isInSubCategory) {
                sidebarLoader.item.goToSubCategoryPage();
            } else if (sidebarLoader.item) {
                sidebarLoader.item.goToMainPage();
            }

            // push default page if no kcm is loaded
            if (pageStack.depth == 0) {
                pageStack.push(defaultPage, QQC2.StackView.Immediate);
            }
        } else {
            sidebarLoader.active = false;
            root.globalDrawer = null;

            // pop all pages
            pageStack.clear();

            // insert listview page at beginning
            listViewPageLoader.active = true;
            pageStack.push(listViewPageLoader.item, null, QQC2.StackView.Immediate);

            // insert subcategory page if necessary
            if (SettingsApp.activeModule.isInSubCategory) {
                pageStack.push(narrowSubCategoryPageLoader.item, null, QQC2.StackView.Immediate);
            }

            // restore the kcm page
            if (SettingsApp.activeModule.name && root.loadedKCMPage) {
                pageStack.push(root.loadedKCMPage, null, QQC2.StackView.Immediate);
            }
        }
    }

    // ListView categories page (when in narrow mode, not sidebar)
    Loader {
        id: listViewPageLoader
        active: false

        sourceComponent: SidebarCategoriesPage {
            onDelegateClicked: (index, pluginId, isCategory) => {
                if (isCategory) {
                    // Load module, but don't show page
                    SettingsApp.loadModule(index);
                    applicationWindow().pageStack.push(narrowSubCategoryPageLoader.item);
                } else {
                    applicationWindow().openModule(index);
                }
            }
        }
    }

    // ListView subcategories page (when in narrow mode, not sidebar)
    Loader {
        id: narrowSubCategoryPageLoader
        active: listViewPageLoader.active

        sourceComponent: SidebarSubCategoryPage {
            onPopPage: applicationWindow().pageStack.pop()
        }
    }

    // Sidebar for when in widescreen mode
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
            if (pageStack.depth === 1) {
                pageStack.clear();
            } else {
                pageStack.pop();
            }
        }
    }

    function loadActiveKCMPage() {

        // Push category page if it is a subcategory
        if (!SettingsApp.singleModule) {
            if (SettingsApp.activeModule.isInSubCategory) {
                if (root.isWidescreen) {
                    sidebarLoader.item.goToSubCategoryPage();
                } else {
                    // Only push subcategory page if it isn't on the stack
                    if (pageStack.depth < root.popKCMDepth()) {
                        pageStack.push(narrowSubCategoryPageLoader.item, null, QQC2.StackView.Immediate);
                    }
                }
            } else {
                if (root.isWidescreen) {
                    sidebarLoader.item.goToMainPage();
                }
            }
        }

        // Only add the kcm page if it is valid
        if (SettingsApp.activeModule.valid) {
            // Destroy old kcm page
            if (loadedKCMPage) {
                loadedKCMPage.destroy();
            }

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

    readonly property real pageHeaderTextHeight: pageHeaderTextMetrics.height

    QQC2.Control {
        id: pageHeaderTextMetrics
        padding: 0
        visible: false
        contentItem: Kirigami.Heading {
            id: textMetrics
            text: 'Text' // placeholder
            maximumLineCount: 1
            elide: Text.ElideRight
            textFormat: Text.PlainText
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
