import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Controls

import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Scope {
    Variants {
        model: Quickshell.screens
        StyledPanel {
            id: root
            name: "aiBar"
            property var reg: ({
                    "todo": "/",
                    "timer": "~",
                    "search": "?",
                    "shell": "!",
                    "translate": ">",
                    "ai": ""
                })
            property string state: "ai"
            property string query: ""
            property bool clearBeforeSend: false
            property bool top: false
            property bool revealLauncherOnAction: true
            property var modelData
            property bool reveal: GlobalStates.showAiBar
            visible: reveal
            anchors.bottom: !top
            anchors.top: top
            implicitWidth: Appearance.sizes.aiBarSize.width
            implicitHeight: Appearance.sizes.aiBarSize.height + Appearance.sizes.elevationMargin
            kbFocus: true
            exclusiveZone: -1

            Timer {
                id: idleTimer
                repeat: true
                running: root.visible && query.length < 1
                interval: 4000
                onTriggered: root.hide()
            }

            Timer {
                id: screenshotProcessTimer
                interval: 200  // Wait for cliphist to update
                property bool autoSend: false
                onTriggered: processScreenshot(autoSend)
            }

            HyprlandFocusGrab {
                id: grab

                windows: [root]
                active: root.visible
                onCleared: root.hide()
            }
            mask: Region {
                item: bg
            }

            Connections {
                target: ScreenShotService

                function onScreenshotCompleted() {
                    screenshotProcessTimer.start();
                }
            }

            Connections {
                target: Cliphist

                function onImageDecoded(path) {
                    if (path) {
                        root.revealSidebar();
                        Ai.attachFile(path);

                        if (screenshotProcessTimer.autoSend) {
                            Ai.sendUserMessage("Explain This Briefly");
                        }
                    }
                }
            }

            function processScreenshot(autoSend) {
                Cliphist.getLatestImage();  // Triggers async decode, fires imageDecoded signal
            }

            function revealSidebar() {
                Mem.states.sidebarLauncher.apis.selectedTab = 0;
                Noon.callIpc("sidebar_launcher reveal API");
            }

            function handleImage(autoSend = false) {
                screenshotProcessTimer.autoSend = autoSend;
                ScreenShotService.takeScreenShot();
            }

            function hide() {
                GlobalStates.showAiBar = false;
            }

            function sendMessage() {
                root.processQuery();
                const text = inputField.text.trim();
                const prefixLength = reg[root.state]?.length || 0;
                const cleanQuery = text.substring(prefixLength).trim();

                switch (root.state) {
                case "ai":
                    if (root.clearBeforeSend) {
                        Ai.clearMessages();
                    }
                    root.revealSidebar();
                    Ai.sendUserMessage(root.query);
                    break;
                case "timer":
                    const duration = TimerService.parseTimeString(cleanQuery);
                    if (duration > 0) {
                        const id = TimerService.addTimer("Focus Time", duration);
                        TimerService.startTimer(id);
                        if (root.revealLauncherOnAction) {
                            Mem.states.sidebarLauncher.misc.selectedTabIndex = 2;
                            Noon.callIpc("sidebar_launcher reveal Misc");
                        }
                    }
                    break;
                case "todo":
                    if (cleanQuery.length > 0) {
                        TodoService.addTask(cleanQuery);
                    }
                    break;
                case "shell":
                    if (cleanQuery.length > 0) {
                        Noon.callIpc(cleanQuery);
                    }
                    break;
                case "search":
                    if (cleanQuery.length > 0) {
                        Noon.execDetached(["xdg-open", `https://www.google.com/search?q=${cleanQuery}`]);
                    }
                    break;
                case "translate":
                    console.log(hintText.text);
                    Cliphist.copy(hintText.text);
                    break;
                }

                root.query = "";
                root.hide();
            }
            function handleHintText() {
                if (root.state === "translate") {
                    TranslatorService.translate(root.query.substring(1));
                }
                return TranslatorService.translatedText;
            }
            function processQuery() {
                const text = inputField.text.trim();
                if (text.startsWith(reg.timer)) {
                    root.state = "timer";
                } else if (text.startsWith(reg.todo)) {
                    root.state = "todo";
                } else if (text.startsWith(reg.shell)) {
                    root.state = "shell";
                } else if (text.startsWith(reg.search)) {
                    root.state = "search";
                } else if (text.startsWith(reg.translate)) {
                    root.state = "translate";
                } else {
                    root.state = "ai";
                }
            }
            StyledRect {
                id: bg
                anchors {
                    fill: parent
                    topMargin: !root.top ? 0 : Appearance.sizes.elevationMargin
                    bottomMargin: root.top ? 0 : Appearance.sizes.elevationMargin
                }
                states: [
                    State {
                        name: "ai"
                        when: root.state === "ai"
                        PropertyChanges {
                            target: icon
                            text: "search"
                            shape: MaterialShape.Shape.Ghostish
                        }
                        PropertyChanges {
                            target: inputField
                            placeholderText: "Ask Any Thing .."
                        }
                        PropertyChanges {
                            target: hintText
                            visible: false
                        }

                        PropertyChanges {
                            target: osrButton
                            visible: true
                        }
                    },
                    State {
                        name: "timer"
                        when: root.state === "timer"
                        PropertyChanges {
                            target: icon
                            text: "timer"
                            shape: MaterialShape.Shape.Clover8Leaf
                        }
                        PropertyChanges {
                            target: inputField
                            placeholderText: "How Long .."
                        }
                        PropertyChanges {
                            target: osrButton
                            visible: false
                        }
                        PropertyChanges {
                            target: hintText
                            visible: false
                        }
                    },
                    State {
                        name: "todo"
                        when: root.state === "todo"
                        PropertyChanges {
                            target: icon
                            text: "task_alt"
                            shape: MaterialShape.Shape.Cookie4Sided
                        }
                        PropertyChanges {
                            target: inputField
                            placeholderText: "Any plans ..?"
                        }
                        PropertyChanges {
                            target: osrButton
                            visible: false
                        }
                        PropertyChanges {
                            target: hintText
                            visible: false
                        }
                    },
                    State {
                        name: "shell"
                        when: root.state === "shell"
                        PropertyChanges {
                            target: icon
                            text: "moon_stars"
                            shape: MaterialShape.Shape.Pentagon
                        }
                        PropertyChanges {
                            target: inputField
                            placeholderText: "Just Order ..?"
                        }
                        PropertyChanges {
                            target: osrButton
                            visible: false
                        }
                        PropertyChanges {
                            target: hintText
                            visible: false
                        }
                    },
                    State {
                        name: "search"
                        when: root.state === "search"
                        PropertyChanges {
                            target: icon
                            text: "api"
                            shape: MaterialShape.Shape.Pentagon
                        }
                        PropertyChanges {
                            target: inputField
                            placeholderText: "Lookup Online ..?"
                        }
                        PropertyChanges {
                            target: hintText
                            visible: false
                        }
                        PropertyChanges {
                            target: osrButton
                            visible: false
                        }
                    },
                    State {
                        name: "translate"
                        when: root.state === "translate"
                        PropertyChanges {
                            target: icon
                            text: "g_translate"
                            shape: MaterialShape.Shape.Puffy
                        }
                        PropertyChanges {
                            target: inputField
                            placeholderText: "Translate ..?"
                        }
                        PropertyChanges {
                            target: hintText
                            visible: true
                        }
                        PropertyChanges {
                            target: osrButton
                            visible: false
                        }
                    }
                ]
                radius: Appearance.rounding.large
                color: Appearance.colors.colLayer0
                enableShadows: true
                enableBorders: true
                clip: true
                StyledRect {
                    id: sideRect
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                        margins: 2
                    }
                    enableShadows: true
                    color: Appearance.colors.colLayer2
                    implicitWidth: 60
                    MaterialShapeWrappedMaterialSymbol {
                        id: icon

                        anchors {
                            centerIn: parent
                            horizontalCenterOffset: Appearance.padding.tiny
                        }
                        implicitSize: 45
                        iconSize: 24
                        text: "search"
                        fill: 1
                        shape: MaterialShape.Shape.Ghostish
                        colSymbol: inputField.focus ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer3
                        color: inputField.focus ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer3
                    }
                }
                TextField {
                    id: inputField
                    anchors {
                        top: parent.top
                        right: buttonsRow.left
                        left: sideRect.right
                        bottom: parent.bottom

                        rightMargin: Appearance.padding.large
                        leftMargin: Appearance.padding.large
                    }
                    focus: grab.active
                    objectName: "inputField"
                    placeholderText: "Ask any thing ..."
                    text: root.query
                    background: null
                    selectionColor: Appearance.colors.colPrimaryContainer
                    selectedTextColor: Appearance.colors.m3.m3onPrimaryContainer
                    color: Appearance.colors.colOnLayer0
                    placeholderTextColor: Appearance.colors.colSubtext
                    selectByMouse: true
                    onTextChanged: {
                        root.query = text;
                        root.processQuery();
                    }
                    StyledText {
                        id: hintText
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            rightMargin: Appearance.padding.normal
                        }
                        font.pixelSize: Appearance.fonts.sizes.normal
                        color: Appearance.colors.colSubtext
                        opacity: 0.6
                        text: root?.handleHintText() ?? ""
                    }
                    font {
                        pixelSize: Appearance.fonts.sizes.normal
                        family: Appearance.fonts.family.main
                    }
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            GlobalStates.showAiBar = false;
                            event.accepted = true;
                        }
                        if (event.key === Qt.Key_Return) {
                            root.sendMessage();
                            event.accepted = true;
                        }

                        if (event.modifiers === Qt.ControlModifier) {
                            if (event.key === Qt.Key_S) {
                                root.handleImage(true);
                                event.accepted = true;
                            }
                        }
                    }
                }
                RowLayout {
                    id: buttonsRow
                    spacing: Appearance.padding.small
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right

                        margins: Appearance.padding.small
                    }

                    RippleButtonWithIcon {
                        id: sendButton
                        releaseAction: () => root.sendMessage()
                        visible: opacity > 0
                        opacity: inputField.text.length > 0 ? 1 : 0
                        materialIcon: "send"
                        implicitSize: 45
                        Behavior on opacity {
                            Anim {}
                        }
                    }
                    RippleButtonWithIcon {
                        id: osrButton
                        releaseAction: () => root.handleImage(false)
                        materialIcon: "screenshot_region"
                        implicitSize: 45
                        enabled: !ScreenShotService.isBusy
                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }
        }
    }
}
