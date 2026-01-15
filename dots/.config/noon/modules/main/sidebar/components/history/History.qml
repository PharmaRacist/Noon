import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

StyledRect {
    id: root
    visible: opacity > 0
    opacity: width > 320 ? 1 : 0
    color: "transparent"
    radius: Rounding.verylarge

    property string searchQuery: ""

    signal searchFocusRequested
    signal contentFocusRequested
    signal dismiss

    anchors.fill: parent

    // --- Focus Control ---
    onContentFocusRequested: {
        if (listView.count > 0) {
            listView.currentIndex = 0;
            listView.forceActiveFocus();
        }
    }

    ScriptModel {
        id: filteredModel
        values: {
            const allResults = ClipboardService.entries || [];
            if (!allResults.length)
                return [];

            const mapped = allResults.map(str => {
                const id = Number(str.split("\t")[0]);
                const isImage = ClipboardService.entryIsImage(str);
                const content = StringUtils.cleanCliphistEntry(str);
                let displayName = content, imagePath = "";

                if (isImage) {
                    imagePath = '/tmp/cliphist-' + id + '.png';
                    displayName = content.split("]]")[1]?.trim() || "Image";
                }

                return {
                    cliphistRawString: str,
                    name: displayName,
                    searchText: displayName,
                    icon: isImage ? "image" : "content_paste",
                    type: isImage ? qsTr("Image") : `#${id}`,
                    id: id.toString(),
                    isImage: isImage,
                    imagePath: imagePath
                };
            });

            const query = root.searchQuery.trim();
            if (!query)
                return mapped;

            const fuzzyResults = Fuzzy.go(query, mapped, {
                key: 'searchText',
                threshold: -10000,
                limit: 50
            });

            return fuzzyResults.map(r => r.obj);
        }
    }

    StyledListView {
        id: listView
        anchors.fill: parent
        animateAppearance: true
        animateMovement: true
        popin: true
        anchors.margins: Padding.normal
        spacing: Padding.small
        clip: true
        model: filteredModel
        currentIndex: -1

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 150

        delegate: Loader {
            id: loader
            required property int index
            required property var modelData

            height: modelData.isImage ? 140 : 70
            width: listView.width - (modelData.isImage ? Padding.normal : 0)

            activeFocusOnTab: false
            sourceComponent: modelData.isImage ? imageComponent : textComponent
            onLoaded: if (item) {
                item.modelData = Qt.binding(() => loader.modelData);
                item.index = Qt.binding(() => loader.index);
                if (item.hasOwnProperty("selected")) {
                    item.selected = Qt.binding(() => listView.currentIndex === loader.index);
                }
            }
        }

        Component {
            id: imageComponent
            StyledRect {
                property int index
                property var modelData
                property bool selected: false
                anchors.fill: parent
                color: selected ? Colors.colSecondaryContainerActive : Colors.colLayer2
                radius: Rounding.small
                clip: true

                border.width: selected ? 2 : 0
                border.color: Colors.colPrimary

                StyledImage {
                    anchors.fill: parent
                    sourceSize: Qt.size(140, width)
                    source: Qt.resolvedUrl(modelData.imagePath)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                }
                StyledRect {
                    anchors.fill: parent
                    color: ColorUtils.transparentize(Colors.colPrimaryContainerHover, 0.85)
                    opacity: selected ? 1 : 0
                    MaterialShapeWrappedMaterialSymbol {
                        z: 9999
                        color: Colors.colPrimaryContainer
                        colSymbol: Colors.colOnPrimaryContainer
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: Padding.verylarge
                        }
                        text: "history"
                        padding: 16
                        iconSize: 24
                    }
                    StyledText {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            margins: Padding.verylarge
                        }
                        text: modelData.id
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        ClipboardService.copy(modelData.cliphistRawString);
                        root.dismiss();
                    }
                }
            }
        }

        Component {
            id: textComponent
            StyledDelegateItem {
                property int index
                property var modelData
                property bool selected: false
                toggled: selected

                shape: MaterialShape.Shape.Clover4Leaf
                title: modelData.name
                subtext: modelData.type
                materialIcon: "history"

                releaseAction: () => {
                    ClipboardService.copy(modelData.cliphistRawString);
                    Noon.playSound("event_accepted");
                    root.dismiss();
                }
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Up) {
                if (currentIndex <= 0) {
                    currentIndex = -1;
                    root.searchFocusRequested();
                } else {
                    currentIndex--;
                }
            } else if (event.key === Qt.Key_Down) {
                if (currentIndex < count - 1) {
                    currentIndex++;
                }
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (currentIndex >= 0) {
                    const selectedData = model.values[currentIndex];
                    ClipboardService.copy(selectedData.cliphistRawString);
                    Noon.playSound("event_accepted");
                    root.dismiss();
                }
            } else if (event.key === Qt.Key_Escape) {
                root.dismiss();
            } else
                return;

            event.accepted = true;
        }

        ScrollEdgeFade {
            target: listView
            anchors.fill: parent
        }
    }

    PagePlaceholder {
        shown: listView.count === 0
        title: qsTr("No history matches")
        icon: "history_toggle_off"
        anchors.centerIn: parent
    }
}
