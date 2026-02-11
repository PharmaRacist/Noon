import qs.services
import qs.common
import qs.common.widgets
import qs.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ColumnLayout {
    id: root

    property bool editing: false
    property bool renderMarkdown: false
    property bool enableMouseSelection: false
    property string segmentContent: ""
    property var messageData: {}
    property bool done: true
    property bool forceDisableChunkSplitting: false

    property list<string> renderedLatexHashes: []
    property string renderedSegmentContent: ""
    property string shownText: ""
    property bool fadeChunkSplitting: !forceDisableChunkSplitting && !editing && !/\n\|/.test(shownText) && Mem.options.sidebar.behavior.aiTextFadeIn

    Layout.fillWidth: true
    spacing: 0

    Timer {
        id: renderTimer
        interval: 100
        repeat: false
        onTriggered: {
            const color = Colors.colOnLayer1.toString();
            renderedLatexHashes = LatexService.detectAndRenderLatex(segmentContent, color);
        }
    }

    function updateRenderedContent() {
        renderedSegmentContent = LatexService.replaceLatexWithImages(segmentContent, renderedLatexHashes);
    }

    onDoneChanged: renderTimer.restart()

    onEditingChanged: {
        if (!editing) {
            renderTimer.restart();
        } else {
            root.shownText = segmentContent;
        }
    }

    onSegmentContentChanged: {
        renderedSegmentContent = String(segmentContent ?? "");
        if (!root.editing && segmentContent) {
            renderTimer.restart();
        }
    }

    onRenderedSegmentContentChanged: {
        if (renderedSegmentContent) {
            root.shownText = renderedSegmentContent;
        }
    }

    Connections {
        target: LatexService
        function onRenderFinished(hash, imagePath) {
            if (renderedLatexHashes.includes(hash)) {
                updateRenderedContent();
            }
        }
    }

    Repeater {
        id: textLinesRepeater
        property list<real> textLineOpacities: []

        model: ScriptModel {
            values: root.fadeChunkSplitting ? root.shownText.split(/\n\n(?= {0,2})|\n(?= {0,2}[-\*])/g).filter(line => line.trim() !== "") : [root.shownText]
            onValuesChanged: {
                while (textLinesRepeater.textLineOpacities.length < values.length) {
                    textLinesRepeater?.textLineOpacities.push(root.messageData?.done ? 1 : 0);
                }
            }
        }

        delegate: TextArea {
            id: textArea
            required property int index
            required property string modelData

            Layout.fillWidth: true
            visible: opacity > 0
            opacity: fadeChunkSplitting ? (textLinesRepeater.textLineOpacities[index] ?? (root.messageData?.done ? 1 : 0)) : 1
            readOnly: !editing
            selectByMouse: enableMouseSelection || editing
            renderType: Text.NativeRendering
            font.family: Fonts.family.reading
            font.hintingPreference: Font.PreferNoHinting
            font.pixelSize: Fonts.sizes.large * Mem.states.sidebar.apis.fontScale
            selectedTextColor: Colors.m3.m3onSecondaryContainer
            selectionColor: Colors.colSecondaryContainer
            wrapMode: TextEdit.Wrap
            color: root.messageData?.thinking ? Colors.colSubtext : Colors.colOnLayer1
            textFormat: renderMarkdown ? TextEdit.MarkdownText : TextEdit.PlainText
            text: modelData

            Behavior on opacity {
                Anim {}
            }

            Connections {
                target: textLinesRepeater.model
                function onValuesChanged() {
                    if (textLinesRepeater.model.values.length > textArea.index + 1) {
                        textLinesRepeater.textLineOpacities[textArea.index] = 1;
                    }
                }
            }

            onTextChanged: {
                if (root.editing)
                    segmentContent = text;
            }

            onLinkActivated: link => {
                Qt.openUrlExternally(link);
                GlobalStates.main.sidebar.visible = false;
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
                cursorShape: parent.hoveredLink !== "" ? Qt.PointingHandCursor : (enableMouseSelection || editing) ? Qt.IBeamCursor : Qt.ArrowCursor
            }
        }
    }
}
