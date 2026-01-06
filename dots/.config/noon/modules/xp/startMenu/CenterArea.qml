import "../common"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services

StyledRect {
    id: centerArea
    color: "#D5E9FE"
    Layout.margins: 2
    Layout.fillHeight: true
    Layout.fillWidth: true
    RowLayout {
        anchors.fill: parent
        spacing: 0
        property real entireWidth: root.width
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            ColumnLayout {
                anchors.fill: parent
                AppsListGenerator {
                    model: Mem.states.favorites.apps.slice(0, 2)
                }
                ListSeparator {}
                AppsListGenerator {
                    viewScale: 0.8
                    bgHeight: 65
                    model: Mem.states.favorites.recentApps.slice(0, 5)
                }
                Spacer {}
            }
        }
        StyledRect {
            implicitWidth: 2
            Layout.fillHeight: true
            color: "#A9BEDA"
        }
        StyledRect {
            Layout.preferredWidth: XSizes.startMenu.rightSideWidth
            Layout.fillHeight: true
            color: "#D5E9FE"
            ColumnLayout {
                anchors.fill: parent
                AppsListGenerator {
                    viewScale: 0.9
                    bgHeight: 65
                    model: Mem.states.favorites.fastLaunchApps.slice(0, 3)
                }
                ListSeparator {
                    accent: "#AECFFF"
                }
                Spacer {}
            }
        }
    }
    StyledRect {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 4
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0
                color: "#5178B1"
            }
            GradientStop {
                position: 0.5
                color: "#F1A40F"
            }
            GradientStop {
                position: 1
                color: "#5178B1"
            }
        }
    }
}
