import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: foldersTab

    property string musicDirectory: ""
    property string searchText: ""

    signal openFolder(string folderName)

    function filterFolders() {
        var filteredIndices = [];
        for (var i = 0; i < folderModel.count; i++) {
            var folderInfo = folderModel.getFolderInfo(i);
            if (foldersTab.searchText === "" || folderInfo.name.toLowerCase().includes(foldersTab.searchText.toLowerCase()))
                filteredIndices.push(i);

        }
        return filteredIndices;
    }

    // Folders model
    FolderListModel {
        id: folderModel

        function getFolderInfo(index) {
            if (index < 0 || index >= count)
                return {
                "name": "",
                "path": "",
                "fileUrl": ""
            };

            try {
                const fileName = get(index, "fileName") || "";
                const fileUrl = get(index, "fileUrl") || "";
                let filePath = fileUrl.toString().startsWith("file://") ? decodeURIComponent(fileUrl.toString().replace("file://", "")) : fileUrl.toString();
                return {
                    "name": fileName || "Unknown Folder",
                    "path": filePath,
                    "fileUrl": fileUrl
                };
            } catch (e) {
                return {
                    "name": "Unknown Folder",
                    "path": "",
                    "fileUrl": ""
                };
            }
        }

        folder: foldersTab.musicDirectory
        showDirs: true
        showFiles: false
        sortField: FolderListModel.Name
    }

    // Folders GridView
    GridView {
        id: folderGridView

        property var filteredIndices: foldersTab.filterFolders()

        anchors.fill: parent
        cellWidth: (parent.width / 2) - 15
        cellHeight: cellWidth
        clip: true
        model: filteredIndices.length
        onFilteredIndicesChanged: {
            model = filteredIndices.length;
        }

        Connections {
            function onSearchTextChanged() {
                folderGridView.filteredIndices = foldersTab.filterFolders();
            }

            target: foldersTab
        }

        delegate: Rectangle {
            id: folderDelegate

            property int originalIndex: folderGridView.filteredIndices[model.index] || 0
            property var folderInfo: folderModel.getFolderInfo(originalIndex)
            property string folderName: folderInfo.name || "Unknown Folder"

            width: folderGridView.cellWidth - 10
            height: folderGridView.cellHeight - 10
            radius: Rounding.normal
            color: folderMouseArea.containsMouse ? TrackColorsService.colors.colSecondaryContainerHover : folderMouseArea.pressed ? TrackColorsService.colors.colSecondaryContainerActive : TrackColorsService.colors.colLayer1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: TrackColorsService.colors.colSecondaryContainer
                    radius: 30
                    implicitHeight: 60
                    implicitWidth: 60

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "folder"
                        font.pixelSize: 32
                        color: TrackColorsService.colors.colPrimary
                    }

                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Fonts.sizes.normal
                    color: TrackColorsService.colors.colOnLayer1
                    opacity: 0.9
                    text: folderName
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    font.weight: Font.Medium
                }

            }

            MouseArea {
                id: folderMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    foldersTab.openFolder(folderName);
                }
            }

            Behavior on color {
                CAnim {}
            }

        }

    }

}
