import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.services
import qs.store

Scope {
    id: root
    Variants {
        model: Quickshell.screens

        StyledPanel {
            id: bar_panel
            required property var modelData
            screen: modelData
            name: "bar"
            shell: "nobuntu"

            anchors {
                top: true
                right: true
                left: true
            }
            margins {
                left: -70
            }
            // WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: 40
            exclusiveZone: implicitHeight
            mask: Region {
                item: bg
            }

            StyledRect {
                id: bg
                anchors.fill: parent
                color: Colors.colLayer0
                GClock {}

                GWs {
                    bar: bar_panel
                }
                GSystemTray {
                    bar: bar_panel
                }
                GClipboard {
                    bar: bar_panel
                    anchors {
                        right: status_icons.left
                        rightMargin: Padding.large
                        top: parent.top
                        bottom: parent.bottom
                    }
                }
                GStatusIcons {
                    id: status_icons
                }
            }
        }
    }
}
