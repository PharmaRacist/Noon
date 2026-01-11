import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

StyledPopup {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        implicitWidth: 350

        // Header
        Row {
            spacing: 6

            Symbol {
                anchors.verticalCenter: parent.verticalCenter
                fill: 0
                font.weight: Font.Medium
                text: NetworkService.materialSymbol
                font.pixelSize: Fonts.sizes.large
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Network"
                color: Colors.m3.m3onSurfaceVariant
                font.weight: Font.Medium
                font.pixelSize: Fonts.sizes.large
            }

        }

        // Connection Type
        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: NetworkService.ethernet ? "lan" : "wifi"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Connection:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: NetworkService.ethernet ? "Ethernet" : NetworkService.wifi ? "Wi-Fi" : "Disconnected"
            }

        }

        // Network Name
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: NetworkService.networkName.length > 0

            Symbol {
                text: "router"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Network:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: NetworkService.networkName
                elide: Text.ElideRight
            }

        }

        // Signal Strength (Wi-Fi only)
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: NetworkService.wifi && NetworkService.networkStrength > 0

            Symbol {
                text: "signal_cellular_alt"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Signal:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: NetworkService.networkStrengthText
            }

        }

        // Download Speed
        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: "download"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Download:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: NetworkService.downloadSpeedText
            }

        }

        // Upload Speed
        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            Symbol {
                text: "upload"
                color: Colors.m3.m3onSurfaceVariant
                font.pixelSize: Fonts.sizes.large
            }

            StyledText {
                text: qsTr("Upload:")
                color: Colors.m3.m3onSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: Colors.m3.m3onSurfaceVariant
                text: NetworkService.uploadSpeedText
            }

        }

    }

}
