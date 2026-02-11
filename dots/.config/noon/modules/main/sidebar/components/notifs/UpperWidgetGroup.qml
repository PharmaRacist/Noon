import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services
import "quickToggles"
import "sliders"

Item {
    id: root

    property var panelWindow

    implicitHeight: contentLayout.implicitHeight + Padding.large
    Layout.fillWidth: true

    ColumnLayout {
        id: contentLayout

        spacing: Padding.normal

        anchors {
            fill: parent
            bottomMargin: Padding.large
            topMargin: Padding.normal
        }

        UptimeRow {}

        Group {
            visible: Mem.options.sidebar.appearance.showSliders ?? false
            Layout.preferredHeight: sliders.implicitHeight + sliders.anchors.margins
            ColumnLayout {
                id: sliders
                anchors.margins: Padding.huge
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Padding.verysmall
                Layout.rightMargin: Padding.normal

                BrightnessSlider {}
                VolumeOutputSlider {}
                VolumeInputSlider {}
            }
        }
        Group {
            Layout.preferredHeight: grid.implicitHeight + Padding.massive
            GridLayout {
                id: grid
                anchors.centerIn: parent
                columns: 2
                rowSpacing: Padding.normal
                columnSpacing: Padding.normal

                NetworkToggle {}

                BluetoothToggle {}

                NightLightToggle {}

                AppearanceToggle {}

                KdeConnectToggle {}

                TransparencyToggle {}
            }
        }
        Group {
            implicitHeight: row.implicitHeight + Padding.large
            RowLayout {
                id: row
                anchors.centerIn: parent
                spacing: Padding.small
                CaffieneToggle {}
                EasyEffectsToggle {}
                RecordToggle {}
                GameModeToggle {}
                InputToggle {}
                BacklightToggle {}
            }
        }
    }

    component UptimeRow: StyledText {
        font.pixelSize: Fonts.sizes.verylarge
        color: Colors.colOnLayer0
        text: StringUtils.format("Up for {0}", DateTimeService.uptime)
        Layout.preferredHeight: 35
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: Padding.large
    }
    component Group: StyledRect {
        Layout.fillWidth: true
        radius: Rounding.verylarge
        color: Colors.colLayer1
    }
}
