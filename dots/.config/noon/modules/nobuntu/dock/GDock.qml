import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.utils
import qs.common.functions
import qs.common.widgets
import qs.services
import qs.store
import "./../common"

Scope {
    id: root
    Variants {
        model: Quickshell.screens

        StyledPanel {
            id: dock_panel
            required property var modelData
            screen: modelData
            name: "gdock"
            shell: "nobuntu"
            WlrLayershell.layer: WlrLayer.Top
            anchors {
                top: true
                left: true
                bottom: true
            }
            margins {
                top: 40
            }
            implicitWidth: 70 + 200
            exclusiveZone: 70

            mask: Region {
                item: bg
            }

            StyledRect {
                id: bg
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
                implicitWidth: 70
                color: ColorUtils.transparentize(Colors.colLayer0, 0.6)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: Padding.large
                    spacing: Padding.large
                    GDockAppsModel {}
                    Spacer {}
                    GDockActionButton {}
                }
            }
        }
    }
}
