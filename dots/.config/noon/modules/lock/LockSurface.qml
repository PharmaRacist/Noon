import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.modules.desktop.bg
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import qs.store

Rectangle {
    id: root

    required property LockContext context
    // Define blurred artwork source (fix for original code)
    property alias blurredArt: backgroundImage
    color: sideRect.color
    Image {
        id: backgroundImage

        z: 0
        anchors.fill: parent
        source: WallpaperService.currentWallpaper
        fillMode: Image.PreserveAspectCrop
        cache: true
        antialiasing: true
        asynchronous: true
        mipmap: true
        layer.enabled: true
        opacity: 0 // Initial opacity for fade-in

        layer.effect: MultiEffect {
            source: backgroundImage // Fixed: use the image itself
            saturation: 0.3
            blurEnabled: true
            blurMax: 75
            blur: 1
        }

        // Fade-in animation for backdrop
        Anim on opacity {
            from: 0
            to: 1
        }
    }

    RoundCorner {
        id: c1

        z: 99
        corner: cornerEnum.topRight
        color: sideRect.color
        size: Rounding.verylarge
        anchors {
            top: sideRect.top
            right: sideRect.left
        }
    }

    RoundCorner {
        id: c2

        z: 99
        corner: cornerEnum.bottomRight
        color: Colors.m3.m3surfaceContainerLow
        size: Rounding.verylarge

        anchors {
            bottom: sideRect.bottom
            right: sideRect.left
        }
    }

    // Visualizer {}
    StyledRect {
        id: sideRect

        z: 99
        color: Colors.m3.m3surfaceContainerLow
        implicitWidth: Math.round(Screen.width * 0.246)
        implicitHeight: Screen.height
        enableShadows: true
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: -implicitWidth
        }
        StyledRect {
            enableShadows: true
            color: Colors.m3.m3surfaceContainer
            radius: Rounding.verylarge
            anchors.fill: parent
            anchors.margins: Padding.verylarge
        }
        ColumnLayout {
            spacing: Padding.huge
            anchors {
                centerIn: parent
                margins: 40
                verticalCenterOffset: 0 // Centered vertically for balance
            }

            // Header section with subtle user indicator
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12
                StyledRect {
                    width: 320
                    height: 320
                    radius: width * Mem.options.Rounding.scale / 10
                    enableShadows: true
                    clip: true
                    color: Colors.colLayer2
                    MaterialSymbol {
                        z: 999
                        anchors.centerIn: parent
                        visible: image.status !== Image.Ready
                        text: "lock"
                        fill: 1
                        font.pixelSize: 125
                        color: Colors.colOnLayer2
                    }
                    Image {
                        id: image
                        fillMode: Image.PreserveAspectCrop
                        anchors.fill: parent
                        source: Directories.home + "/.face"
                        sourceSize: Qt.size(parent.size)
                    }
                }
            }
            Spacer {}

            Item {
                id: entryRect
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 280
                Layout.preferredHeight: 50 + Padding.normal
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Padding.normal
                    spacing: Padding.small

                    // Password input with enhanced styling
                    StyledRect {
                        id: inputContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        topLeftRadius: Rounding.normal
                        bottomLeftRadius: Rounding.normal
                        radius: enter.visible ? Rounding.tiny : Rounding.normal
                        color: Colors.m3.m3surfaceContainerHigh
                        enableShadows: true
                        TextField {
                            id: passwordBox

                            leftPadding: 30 + lockSymb.font.pixelSize
                            rightPadding: 30
                            topPadding: 0
                            bottomPadding: 0
                            focus: true
                            enabled: !root.context.unlockInProgress
                            echoMode: TextInput.Password
                            inputMethodHints: Qt.ImhSensitiveData
                            placeholderText: "Enter your password"
                            font.pixelSize: 16
                            color: Colors.m3.m3onSurface
                            selectionColor: Colors.m3.m3primary
                            onAccepted: root.context.tryUnlock()
                            onTextChanged: root.context.currentText = this.text
                            scale: focus ? 1.05 : 1
                            background: null // No default background

                            // Leading icon for security
                            MaterialSymbol {
                                id: lockSymb
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                text: "lock"
                                font.pixelSize: 20
                                color: parent.placeholderTextColor
                                visible: !parent.text.length
                            }

                            anchors {
                                fill: parent
                            }

                            Connections {
                                function onCurrentTextChanged() {
                                    passwordBox.text = root.context.currentText;
                                }

                                target: root.context
                            }

                            Behavior on scale {
                                Anim {}
                            }
                        }
                    }
                    StyledRect {
                        id: enter
                        property bool enabled: passwordBox.text.length > 0 && !root.context.unlockInProgress
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        radius: Rounding.tiny
                        topRightRadius: Rounding.normal
                        bottomRightRadius: Rounding.normal
                        enableShadows: true
                        color: enabled ? Colors.m3.m3primary : Colors.m3.m3surfaceVariant
                        Behavior on color {
                            CAnim {}
                        }
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "arrow_forward"
                            font.pixelSize: 24
                            color: parent.enabled ? Colors.m3.m3onPrimary : Colors.m3.m3onSurfaceVariant
                            fill: 1
                            Behavior on color {
                                CAnim {}
                            }
                        }
                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            onClicked: root.context.tryUnlock()
                        }
                    }
                }
            }
            // Enhanced unlock section with better focus states

            // Error label with better animation
            Label {
                id: errorLabel

                Layout.alignment: Qt.AlignHCenter
                visible: root.context.showFailure
                text: "Incorrect password"
                color: Colors.m3.m3error
                font.pixelSize: 14
                opacity: visible ? 1 : 0
                scale: visible ? 1 : 0.9

                Behavior on opacity {
                    Anim {}
                }

                Behavior on scale {
                    Anim {}
                }
            }

            Spacer {}
            Spacer {}

            QuickSettingsSplitButton {
                // Use computed color

                id: powerButtons
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter

                firstIcon: "power_settings_new"
                secondIcon: "restart_alt"
                thirdIcon: "sleep"
                // Core state for power mode (no search, always compact)
                enabled: true
                searchToggled: false
                secondActive: false
                buttonWide: 45
                thirdActive: false
                showThird: true
                searchText: ""
                // Customization for power buttons
                placeholderText: "Power"
                // Unused but predefined
                showPlaceHolder: false
                // Hide placeholder for compact power look
                thirdBgColor: defaultColors
                // Actions using predefined properties (via loginctl for system power control)
                firstAction: () => {
                    return Noon.exec("loginctl poweroff");
                }
                secondAction: () => {
                    return Noon.exec("reboot");
                }
                thirdAction: () => {
                    return Noon.exec("loginctl suspend");
                }
            }
        }

        // Slide-in animation for sidebar from right
        Anim on anchors.rightMargin {
            from: -sideRect.width
            to: 0
            duration: 800
            easing.type: Easing.InOutCubic
        }
    }

    // Enhanced clock with larger, modern styling - positioned for better coherence
    DesktopClock {
        id: clock
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: Padding.massive
            leftMargin: Padding.massive
        }
    }

    Behavior on opacity {
        Anim {}
    }
}
