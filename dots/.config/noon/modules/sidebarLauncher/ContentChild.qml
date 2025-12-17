import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import qs.store

ColumnLayout {
    id: panel

    // Required properties
    required property string category
    required property string searchText
    required property var dataModel
    required property var componentMap
    required property var parentRoot
    required property bool isAux
    property bool showContent
    property bool effectiveSearchable: category ? LauncherData.isSearchable(category) : false
    property alias searchInput: searchInput
    property real contentYOffset: 0
    property real contentOpacity: 1
    property string previousCategory: ""

    // Unified signals
    signal searchUpdated(string newText)
    signal contentFocusRequested
    signal searchFocusRequested
    spacing: Padding.large
    clip:true
    // Helper function to determine animation direction
    function getCategoryDirection(oldCat, newCat) {
        if (!oldCat || !newCat || oldCat === newCat)
            return 1;

        const categories = parentRoot?.categories || LauncherData?.categories || [];
        const oldIndex = categories.indexOf(oldCat);
        const newIndex = categories.indexOf(newCat);

        if (oldIndex !== -1 && newIndex !== -1) {
            return newIndex > oldIndex ? -1 : 1;
        }

        return 1; // Default to downward motion
    }

    // Trigger animation on category change
    onCategoryChanged: {
        if (category && category !== previousCategory && previousCategory !== "") {
            const direction = getCategoryDirection(previousCategory, category);
            // Set initial offset in the opposite direction so content slides in correctly
            // If going down the list (direction = 1), content should come from bottom (+100)
            // If going up the list (direction = -1), content should come from top (-100)
            contentYOffset = direction * 100;
            contentOpacity = 0;
            resetAnimation.restart();
        }
        previousCategory = category;
    }

    ParallelAnimation {
        id: resetAnimation

        Anim {
            target: panel
            property: "contentYOffset"
            to: 0
            duration: Animations.durations.expressiveDefaultSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.curves.emphasizedDecel
        }

        Anim {
            target: panel
            property: "contentOpacity"
            to: 1
            duration: Animations.durations.expressiveDefaultSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.curves.emphasizedDecel
        }
    }

    // Category Title
    // StyledText {
    //     visible: searchBar.visible
    //     text: category
    //     font.pixelSize: Fonts.sizes.veryhuge
    //     color: Colors.colOnLayer2
    //     Layout.alignment: Qt.AlignHCenter
    //     Layout.preferredHeight: effectiveSearchable ? implicitHeight : 0
    //     opacity: effectiveSearchable ? contentOpacity : 0
    //     transform: Translate {
    //         y: contentYOffset * 0.5
    //     }

    //     Behavior on Layout.preferredHeight {
    //         Anim {}
    //     }
    // }

    // Content Loader with placeholder support
    Loader {
        id: contentLoader
        Layout.fillWidth: true
        Layout.fillHeight: true
        focus: true
        asynchronous: isAux
        opacity: contentOpacity
        transform: Translate {
            y: contentYOffset
        }

        sourceComponent: {
            if (!category) {
                return null;
            } else if (category) {
                const componentName = LauncherData.getComponent(category);
                return componentMap[componentName] || null;
            } else if (dataModel.count === 0 && LauncherData.hasModel(category) && category !== "Gallery" && root.showContent) {
                return placeholderComponent;
            }
        }

        onLoaded: {
            if (item) {
                if ("model" in item)
                    item.model = dataModel;
                if ("selectedCategory" in item)
                    item.selectedCategory = Qt.binding(() => category);
                if ("searchQuery" in item)
                    item.searchQuery = Qt.binding(() => searchText);
                if ("expanded" in item) {
                    // Aux always collapsed, main follows parent's expanded state
                    if (isAux) {
                        item.expanded = false;
                    } else {
                        item.expanded = Qt.binding(() => parentRoot.expanded);
                    }
                }
                if ("panelWindow" in item && !isAux)
                    item.panelWindow = parentRoot.panelWindow;
                if ("sidebarMode" in item && !isAux)
                    item.sidebarMode = true;
            }
        }

        Connections {
            target: panel
            function onSearchFocusRequested() {
                if (!isAux && searchInput && effectiveSearchable) {
                    searchInput.forceActiveFocus();
                }
            }
            function onContentFocusRequested() {
                if (contentLoader.item && "contentFocusRequested" in contentLoader.item) {
                    contentLoader.item.contentFocusRequested();
                }
            }
        }

        Connections {
            target: contentLoader.item
            ignoreUnknownSignals: true

            function onSearchFocusRequested() {
                if (!isAux) {
                    panel.searchFocusRequested();
                }
            }

            function onAltLaunched(app) {
                LauncherData.altLaunch(app, isAux);
            }

            function onAppLaunched(app) {
                LauncherData.launch(category, app, parentRoot.switchToLayout, isAux);
            }
        }
    }
    // Search Bar
    StyledRect {
        id: searchBar
        visible: opacity > 0
        clip:true
        Layout.fillWidth: true
        Layout.alignment:Qt.AlignHCenter
        Layout.maximumWidth:LauncherData.sizePresets.quarter
        Layout.preferredHeight: effectiveSearchable ? 45 : 0
        Layout.margins: effectiveSearchable ? Padding.normal : 0
        radius: Rounding.normal
        color: Colors.colLayer1
        opacity: effectiveSearchable ? contentOpacity : 0
        transform: Translate {
            y: contentYOffset
        }

        Behavior on Layout.preferredHeight {
            Anim {}
        }
        Rectangle {
            id:sideRect
            anchors {
                top:parent.top
                bottom:parent.bottom
                left:parent.left
            }
            color:Colors.colSecondary
            implicitWidth: 40

            MaterialSymbol {
                anchors.centerIn:parent
                anchors.horizontalCenterOffset:Padding.tiny
                font.pixelSize: 20
                text: LauncherData.getIcon(category) || "apps"
                color: Colors.colOnSecondary
                opacity: 0.6
            }

        }
        RowLayout {
            anchors {
                top:parent.top
                right:parent.right
                bottom:parent.bottom
                left:sideRect.right
                leftMargin:Padding.normal
            }
            spacing: Padding.small

            TextField {
                id: searchInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                objectName: "searchInput"
                visible: effectiveSearchable
                enabled: effectiveSearchable
                text: searchText
                placeholderText: LauncherData.getPlaceholder(category) || "Search..."
                background: null
                selectionColor: Colors.colSecondaryContainer
                selectedTextColor: Colors.m3.m3onSecondaryContainer
                color: Colors.m3.m3onSurfaceVariant
                placeholderTextColor: Colors.m3.m3outline
                selectByMouse: true

                onTextChanged: {
                    panel.searchUpdated(text);
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down && effectiveSearchable || event.key === Qt.Key_PageDown && effectiveSearchable) {
                        panel.contentFocusRequested();
                        event.accepted = true;
                    }
                }

                font {
                    family: Fonts.family.main
                    pixelSize: Fonts.sizes.small
                }
            }

            RippleButton {
                buttonRadius: 12
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                visible: searchInput.text.length > 0
                colBackground: "transparent"
                MaterialSymbol {
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    text: "close"
                    color: Colors.m3.m3onSurfaceVariant
                }
                releaseAction: () => {
                    searchInput.clear();
                    if (!isAux) {
                        Qt.callLater(() => searchInput.forceActiveFocus());
                    }
                }
            }
        }
    }


    // Placeholder component definition
    Component {
        id: placeholderComponent

        PagePlaceholder {
            anchors.fill: parent
            anchors.centerIn: parent
            icon: "block"
            shape: MaterialShape.Clover4Leaf
            title: "Nothing found"
        }
    }

    // Close button (only for aux panel)
    RippleButton {
        visible: isAux
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width - Padding.veryhuge
        Layout.preferredHeight: 32
        buttonRadius: 16
        colBackground: Colors.colError
        colBackgroundHover: Colors.colErrorHover
        opacity: contentOpacity
        transform: Translate {
            y: contentYOffset
        }

        RowLayout {
            anchors.centerIn: parent

            MaterialSymbol {
                font.pixelSize: 20
                text: "close"
                color: Colors.m3.m3onError
            }
            StyledText {
                text: "Dismiss"
                color: Colors.m3.m3onError
            }
        }
        releaseAction: () => {
            if (isAux && parentRoot) {
                parentRoot.closeAuxPanel();
            }
        }
    }
}
