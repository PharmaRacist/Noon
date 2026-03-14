import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import "content"

Item {
    id: root
    required property var panel
    required property string state
    readonly property bool expanded: state === "expanded"

    RowLayout {
        anchors.fill: parent
        spacing: Padding.huge
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Rounding.huge
            color: Colors.colLayer0
            RowLayout {
                id: mainRow
                anchors.fill: parent
                anchors.margins: Padding.large
                spacing: Padding.large
                StyledRect {
                    visible: root.expanded
                    Layout.fillHeight: true
                    Layout.minimumWidth: 200
                    radius: Rounding.huge
                    enableBorders: true
                }
                ColumnLayout {
                    id: middleSection
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Padding.large

                    PFInfo {
                        Layout.alignment: Qt.AlignHCenter
                    }
                    StyledRect {
                        visible: root.expanded
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Rounding.huge
                        enableBorders: true
                    }
                }
                StyledRect {
                    visible: root.expanded
                    Layout.fillHeight: true
                    Layout.minimumWidth: 200
                    radius: Rounding.huge
                    enableBorders: true
                }
            }
        }
    }
}
