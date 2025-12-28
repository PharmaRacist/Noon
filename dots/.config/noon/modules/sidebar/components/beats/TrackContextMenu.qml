import QtQuick
import QtQuick.Controls
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Menu {
    id: contextMenu

    // Properties to be set from parent
    property string trackPath: ""
    property string trackName: ""
    property var musicModel: null
    property var onRefresh: null
    property var parentButton: null

    // Custom popup function with positioning
    function showMenu() {
        // Position at mouse or parent
        if (parentButton) {
            x = parentButton.width / 2;
            y = parentButton.height;
        }
        // Try both methods
        if (typeof popup === "function")
            popup();
        else if (typeof open === "function")
            open();
        else
            visible = true;
    }

    // Make sure menu is visible
    visible: false
    // Size properties
    width: 200
    modal: true
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Play Track
    TMItem {
        text: qsTr("Play")
        materialIcon: "play_arrow"
        height: 40
        onTriggered: () => {
            if (trackPath)
                BeatsService.playTrack(trackPath, musicModel);
        }

    }

    // Share via KDE Connect
    TMItem {
        text: qsTr("Share")
        materialIcon: "share"
        enabled: KdeConnectService.selectedDeviceId !== ""
        onTriggered: {
            if (trackPath)
                KdeConnectService.shareFile(KdeConnectService.selectedDeviceId, trackPath);
        }

    }

    // Show in File Manager
    TMItem {
        text: qsTr("Show in Files")
        materialIcon: "folder_open"
        onTriggered: {
            if (trackPath) {
                const dirPath = trackPath.substring(0, trackPath.lastIndexOf('/'));
                Qt.openUrlExternally("file://" + dirPath);
            }
        }
    }

    background: StyledRect {
        color: TrackColorsService.colors.colLayer2
        radius: Rounding.large
        enableShadows: true
    }

    component TMItem:StyledMenuItem {
        id:root
        colBackground:TrackColorsService.colors.colLayer1
        colBackgroundHover:TrackColorsService.colors.colLayer1Hover
        colBackgroundActive:TrackColorsService.colors.colSecondaryContainer
        colContent:TrackColorsService.colors.colOnLayer1
        colContentActive:TrackColorsService.colors.colOnSecondaryContainer
    }
}
