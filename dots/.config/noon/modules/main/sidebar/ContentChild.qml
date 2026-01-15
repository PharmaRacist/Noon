import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services
import qs.store

Item {
    id: panel

    required property string category
    required property string searchText
    required property var parentRoot
    required property bool isAux
    property bool showContent
    property bool effectiveSearchable
    property alias searchInput: searchInput
    property real contentYOffset: 0
    property string previousCategory: ""
    property alias componentPath: contentLoader.source
    property alias contentOpacity: contentLoader.opacity
    property QtObject colors: Colors

    signal searchUpdated(string newText)
    signal contentFocusRequested
    signal searchFocusRequested

    function getCategoryDirection(oldCat, newCat) {
        if (!oldCat || !newCat || oldCat === newCat)
            return 1;

        const categories = SidebarData.enabledCategories || [];
        const oldIndex = categories.indexOf(oldCat);
        const newIndex = categories.indexOf(newCat);

        if (oldIndex !== -1 && newIndex !== -1)
            return newIndex > oldIndex ? -1 : 1;

        return 1;
    }

    onCategoryChanged: {
        if (category && category !== previousCategory && previousCategory !== "") {
            const direction = getCategoryDirection(previousCategory, category);
            contentYOffset = direction * 100;
            contentOpacity = 0;
            resetAnimation.restart();
        }
        previousCategory = category;
    }

    ColumnLayout {
        spacing: Padding.large
        clip: true
        anchors.fill: parent

        ParallelAnimation {
            id: resetAnimation
            Anim {
                target: panel
                property: "contentYOffset"
                to: 0
            }
            Anim {
                target: panel
                property: "contentOpacity"
                to: 1
            }
        }

        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true
            visible: !isAux && category !== ""
            asynchronous: isAux || SidebarData.isAsync(category)
            opacity: contentOpacity

            onLoaded: {
                if (item) {
                    if ("selectedCategory" in item)
                        item.selectedCategory = Qt.binding(() => category);

                    if ("searchQuery" in item)
                        item.searchQuery = Qt.binding(() => searchText);

                    if ("expanded" in item) {
                        item.expanded = isAux ? false : Qt.binding(() => parentRoot.expanded);
                    }
                    if ("panelWindow" in item && !isAux)
                        item.panelWindow = Qt.binding(() => parentRoot.panelWindow);

                    if ("sidebarMode" in item && !isAux)
                        item.sidebarMode = true;
                }
            }

            Connections {
                target: panel
                function onSearchFocusRequested() {
                    if (!isAux && searchInput && effectiveSearchable)
                        searchInput.forceActiveFocus();
                }
                function onContentFocusRequested() {
                    if (contentLoader.item && "contentFocusRequested" in contentLoader.item)
                        contentLoader.item.contentFocusRequested();
                }
            }

            Connections {
                target: contentLoader.item
                ignoreUnknownSignals: true
                function onSearchFocusRequested() {
                    if (!isAux)
                        panel.searchFocusRequested();
                }
                function onDismiss() {
                    parentRoot.dismiss();
                }
            }

            transform: Translate {
                y: contentYOffset
            }
        }

        StyledRect {
            id: searchBar
            visible: effectiveSearchable && category !== ""
            clip: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: SidebarData.sizePresets.quarter
            Layout.preferredHeight: effectiveSearchable ? 45 : 0
            Layout.margins: effectiveSearchable ? Padding.normal : 0
            radius: Rounding.normal
            color: panel.colors.colLayer1
            opacity: effectiveSearchable ? contentOpacity : 0

            Rectangle {
                id: sideRect
                color: panel.colors.colSecondary
                implicitWidth: 40
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }
                Symbol {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: Padding.tiny
                    font.pixelSize: 20
                    text: SidebarData.getIcon(category)
                    fill: 1
                    color: panel.colors.colOnSecondary
                    opacity: 0.6
                }
            }

            RowLayout {
                spacing: Padding.small
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    left: sideRect.right
                    leftMargin: Padding.normal
                }

                StyledTextField {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    objectName: "searchInput"
                    visible: effectiveSearchable
                    enabled: effectiveSearchable
                    text: searchText
                    placeholderText: "Search..."
                    placeholderTextColor: Colors.colOutline
                    background: null
                    selectionColor: panel.colors.colSecondaryContainer
                    selectedTextColor: Colors.colOnSecondaryContainer
                    color: Colors.colOnLayer1
                    selectByMouse: true
                    onTextChanged: panel.searchUpdated(text)
                    Keys.onPressed: event => {
                        if ((event.key === Qt.Key_Down || event.key === Qt.Key_PageDown) && effectiveSearchable) {
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
                    releaseAction: () => {
                        searchInput.clear();
                        if (!isAux)
                            Qt.callLater(() => searchInput.forceActiveFocus());
                    }
                    Symbol {
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        text: "close"
                        color: Colors.colOnLayer1
                    }
                }
            }

            transform: Translate {
                y: contentYOffset
            }
            Behavior on Layout.preferredHeight {
                Anim {}
            }
        }

        RippleButton {
            visible: isAux
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - Padding.veryhuge
            Layout.preferredHeight: 32
            buttonRadius: 16
            colBackground: panel.colors.colError
            colBackgroundHover: panel.colors.colErrorHover
            opacity: contentOpacity
            releaseAction: () => {
                if (isAux && parentRoot)
                    parentRoot.resetAux();
            }

            RowLayout {
                anchors.centerIn: parent
                Symbol {
                    font.pixelSize: 20
                    text: "close"
                    color: Colors.colOnError
                }
                StyledText {
                    text: "Dismiss"
                    color: Colors.colOnError
                }
            }
            transform: Translate {
                y: contentYOffset
            }
        }
    }
}
