import qs.store
import qs.services
import qs.common
import qs.common.widgets
import qs.common.functions

import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Layouts

StyledPopup {
    name: `workspace-${button.workspaceValue}-preview`
    focus: false

    StyledRect {
        readonly property size targetSize: {
            if (button.windowToplevel && button.biggestWindow?.size) {
                const winWidth = button.biggestWindow.size[0];
                const winHeight = button.biggestWindow.size[1];

                if (winWidth <= 0 || winHeight <= 0)
                    return root.previewMaxSize;

                const aspectRatio = winWidth / winHeight;
                let width = winWidth * root.previewScale;
                let height = winHeight * root.previewScale;

                if (width > root.previewMaxSize.width) {
                    width = root.previewMaxSize.width;
                    height = width / aspectRatio;
                }

                if (height > root.previewMaxSize.height) {
                    height = root.previewMaxSize.height;
                    width = height * aspectRatio;
                }

                return Qt.size(width, height);
            }
            return root.previewMaxSize;
        }

        clip: true
        color: "transparent"
        radius: Rounding.verylarge - Padding.normal
        anchors.fill: parent
        anchors.margins: Padding.normal
        implicitWidth: targetSize.width - Padding.normal
        implicitHeight: targetSize.height - Padding.normal

        StyledScreencopyView {
            id: preview
            z: 0
            anchors.fill: parent
            constraintSize: Qt.size(parent.implicitWidth, parent.implicitHeight)
            captureSource: button.windowToplevel || root.bar.screen
            live: true
            smooth: true
        }

        StyledIconImage {
            z: 1
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: Padding.huge
            width: Math.min(parent.implicitWidth, parent.implicitHeight) * root.previewIconScale
            height: width
            source: button.appIconSource
            mipmap: true
        }
    }
}
