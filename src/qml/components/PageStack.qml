// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root
    anchors.fill: parent

    property var internalStackView: stackView

    // Recreation of StackView API
    readonly property bool busy: stackView.busy
    readonly property var currentItem: (stackView.currentItem instanceof PageContainer) ? stackView.currentItem.page : stackView.currentItem
    readonly property int depth: stackView.depth
    property alias initialItem: stackView.initialItem

    function clear(transition) {
        stackView.clear(transition);
    }

    function find(callback, behavior) {
        return stackView.find(callback, behavior);
    }

    function get(index, behavior) {
        return stackView.get(index, behavior);
    }

    function pop(item, operation) {
        return stackView.pop(item, operation);
    }

    function push(item, properties, operation) {
        // TODO support pushing multiple pages?

        let pageItem = __initItem(item, properties);
        if (pageItem instanceof Kirigami.Page) {
            // Wrap Kirigami pages in PageContainer
            // StackView manages deleting the item
            return stackView.push(pageContainer, {
                'page': pageItem,
                'autoDestroyPage': !(item instanceof Kirigami.Page)
            }, operation);
        } else {
            return stackView.push(pageItem, properties, operation);
        }
    }

    function replace(target, item, properties, operation) {
        let pageItem = __initItem(item, properties);

        if (pageItem instanceof Kirigami.Page) {
            // Wrap Kirigami pages in PageContainer
            // StackView manages deleting the item
            return stackView.replace(target, pageContainer, {
                'page': pageItem,
                'autoDestroyPage': !(item instanceof Kirigami.Page)
            }, operation);
        } else {
            return stackView.replace(target, __initItem(item, properties), properties, operation);
        }
    }

    function __initItem(item, properties) {
        let page = null;
        if (item.createObject) {
            page = item;
        } else if (typeof item === "string") {
            page = Qt.createComponent(item);
        } else if (typeof item === "object" && !(item instanceof Item) && item.toString !== undefined) {
            page = Qt.createComponent(item.toString());
        }

        if (page) {
            page = page.createObject(root, properties || {});
        } else {
            // item is already a page
            page = item;
            // Copy properties to the existing page
            for (const prop in properties) {
                if (page.hasOwnProperty(prop)) {
                    page[prop] = properties[prop];
                }
            }
        }
        return page;
    }

    readonly property real animationDistance: Kirigami.Units.gridUnit * 2

    Component {
        id: pageContainer
        PageContainer {
            pageStack: root
        }
    }

    T.StackView {
        id: stackView
        anchors.fill: parent
        focus: true

        Shortcut {
            sequences: [ StandardKey.Back ]
            onActivated: {
                if (stackView.depth > 1) {
                    stackView.pop();
                }
            }
        }

        Item {
            id: dragGestureArea
            width: 40

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // Drag gesture to dismiss page
            DragHandler {
                // acceptedDevices: PointerDevice.TouchScreen
                enabled: stackView.currentItem && stackView.currentItem.StackView.index > 0
                target: stackView.currentItem
                yAxis.enabled: false
                xAxis.enabled: true
                xAxis.minimum: 0
                xAxis.maximum: stackView.width

                property bool closing: false
                onActiveTranslationChanged: (t) => {
                    closing = t.x > 0;
                }
                onActiveChanged: {
                    if (active) {
                        swipeCloseAnim.stop();
                        swipeKeepAnim.stop();

                        // By default, StackView hides elements below
                        if (stackView.depth > 1) {
                            stackView.get(stackView.depth - 2).StackView.visible = true;
                        }
                    } else {
                        // Use our own animations for gestures rather than relying on provided ones
                        if (closing) {
                            swipeCloseAnim.restart();
                        } else {
                            swipeKeepAnim.restart();
                        }
                    }
                }
            }
        }

        ParallelAnimation {
            id: swipeCloseAnim
            onFinished: stackView.popCurrentItem(StackView.Immediate)

            NumberAnimation {
                target: stackView.currentItem
                property: 'x'
                to: (stackView.mirrored ? -1 : 1) * stackView.width
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: stackView.currentItem
                property: 'opacity'
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        NumberAnimation {
            id: swipeKeepAnim
            target: stackView.currentItem
            property: 'x'
            to: 0
            duration: Kirigami.Units.veryLongDuration
            easing.type: Easing.OutCubic
        }

        pushEnter: Transition {
            NumberAnimation {
                property: "x"
                from: (stackView.mirrored ? -1 : 1) * root.animationDistance
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0; to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
        pushExit: Transition {
            // Ensure that page can be seen
            NumberAnimation {
                property: "opacity"
                from: 1.0; to: 1.0
            }
        }
        popEnter: Transition {}
        popExit: Transition {
            NumberAnimation {
                property: "x"
                to: (stackView.mirrored ? -1 : 1) * root.animationDistance;
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 1.0; to: 0.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
        replaceEnter: Transition {
            NumberAnimation {
                property: "x"
                from: (stackView.mirrored ? -1 : 1) * root.animationDistance
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0; to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
        replaceExit: Transition {
            NumberAnimation {
                property: "x"
                from: 0
                to: (stackView.mirrored ? -1 : 1) * -root.animationDistance
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 1.0; to: 0.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
}
