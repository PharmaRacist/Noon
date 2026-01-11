import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.common.functions
import qs.services
import qs.store
import QtMultimedia

StyledToolTip {
    id: root
    property string type
    property string path
    property var supportedPreviews: ["image", "docs", "play_arrow"]
    contentItem: Item {
        implicitWidth: Sizes.sidebar.shelfPopupSize.width
        implicitHeight: Sizes.sidebar.shelfPopupSize.height
        StyledRect {
            id: bg
            anchors.fill: parent
            anchors.margins: Padding.large
            color: Colors.m3.m3surfaceContainer
            radius: Rounding.large
            Loader {
                active: root.extraVisibleCondition
                anchors.fill: parent
                asynchronous: true
                sourceComponent: switch (root.type) {
                case "image":
                    return imageComponent;
                case "docs":
                    return docsComponent;
                case "video":
                    return videoComponent;
                default:
                    return null;
                }
                onLoaded: {
                    if (item && item !== null) {
                        item.source = root.path;
                    }
                }
            }

            Component {
                id: docsComponent
                PdfPreview {
                    source: root.source
                    anchors.margins: Padding.verylarge
                    anchors.fill: parent
                    renderScale: 0.5
                    sourceSize: Qt.size(width, height)
                }
            }
            Component {
                id: imageComponent
                CroppedImage {
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: Padding.verylarge
                    radius: Rounding.normal
                }
            }
            Component {
                id: videoComponent
                VideoPreview {
                    anchors.fill: parent
                    anchors.margins: Padding.verylarge
                    autoPlay: true
                }
            }
        }
        Rectangle {
            z: 9999
            anchors {
                fill: parent
            }
            StyledText {
                anchors {
                    left: parent.left
                    margins: Padding.massive
                    bottom: parent.bottom
                }
                text: title.text
                width: parent.width - Padding.verylarge * 5
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }
            gradient: Gradient {
                GradientStop {
                    color: Colors.m3.m3surfaceContainerLowest
                    position: 0.98
                }
                GradientStop {
                    position: 0.02
                    color: "transparent"
                }
            }
        }
        StyledRectangularShadow {
            target: bg
        }
    }
}
