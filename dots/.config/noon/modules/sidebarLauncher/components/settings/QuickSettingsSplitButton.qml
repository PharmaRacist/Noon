import QtQuick.Controls
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    // Essential properties only
    property string searchText: ""
    property bool enabled: true
    property bool searchToggled: false
    property bool secondaryActive: Persistence.dashboard.expandSettings
    property bool middleActive: false
    property bool showMiddle: true

    // UI constants
    readonly property int buttonHeight: 45
    readonly property int buttonRadius: 99
    readonly property int buttonSmallRadius: 4
    readonly property int buttonWide: 100
    readonly property int buttonExpanded: 210
    readonly property int transitionDuration: 200

    // Signals
    signal primaryClicked
    signal secondaryClicked
    signal secondaryRightClicked
    signal middleClicked
    signal searchChanged(string text)

    implicitWidth: content.width
    implicitHeight: buttonHeight
    opacity: enabled ? 1.0 : 0.38

    RowLayout {
        id: content
        anchors.fill: parent
        spacing: 3

        // Primary button (search/find)
        Rectangle {
            id: primaryButton
            Layout.fillHeight: true
            Layout.preferredWidth: searchToggled ? buttonExpanded : buttonWide

            topLeftRadius: buttonRadius
            bottomLeftRadius: buttonRadius
            topRightRadius: buttonSmallRadius
            bottomRightRadius: buttonSmallRadius

            color: {
                if (!enabled)
                    return Colors.m3.m3primary;
                if (primaryMouse.pressed)
                    return Colors.colPrimaryActive;
                if (primaryMouse.containsMouse)
                    return Colors.colPrimaryHover;
                return Colors.m3.m3primary;
            }

            Behavior on Layout.preferredWidth {
                Anim {}
            }

            Behavior on color {
                ColorAnimation {
                    duration: transitionDuration
                }
            }

            StyledRectangularShadow {
                target: parent
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 8
                spacing: 4

                MaterialSymbol {
                    text: "search"
                    color: Colors.colOnPrimary
                    fill: 1
                    font.pixelSize: Fonts.sizes.huge
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    visible: searchToggled
                    placeholderText: "Find"
                    background: null
                    padding: 0
                    placeholderTextColor: Colors.m3.m3outline
                    color: Colors.colOnPrimary
                    selectedTextColor: Colors.m3.m3onPrimaryContainer
                    selectionColor: Colors.colPrimaryContainer

                    font {
                        family: Fonts.family.main ?? "sans-serif"
                        pixelSize: Fonts.sizes.small ?? 15
                        hintingPreference: Font.PreferFullHinting
                    }

                    onTextChanged: {
                        root.searchText = text;
                        root.searchChanged(text);
                    }

                    onVisibleChanged: {
                        if (visible)
                            forceActiveFocus();
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.searchText = "";
                            root.searchToggled = false;
                            text = "";
                            event.accepted = true;
                        }
                    }
                }

                StyledText {
                    visible: !searchToggled
                    Layout.leftMargin: -10
                    text: "Find"
                    color: Colors.colOnPrimary
                    font.pixelSize: Fonts.sizes.normal
                }
            }

            MouseArea {
                id: primaryMouse
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (!searchToggled) {
                        root.searchToggled = true;
                    } else {
                        root.searchText = "";
                        searchField.text = "";
                        root.searchToggled = false;
                    }
                    root.primaryClicked();
                }
            }
        }

        // Secondary button (expand/collapse) - now in middle position
        Rectangle {
            id: secondaryButton
            visible: showMiddle
            Layout.fillHeight: true
            Layout.preferredWidth: secondaryMouse.pressed ? buttonHeight + 10 : buttonHeight

            topLeftRadius: secondaryActive ? 50 : buttonSmallRadius
            bottomLeftRadius: secondaryActive ? 50 : buttonSmallRadius
            topRightRadius: secondaryActive ? 50 : buttonSmallRadius
            bottomRightRadius: secondaryActive ? 50 : buttonSmallRadius

            Behavior on topLeftRadius {
                Anim {}
            }

            Behavior on bottomLeftRadius {
                Anim {}
            }

            color: {
                if (!enabled)
                    return Colors.m3.m3primary;
                if (secondaryMouse.pressed || secondaryActive)
                    return Colors.colPrimaryActive;
                if (secondaryMouse.containsMouse)
                    return Colors.colPrimaryHover;
                return Colors.m3.m3primary;
            }

            Behavior on Layout.preferredWidth {
                Anim {}
            }

            Behavior on color {
                ColorAnimation {
                    duration: transitionDuration
                }
            }

            StyledRectangularShadow {
                target: parent
            }

            MaterialSymbol {
                anchors.centerIn: parent
                text: "collapse_content"
                color: Colors.colOnPrimary
                font.pixelSize: buttonHeight * 0.5

                rotation: {
                    if (secondaryMouse.pressed)
                        return 180;
                    if (secondaryMouse.containsMouse)
                        return 90;
                    return 0;
                }

                Behavior on rotation {
                    Anim {}
                }
            }

            MouseArea {
                id: secondaryMouse
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                acceptedButtons: Qt.MiddleButton | Qt.RightButton | Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onPressed: event => {
                    if (event.button === Qt.RightButton) {
                        root.secondaryRightClicked();
                        root.primaryClicked();
                    } else if (event.button === Qt.LeftButton) {
                        root.secondaryClicked();
                    }
                }
            }
        }

        // Middle button - now in rightmost position
        Rectangle {
            id: middleButton
            Layout.fillHeight: true
            Layout.preferredWidth: middleMouse.pressed ? buttonHeight + 10 : buttonHeight

            topLeftRadius: middleActive ? 50 : buttonSmallRadius
            bottomLeftRadius: middleActive ? 50 : buttonSmallRadius
            topRightRadius: middleActive ? 50 : buttonRadius
            bottomRightRadius: middleActive ? 50 : buttonRadius

            Behavior on topLeftRadius {
                Anim {}
            }

            Behavior on bottomLeftRadius {
                Anim {}
            }

            color: {
                if (!enabled)
                    return Colors.m3.m3primary;
                if (middleMouse.pressed || middleActive)
                    return Colors.colPrimaryActive;
                if (middleMouse.containsMouse)
                    return Colors.colPrimaryHover;
                return Colors.m3.m3primary;
            }

            Behavior on Layout.preferredWidth {
                Anim {}
            }

            Behavior on color {
                ColorAnimation {
                    duration: transitionDuration
                }
            }

            StyledRectangularShadow {
                target: parent
            }

            MaterialSymbol {
                anchors.centerIn: parent
                text: "restart_alt"
                color: Colors.m3.m3onPrimary
                font.pixelSize: buttonHeight * 0.5

                rotation: {
                    if (middleMouse.pressed)
                        return 180;
                    if (middleMouse.containsMouse)
                        return 90;
                    return 0;
                }

                Behavior on rotation {
                    Anim {}
                }
            }

            MouseArea {
                id: middleMouse
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                pressAndHoldInterval: 500
                onPressAndHold: root.middleClicked()
            }
        }
    }
}
