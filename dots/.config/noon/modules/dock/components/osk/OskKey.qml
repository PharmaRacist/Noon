import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

RippleButton {
    id: root

    property var keyData
    property string key: keyData.label
    property string type: keyData.keytype
    property var keycode: keyData.keycode
    property string shape: keyData.shape
    property bool isShift: Ydotool.shiftKeys.includes(keycode)
    property bool isBackspace: (key.toLowerCase() == "backspace")
    property bool isEnter: (key.toLowerCase() == "enter" || key.toLowerCase() == "return")
    property real baseWidth: 45
    property real baseHeight: 45
    property var widthMultiplier: ({
        "normal": 1,
        "fn": 1,
        "tab": 1.6,
        "caps": 1.9,
        "shift": 2.5,
        "control": 1.3
    })
    property var heightMultiplier: ({
        "normal": 1,
        "fn": 0.7,
        "tab": 1,
        "caps": 1,
        "shift": 1,
        "control": 1
    })

    toggled: isShift ? Ydotool.shiftMode : false
    enabled: shape != "empty"
    colBackground: shape == "empty" ? ColorUtils.transparentize(Colors.colLayer1) : Colors.colLayer1
    buttonRadius: Rounding.small
    implicitWidth: baseWidth * widthMultiplier[shape] || baseWidth
    implicitHeight: baseHeight * heightMultiplier[shape] || baseHeight
    Layout.fillWidth: shape == "space" || shape == "expand"
    downAction: () => {
        Ydotool.press(root.keycode);
        if (isShift && Ydotool.shiftMode == 0)
            Ydotool.shiftMode = 1;

    }
    releaseAction: () => {
        if (root.type == "normal") {
            Ydotool.release(root.keycode);
            if (Ydotool.shiftMode == 1)
                Ydotool.releaseShiftKeys();

        } else if (isShift) {
            // Caps lock mode

            if (Ydotool.shiftMode == 1) {
                if (!capsLockTimer.hasStarted) {
                    capsLockTimer.startWaiting();
                } else {
                    if (capsLockTimer.canCaps)
                        Ydotool.shiftMode = 2;
                    else
                        Ydotool.releaseShiftKeys();
                }
            } else if (Ydotool.shiftMode == 2) {
                Ydotool.releaseShiftKeys();
            }
        } else if (root.type == "modkey") {
            root.toggled = !root.toggled;
            if (!root.toggled) {
                if (isShift)
                    Ydotool.releaseShiftKeys();
                else
                    Ydotool.release(root.keycode);
            }
        }
    }

    Connections {
        function onShiftModeChanged() {
            if (Ydotool.shiftMode == 0)
                capsLockTimer.hasStarted = false;

        }

        target: Ydotool
        enabled: isShift
    }

    Timer {
        id: capsLockTimer

        property bool hasStarted: false
        property bool canCaps: false

        function startWaiting() {
            hasStarted = true;
            canCaps = true;
            start();
        }

        interval: 300
        onTriggered: {
            canCaps = false;
        }
    }

    contentItem: StyledText {
        id: keyText

        anchors.fill: parent
        font.family: (isBackspace || isEnter) ? Fonts.family.iconMaterial : Fonts.family.main
        font.pixelSize: root.shape == "fn" ? Fonts.sizes.small : (isBackspace || isEnter) ? Fonts.sizes.huge : Fonts.sizes.large
        horizontalAlignment: Text.AlignHCenter
        color: root.toggled ? Colors.m3.m3onPrimary : Colors.colOnLayer1
        text: root.isBackspace ? "backspace" : root.isEnter ? "subdirectory_arrow_left" : Ydotool.shiftMode == 2 ? (root.keyData.labelCaps || root.keyData.labelShift || root.keyData.label) : Ydotool.shiftMode == 1 ? (root.keyData.labelShift || root.keyData.label) : root.keyData.label
    }

}
