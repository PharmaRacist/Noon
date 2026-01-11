import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Item {
    // on text change / accept

    id: root

    // ─── Core State ─────────────────────────────────────────────
    property bool enabled: true
    property bool searchToggled: false
    property bool secondActive: false
    property bool thirdActive: false
    property bool showThird: true
    property string searchText: ""
    // ─── Customization ──────────────────────────────────────────
    property string placeholderText: "Find"
    property string firstIcon: "search"
    property string secondIcon: "restart_alt"
    property string thirdIcon: "collapse_content"
    property bool showPlaceHolder: true
    property color thirdBgColor: defaultColors
    property color defaultColors: {
        if (!enabled)
            return Colors.m3.m3primary;

        if (thirdMouse.pressed || thirdActive)
            return Colors.colPrimaryActive;

        if (thirdMouse.containsMouse)
            return Colors.colPrimaryHover;

        return Colors.m3.m3primary;
    }
    // ─── Variable-based action callbacks ─────────────────────────
    property var firstAction
    // toggles search or custom
    property var secondAction
    // middle hold or click
    property var thirdAction
    // expand/collapse or custom
    property var thirdRightAction
    // right-click alternative
    property var searchAction
    property var secondPressHoldAction
    // ─── UI constants ───────────────────────────────────────────
    property int buttonHeight: 45
    property int buttonRadius: 99
    property int buttonSmallRadius: 4
    property int buttonWide: 120
    property int buttonExpanded: 150
    property int transitionDuration: 200

    implicitHeight: buttonHeight
    implicitWidth: content.width
    opacity: enabled ? 1 : 0.38
    focus: searchField
    z: 999

    StyledRectangularShadow {
        target: content
    }

    RowLayout {
        id: content

        implicitHeight: buttonHeight
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        spacing: 3

        // ─── First Button (Search) ───────────────────────────────
        Rectangle {
            id: firstButton

            Layout.fillHeight: true
            Layout.preferredWidth: searchToggled ? buttonExpanded : buttonWide
            topLeftRadius: buttonRadius
            bottomLeftRadius: buttonRadius
            topRightRadius: buttonSmallRadius
            bottomRightRadius: buttonSmallRadius
            color: {
                if (!enabled)
                    return Colors.m3.m3primary;

                if (firstMouse.pressed)
                    return Colors.colPrimaryActive;

                if (firstMouse.containsMouse)
                    return Colors.colPrimaryHover;

                return Colors.m3.m3primary;
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 8
                spacing: 15

                Symbol {
                    text: firstIcon
                    color: Colors.colOnPrimary
                    fill: 1
                    font.pixelSize: Fonts.sizes.huge
                }

                TextField {
                    id: searchField

                    visible: searchToggled
                    Layout.fillWidth: true
                    placeholderText: root.placeholderText
                    background: null
                    padding: 0
                    placeholderTextColor: Colors.m3.m3outline
                    color: Colors.colOnPrimary
                    selectedTextColor: Colors.m3.m3onPrimaryContainer
                    selectionColor: Colors.colPrimaryContainer
                    onTextChanged: {
                        root.searchText = text;
                    }
                    onAccepted: {
                        if (root.searchAction) {
                            root.searchAction(searchText);
                            text = "";
                        }
                    }
                    onVisibleChanged: {
                        if (visible)
                            forceActiveFocus();

                    }
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.searchText = "";
                            root.searchToggled = false;
                            text = "";
                            event.accepted = true;
                        }
                    }

                    font {
                        family: Fonts.family.main ?? "sans-serif"
                        pixelSize: Fonts.sizes.small ?? 15
                        hintingPreference: Font.PreferFullHinting
                    }

                }

                StyledText {
                    animateChange: true
                    visible: !searchToggled && showPlaceHolder
                    Layout.leftMargin: -10
                    text: root.placeholderText
                    color: Colors.colOnPrimary
                    font.pixelSize: Fonts.sizes.normal
                }

            }

            MouseArea {
                id: firstMouse

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
                    if (root.firstAction)
                        root.firstAction();

                }
            }

            Behavior on Layout.preferredWidth {
                Anim {
                }

            }

            Behavior on color {
                CAnim {
                }

            }

        }

        // ─── Second Button ───────────────────────────────────────
        Rectangle {
            id: secondButton

            Layout.fillHeight: true
            Layout.preferredWidth: secondMouse.pressed ? buttonHeight + 10 : buttonHeight
            topLeftRadius: secondActive ? 50 : buttonSmallRadius
            bottomLeftRadius: secondActive ? 50 : buttonSmallRadius
            topRightRadius: !root.showThird ? buttonRadius : (secondActive ? 50 : buttonSmallRadius)
            bottomRightRadius: !root.showThird ? buttonRadius : (secondActive ? 50 : buttonSmallRadius)
            color: {
                if (!enabled)
                    return Colors.m3.m3primary;

                if (secondMouse.pressed || secondActive)
                    return Colors.colPrimaryActive;

                if (secondMouse.containsMouse)
                    return Colors.colPrimaryHover;

                return Colors.m3.m3primary;
            }

            Symbol {
                anchors.centerIn: parent
                text: secondIcon
                color: Colors.colOnPrimary
                font.pixelSize: buttonHeight * 0.5
                rotation: secondMouse.pressed ? 180 : secondMouse.containsMouse ? 90 : 0

                Behavior on rotation {
                    Anim {
                    }

                }

            }

            MouseArea {
                id: secondMouse

                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                pressAndHoldInterval: 500
                onClicked: {
                    if (root.secondAction)
                        root.secondAction();

                }
                onPressAndHold: {
                    if (root.secondPressHoldAction)
                        root.secondPressHoldAction();

                }
            }

            Behavior on topLeftRadius {
                Anim {
                }

            }

            Behavior on bottomLeftRadius {
                Anim {
                }

            }

            Behavior on Layout.preferredWidth {
                Anim {
                }

            }

            Behavior on color {
                CAnim {
                }

            }

        }

        // ─── Third Button ────────────────────────────────────────
        Rectangle {
            id: thirdButton

            visible: showThird
            Layout.fillHeight: true
            Layout.preferredWidth: thirdMouse.pressed ? buttonHeight + 10 : buttonHeight
            topLeftRadius: thirdActive ? 50 : buttonSmallRadius
            bottomLeftRadius: thirdActive ? 50 : buttonSmallRadius
            topRightRadius: thirdActive ? 50 : buttonRadius
            bottomRightRadius: thirdActive ? 50 : buttonRadius
            color: thirdBgColor

            Symbol {
                anchors.centerIn: parent
                text: thirdIcon
                color: Colors.m3.m3onPrimary
                font.pixelSize: buttonHeight * 0.5
                rotation: thirdMouse.pressed ? 180 : thirdMouse.containsMouse ? 90 : 0

                Behavior on rotation {
                    Anim {
                    }

                }

            }

            MouseArea {
                id: thirdMouse

                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onPressed: (event) => {
                    if (event.button === Qt.RightButton && root.thirdRightAction)
                        root.thirdRightAction();
                    else if (event.button === Qt.LeftButton && root.thirdAction)
                        root.thirdAction();
                }
            }

            Behavior on topLeftRadius {
                Anim {
                }

            }

            Behavior on bottomLeftRadius {
                Anim {
                }

            }

            Behavior on Layout.preferredWidth {
                Anim {
                }

            }

            Behavior on color {
                CAnim {
                }

            }

        }

    }

}
