import "../common"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import qs
import qs.services
import qs.common
import qs.common.widgets

StyledPanel {
    id: root

    property bool top: false

    visible: true
    name: "bar"
    shell: "xp"
    implicitHeight: XSizes.taskbar.height  || 49
    exclusiveZone: implicitHeight

    anchors {
        top: root.top
        left: true
        right: true
        bottom: !root.top
    }

    StyledRect {
        id: taskbar

        anchors {
            bottom: root.top ? parent.top : parent.bottom
            right:parent.right
            left:parent.left
        }
        implicitHeight:XSizes.taskbar.height
        color: XColors.colors.primaryContainer
        enableShadows:true
        Border {
            color:XColors.colors.primaryBorder
        }
        RowLayout {
            id: content

            spacing: XPadding.normal

            anchors {
                fill: parent
            }
            // Inner Glow Here
            StyledRect {
                id: startMenu

                Layout.fillHeight: true
                implicitWidth: 180
                color: XColors.colors.tertiary
                rightRadius: 15
                enableShadows: true
                Border {
                    rightRadius: 10
                    color:XColors.colors.tertiaryBorder
                    anchors.rightMargin:startMenu.rightRadius / 1.6
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    verticalOffset: 4
                    horizontalOffset:3
                    color: XColors.colors.shadows
                    samples: 4
                    radius: 5
                }

                // Need Shadows Below Content
                RowLayout {
                    anchors {
                        horizontalCenterOffset: -XPadding.verysmall
                        centerIn: parent
                    }
                    spacing: XPadding.tiny
                    Image {
                        clip:true
                        sourceSize:Qt.size(36,36)
                        source:Directories.assets + "/icons/xp_logo.png"
                        layer.enabled: true
                        layer.effect: DropShadow {
                            verticalOffset: 4
                            horizontalOffset:3
                            color: XColors.colors.shadows
                            radius: 4
                            samples: 2
                        }

                    }
                    StyledText {
                        text: "Start"
                        layer.enabled: true
                        layer.effect: DropShadow {
                            verticalOffset: 4
                            horizontalOffset:3
                            color: XColors.colors.shadows
                            radius: 3
                            samples: 3
                        }

                        font {
                            weight: 700
                            family: XFonts.family.main
                            pixelSize: XFonts.sizes.huge
                        }

                    }

                }

            }
            // Implement
            RowLayout {
                id: pinnedAppsRow
                Layout.fillHeight:true
                implicitWidth:200
                property list<string> pinnedApps: ["firefox","dolphin"]
                Repeater {
                    model:pinnedAppsRow.pinnedApps
                    StyledIconImage {
                        implicitWidth: 18
                        implicitHeight: 18
                        source: AppSearch.guessIcon("firefox")
                    }
                }
            }
            // --> create currently running apps ["icon","name"]
            Spacer {
            }

            StyledRect {
                id: rightArea

                implicitWidth: Math.min(230)
                color: XColors.colors.secondary
                Layout.fillHeight: true
                Border {
                    color:XColors.colors.secondaryBorder
                }
                StyledRect {
                    anchors.right:parent.right
                    implicitHeight:parent.height
                    implicitWidth:4
                    color:XColors.colors.primary
                    // TODO Better Logic
                    MouseArea { 
                        anchors.fill:parent
                        onEntered: Hyprland.dispatch("workspace special")
                        onExited: Hyprland.dispatch("workspace 1")
                        onClicked: Hyprland.dispatch("workspace special")
                    }
                }
                StyledRect {
                    id: separator

                    implicitHeight: parent.height
                    implicitWidth: 3
                    enableShadows: true
                    color: XColors.colors.shadows
                    opacity: 0.85
                    anchors {
                        left: parent.left
                    }
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: XColors.colors.shadows
                        samples: 7
                        radius: 5
                    }


                }
                RowLayout {
                    spacing:XPadding.small
                    anchors {
                        fill: parent
                        rightMargin: XPadding.normal
                    }

                    Spacer {
                    }
                    Tray {
                        bar:root
                    }
                    // Custom Icon usage here ..
                    StatusIcons {
                    }
                    Clock {
                    }

                }

            }

        }

    }

    component Border:StyledRect {
            id:root
            anchors {
                top:parent.top
                right:parent.right
                left:parent.left
            }
            height:2.9
        gradient: Gradient {
        GradientStop {
            position: 0.92
            color:root.color 
            }
        GradientStop {
            position: 0.08
            color:"transparent"
        }
    }

    }

}
