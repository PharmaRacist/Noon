import qs.services
import qs.common
import qs.common.widgets
import qs.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    property real maxWindowPreviewHeight: 216
    property real maxWindowPreviewWidth: 384
    property real windowControlsHeight: 30

    property Item lastHoveredButton
    property bool buttonHovered: false
    property bool requestDockShow: previewPopup.show
    property bool verticalMode: false
    property var pinnedApps: Mem.states.favorites.apps
    Layout.preferredWidth: listView.implicitWidth
    Layout.preferredHeight: listView.implicitHeight
    Layout.margins: Padding.normal

    StyledListView {
        id: listView
        spacing: height / 10
        orientation: ListView.Horizontal
        implicitWidth: contentWidth
        implicitHeight: Mem.options.dock.appearance.iconSize
        model: ScriptModel {
            objectProp: "appId"
            values: {
                var map = new Map();
                var pinnedAppIds = new Set();
                var runningAppIds = new Set();

                for (const appId of root.pinnedApps) {
                    const normalizedAppId = appId.toLowerCase();
                    pinnedAppIds.add(normalizedAppId);
                    if (!map.has(normalizedAppId)) {
                        map.set(normalizedAppId, {
                            appId: appId,
                            pinned: true,
                            toplevels: []
                        });
                    }
                }

                for (const toplevel of ToplevelManager.toplevels.values) {
                    const originalAppId = toplevel.appId;
                    const normalizedAppId = originalAppId.toLowerCase();
                    runningAppIds.add(normalizedAppId);
                    if (!map.has(normalizedAppId)) {
                        map.set(normalizedAppId, {
                            appId: originalAppId,
                            pinned: false,
                            toplevels: []
                        });
                    }
                    map.get(normalizedAppId).toplevels.push(toplevel);
                }

                const hasUnpinnedRunningApps = Array.from(runningAppIds).some(appId => !pinnedAppIds.has(appId));
                const shouldAddSeparator = root.pinnedApps.length > 0 && hasUnpinnedRunningApps;
                var values = [];

                for (const appId of root.pinnedApps) {
                    const normalizedAppId = appId.toLowerCase();
                    if (map.has(normalizedAppId)) {
                        const appData = map.get(normalizedAppId);
                        values.push({
                            appId: appData.appId,
                            toplevels: appData.toplevels,
                            pinned: appData.pinned
                        });
                        map.delete(normalizedAppId);
                    }
                }

                if (shouldAddSeparator) {
                    values.push({
                        appId: "SEPARATOR",
                        toplevels: [],
                        pinned: false
                    });
                }

                for (const [normalizedKey, appData] of map) {
                    if (appData.toplevels.length > 0) {
                        values.push({
                            appId: appData.appId,
                            toplevels: appData.toplevels,
                            pinned: appData.pinned
                        });
                    }
                }

                return values;
            }
        }

        delegate: DockAppButton {
            required property var modelData
            appToplevel: modelData
            appListRoot: root
        }
    }

    PopupWindow {
        id: previewPopup
        visible: false
        property var appTopLevel: root.lastHoveredButton?.appToplevel
        property bool allPreviewsReady: false
        property int readyCount: 0
        property int totalCount: 0

        Connections {
            target: root
            function onLastHoveredButtonChanged() {
                previewPopup.allPreviewsReady = false;
                previewPopup.readyCount = 0;
                previewPopup.totalCount = 0;
            }
        }

        function notifyViewReady() {
            readyCount++;
            if (totalCount > 0 && readyCount >= totalCount)
                allPreviewsReady = true;
        }

        function registerView(alreadyHasContent) {
            totalCount++;
            if (alreadyHasContent)
                notifyViewReady();
        }

        property bool shouldShow: (popupMouseArea.containsMouse || root.buttonHovered) && allPreviewsReady
        property bool show: false

        onShouldShowChanged: updateTimer.restart()

        Timer {
            id: updateTimer
            interval: 100
            onTriggered: previewPopup.show = previewPopup.shouldShow
        }
        anchor {
            window: root.QsWindow.window
            adjustment: PopupAdjustment.None
            gravity: Edges.Top | Edges.Right
            edges: Edges.Top | Edges.Right
        }
        // visible: popupBackground.visible
        color: "transparent"
        implicitWidth: Screen.width
        implicitHeight: popupMouseArea.implicitHeight + root.windowControlsHeight + Sizes.elevationMargin * 2

        MouseArea {
            id: popupMouseArea
            anchors.bottom: parent.bottom
            implicitWidth: popupBackground.implicitWidth + Sizes.elevationMargin * 2
            implicitHeight: root.maxWindowPreviewHeight + root.windowControlsHeight + Sizes.elevationMargin * 2
            hoverEnabled: true
            x: {
                if (!root.lastHoveredButton || root.lastHoveredButton.window === null)
                    return 0;
                var itemCenter = root.QsWindow.mapFromItem(root.lastHoveredButton, root.lastHoveredButton.width / 2, 0);
                return itemCenter.x - width / 2;
            }

            StyledRectangularShadow {
                target: popupBackground
                opacity: previewPopup.show ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    Anim {}
                }
            }

            StyledRect {
                id: popupBackground
                readonly property real padding: Padding.large
                opacity: previewPopup.show ? 1 : 0
                visible: opacity > 0
                clip: true
                color: Colors.colSurfaceContainer
                radius: Rounding.normal
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Sizes.elevationMargin
                anchors.horizontalCenter: parent.horizontalCenter
                implicitHeight: previewRowLayout.implicitHeight + padding * 2
                implicitWidth: previewRowLayout.implicitWidth + padding * 2

                RowLayout {
                    id: previewRowLayout
                    anchors.centerIn: parent
                    Repeater {
                        model: previewPopup.appTopLevel?.toplevels
                        RippleButton {
                            id: windowButton
                            required property var modelData
                            padding: 0
                            middleClickAction: () => windowButton.modelData?.close()
                            releaseAction: () => windowButton.modelData?.activate()

                            contentItem: ColumnLayout {
                                implicitWidth: screencopyView.implicitWidth
                                implicitHeight: screencopyView.implicitHeight

                                ButtonGroup {
                                    contentWidth: parent.width - anchors.margins * 2
                                    WrapperRectangle {
                                        Layout.fillWidth: true
                                        color: ColorUtils.transparentize(Colors.colSurfaceContainer)
                                        radius: Rounding.small
                                        margin: 5
                                        StyledText {
                                            Layout.fillWidth: true
                                            font.pixelSize: Fonts.sizes.small
                                            text: windowButton.modelData?.title
                                            elide: Text.ElideRight
                                            color: Colors.m3.m3onSurface
                                        }
                                    }
                                    GroupButton {
                                        id: closeButton
                                        colBackground: ColorUtils.transparentize(Colors.colSurfaceContainer)
                                        baseWidth: windowControlsHeight
                                        baseHeight: windowControlsHeight
                                        buttonRadius: Rounding.full
                                        contentItem: Symbol {
                                            anchors.centerIn: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            text: "close"
                                            font.pixelSize: Fonts.sizes.normal
                                            color: Colors.m3.m3onSurface
                                        }
                                        onClicked: windowButton.modelData?.close()
                                    }
                                }

                                StyledScreencopyView {
                                    id: screencopyView
                                    captureSource: windowButton?.modelData ?? null
                                    constraintSize: Qt.size(root.maxWindowPreviewWidth, root.maxWindowPreviewHeight)
                                    Component.onCompleted: previewPopup.registerView(hasContent)
                                    onHasContentChanged: {
                                        if (hasContent)
                                            previewPopup.notifyViewReady();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
