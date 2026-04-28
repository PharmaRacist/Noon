import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

StyledRect {
    property var account: SysInfoService.oauthData[0]?.account ?? {}
    color: Colors.colLayer2
    radius: Rounding.verylarge

    Layout.fillWidth: true
    height: 80
    RowLayout {
        anchors.fill: parent
        spacing: Padding.huge
        StyledRect {
            implicitSize: 60
            color: Colors.colLayer1
            radius: Rounding.full
            clip: true
            CroppedImage {
                anchors.fill: parent
                visible: account.image.length > 0
                width: height
                source: account?.image
            }
            Symbol {
                anchors.centerIn: parent
                font.pixelSize: 28
                color: Colors.colOnLayer2
                fill: 1
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            spacing: 0
            StyledText {
                truncate: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: account.name
                color: Colors.colOnLayer2
                font.pixelSize: Fonts.sizes.huge
                font.variableAxes: Fonts.variableAxes.title
            }

            StyledText {
                truncate: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: account.handler
                color: Colors.colSubtext
                font.pixelSize: Fonts.sizes.small
                font.variableAxes: Fonts.variableAxes.title
            }
        }
    }
}
