import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.utils

FloatingWindow {
    id: root
    visible: true
    maximumSize: Qt.size(1600, 900)
    minimumSize: Qt.size(1280, 720)
    readonly property Item contentLoaderItem: contentLoader.item
    readonly property Item sidebarContentLoaderItem: sidebarContentLoader.item
    property alias expandSidebar: sidebar.expanded
    property alias sidebarContentItem: sidebarContentLoader.sourceComponent
    property alias contentItem: contentLoader.sourceComponent
    StyledRect {
        id: bg
        anchors.fill: parent
        color: Colors.m3.m3surface
    }
    Loader {
        id: contentLoader
        anchors {
            left: sidebar.right
            leftMargin: Padding.large
            margins: Padding.normal
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
    }
    StyledRect {
        id: sidebar
        property bool expanded: true
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        implicitWidth: expanded ? Sizes.mediaPlayer.sidebarWidth : Sizes.mediaPlayer.sidebarWidthCollapsed
        color: Colors.colLayer2
        Loader {
            id: sidebarContentLoader
            anchors.fill: parent
            sourceComponent: sidebarContentItem
        }
        Rectangle {
            color: Colors.colOutline
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: 1
        }
        RippleButtonWithIcon {
            anchors {
                top: parent.top
                left: parent.left
                margins: Padding.massive
            }
            materialIcon: "close"
            colBackground: Colors.colLayer3
            buttonRadius: Rounding.full
            implicitSize: 34
            releaseAction: () => {
                root.visible = false;
            }
        }

        RippleButtonWithIcon {
            anchors {
                bottom: parent.bottom
                right: parent.right
                horizontalCenter: sidebar.expanded ? undefined : parent.horizontalCenter
                margins: Padding.massive
            }
            materialIcon: "expand_content"
            colBackground: Colors.colLayer3
            buttonRadius: Rounding.full
            implicitSize: 34
            releaseAction: () => {
                sidebar.expanded = !sidebar.expanded;
            }
        }
    }
}
