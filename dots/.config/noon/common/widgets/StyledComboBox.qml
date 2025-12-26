import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services

ComboBox {
    id: root
    // clip:true
    Layout.preferredHeight: 40
    Layout.preferredWidth: 210
    // ---- Custom delegate ----
    delegate: ItemDelegate {
        width: root.width - 10
        height: 40
        highlighted: root.highlightedIndex === index

        contentItem: Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            MaterialSymbol {
                text: modelData?.icon ?? ""
                font.pixelSize: 20
                color: Colors.colOnLayer1
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: modelData?.name ?? modelData ?? ""
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
            }
        }

        background: Rectangle {
            color: parent.highlighted ? Colors.m3.m3primaryContainer : "transparent"
            radius: Rounding.small
        }
    }

    // ---- Displayed text ----
    contentItem: StyledText {
        id: display
        text: root.displayText
        color: Colors.colOnLayer1
        anchors.leftMargin:Padding.large
        anchors.rightMargin:Padding.verylarge
        anchors.fill: parent
        elide: Text.ElideRight
        wrapMode: TextEdit.Wrap
        maximumLineCount: 1

    }

    background: Rectangle {
        color: Colors.m3.m3surfaceContainer
        radius: Rounding.normal
    }

    // ---- Click handling ----
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (popup.visible)
                popup.closeWithAnim();
            else
                popup.openWithAnim();
        }
    }

    // ---- Custom popup ----
    popup: Popup {
        id: popup
        width: root.width + padding + 6
        padding: 15
        opacity: 0
        implicitHeight: Math.min(contentItem.implicitHeight + padding, 300)
        property real animatedHeight: 0
        property real baseY: root.height + 1.5 * padding
        property real offsetY: padding
        height: animatedHeight
        x: (root.width - width) / 2 // Horizontally center the popup
        y: baseY
        closePolicy: Popup.NoAutoClose // prevent instant hide

        function openWithAnim() {
            animatedHeight = 0;
            opacity = 0;
            y = baseY;
            visible = true;
            revealAnim.restart();
        }

        function closeWithAnim() {
            if (!visible || hideAnim.running)
                return;
            hideAnim.restart();
        }

        // Intercept close() to animate first
        onAboutToHide: event => {
            // event.accepted = true
            closeWithAnim();
        }

        background: Rectangle {
            color: Colors.m3.m3surfaceContainerLowest
            radius: Rounding.large
            clip: true
        }

        contentItem: StyledListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            spacing: 2
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        // --- OPEN: expand upward + fade in ---
        ParallelAnimation {
            id: revealAnim
            running: false
            PropertyAnimation {
                target: popup
                property: "opacity"
                from: 0
                to: 1
                duration: 180
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                target: popup
                property: "animatedHeight"
                from: 0
                to: popup.implicitHeight
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        // --- CLOSE: slide downward + fade out ---
        ParallelAnimation {
            id: hideAnim
            running: false
            PropertyAnimation {
                target: popup
                property: "opacity"
                from: 1
                to: 0
                duration: 150
                easing.type: Easing.InCubic
            }
            PropertyAnimation {
                target: popup
                property: "y"
                from: popup.baseY
                to: popup.baseY + 2 * popup.offsetY
                duration: 150
                easing.type: Easing.InCubic
            }
            onStopped: {
                popup.visible = false;
                popup.y = popup.baseY;
            }
        }
    }
}
