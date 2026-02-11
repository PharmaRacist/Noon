import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.common
import qs.common.widgets

RowLayout {
    Layout.fillWidth: true
    Layout.maximumHeight: 60
    spacing: Padding.huge
    Item {
        Layout.fillHeight: true
        Layout.preferredWidth: height
        StyledImage {
            id: distIcon
            source: "file://" + Directories.assets + "/icons/" + SysInfoService.distroIcon
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            sourceSize: Qt.size(width, height)
            layer.enabled: true
        }
        ColorOverlay {
            anchors.fill: distIcon
            source: distIcon
            color: Colors.colPrimary
        }
    }
    ColumnLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        spacing: 0
        StyledText {
            text: SysInfoService.username.charAt(0).toUpperCase() + SysInfoService.username.slice(1)
            color: Colors.colOnLayer0
            font.pixelSize: Fonts.sizes.large
            font.letterSpacing: 1.5
            font.weight: 900
            font.family: Fonts.family.monospace
        }

        StyledText {
            text: SysInfoService.distroName.charAt(0).toUpperCase() + SysInfoService.distroName.slice(1)
            color: Colors.colSubtext
            font.pixelSize: Fonts.sizes.small
            font.letterSpacing: 1.5
            font.weight: 900
            font.family: Fonts.family.monospace
        }
    }
    Spacer {}
}
