import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

SidebarDialog {
    id: root

    // Modular settings components
    Component {
        id: modeSettingsComponent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Rounding.large
            Layout.rightMargin: Rounding.large
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            spacing: 4

            Repeater {
                model: [{
                    "text": qsTr("Full Screen"),
                    "icon": "screenshot_monitor",
                    "mode": 0
                }, {
                    "text": qsTr("Select Region"),
                    "icon": "crop_free",
                    "mode": 1
                }, {
                    "text": qsTr("Active Window"),
                    "icon": "web_asset",
                    "mode": 2
                }]

                delegate: DialogButton {
                    property bool selected: RecordingService.recordingMode === modelData.mode

                    Layout.fillWidth: true
                    buttonText: ""
                    colBackground: selected ? Colors.colPrimary : Colors.colLayer2
                    colBackgroundHover: selected ? Colors.colPrimaryHover : Colors.colLayer2Hover
                    colRipple: selected ? Colors.colPrimaryActive : Colors.colLayer2Active
                    onClicked: RecordingService.setRecordingMode(modelData.mode)

                    contentItem: RowLayout {
                        spacing: 10

                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                            topMargin: 8
                            bottomMargin: 8
                        }

                        MaterialSymbol {
                            text: modelData.icon
                            font.pixelSize: Fonts.sizes.verylarge
                            color: parent.parent.selected ? Colors.colOnPrimary : Colors.colOnSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: parent.parent.selected ? Colors.colOnPrimary : Colors.colOnSurfaceVariant
                        }

                        MaterialSymbol {
                            visible: parent.parent.selected
                            text: "check"
                            font.pixelSize: Fonts.sizes.verylarge
                            color: Colors.colOnPrimary
                        }

                    }

                }

            }

        }

    }

    Component {
        id: audioSettingsComponent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Rounding.large
            Layout.rightMargin: Rounding.large
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            spacing: 4

            Repeater {
                model: [{
                    "text": qsTr("Muted"),
                    "icon": "volume_off",
                    "mode": 0
                }, {
                    "text": qsTr("System Audio"),
                    "icon": "volume_up",
                    "mode": 1
                }, {
                    "text": qsTr("Microphone"),
                    "icon": "mic",
                    "mode": 2
                }, {
                    "text": qsTr("System + Microphone"),
                    "icon": "speaker_phone",
                    "mode": 3
                }]

                delegate: DialogButton {
                    property bool selected: RecordingService.audioMode === modelData.mode

                    Layout.fillWidth: true
                    buttonText: ""
                    colBackground: selected ? Colors.colPrimary : Colors.colLayer2
                    colBackgroundHover: selected ? Colors.colPrimaryHover : Colors.colLayer2Hover
                    colRipple: selected ? Colors.colPrimaryActive : Colors.colLayer2Active
                    onClicked: RecordingService.setAudioMode(modelData.mode)

                    contentItem: RowLayout {
                        spacing: 10

                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                            topMargin: 8
                            bottomMargin: 8
                        }

                        MaterialSymbol {
                            text: modelData.icon
                            font.pixelSize: Fonts.sizes.verylarge
                            color: parent.parent.selected ? Colors.colOnPrimary : Colors.colOnSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: parent.parent.selected ? Colors.colOnPrimary : Colors.colOnSurfaceVariant
                        }

                        MaterialSymbol {
                            visible: parent.parent.selected
                            text: "check"
                            font.pixelSize: Fonts.sizes.verylarge
                            color: Colors.colOnPrimary
                        }

                    }

                }

            }

        }

    }

    Component {
        id: qualitySettingsComponent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Rounding.large
            Layout.rightMargin: Rounding.large
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            spacing: 4

            Repeater {
                model: [{
                    "text": qsTr("Low (720p 30fps)"),
                    "icon": "sd",
                    "quality": 0
                }, {
                    "text": qsTr("Medium (1080p 30fps)"),
                    "icon": "hd",
                    "quality": 1
                }, {
                    "text": qsTr("High (1080p 60fps)"),
                    "icon": "high_quality",
                    "quality": 2
                }, {
                    "text": qsTr("Ultra (4K 60fps)"),
                    "icon": "4k",
                    "quality": 3
                }]

                delegate: DialogButton {
                    property bool selected: RecordingService.quality === modelData.quality

                    Layout.fillWidth: true
                    buttonText: ""
                    colBackground: selected ? Colors.colPrimary : Colors.colLayer2
                    colBackgroundHover: selected ? Colors.colPrimaryHover : Colors.colLayer2Hover
                    colRipple: selected ? Colors.colPrimaryActive : Colors.colLayer2Active
                    onClicked: RecordingService.setQuality(modelData.quality)

                    contentItem: RowLayout {
                        spacing: 10

                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                            topMargin: 8
                            bottomMargin: 8
                        }

                        MaterialSymbol {
                            text: modelData.icon
                            font.pixelSize: Fonts.sizes.verylarge
                            color: parent.parent.selected ? Colors.colOnPrimary : Colors.colOnSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: parent.parent.selected ? Colors.colOnPrimary : Colors.colOnSurfaceVariant
                        }

                        MaterialSymbol {
                            visible: parent.parent.selected
                            text: "check"
                            font.pixelSize: Fonts.sizes.verylarge
                            color: Colors.colOnPrimary
                        }

                    }

                }

            }

        }

    }

    Component {
        id: optionsSettingsComponent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Rounding.large
            Layout.rightMargin: Rounding.large
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MaterialSymbol {
                    text: "mouse"
                    font.pixelSize: Fonts.sizes.verylarge
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Show Cursor")
                    color: Colors.colOnSurfaceVariant
                }

                StyledSwitch {
                    checked: RecordingService.showCursor
                    onToggled: RecordingService.showCursor = checked
                }

            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MaterialSymbol {
                    text: "speed"
                    font.pixelSize: Fonts.sizes.verylarge
                    color: Colors.colOnSurfaceVariant
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Custom Framerate")
                    color: Colors.colOnSurfaceVariant
                }

                MaterialTextField {
                    // Revert to previous value

                    Layout.preferredWidth: 80
                    text: RecordingService.customFramerate === 0 ? "Auto" : RecordingService.customFramerate.toString()
                    placeholderText: "Auto"
                    inputMethodHints: Qt.ImhDigitsOnly
                    onEditingFinished: {
                        if (text === "" || text.toLowerCase() === "auto") {
                            RecordingService.customFramerate = 0;
                        } else {
                            const val = parseInt(text);
                            if (!isNaN(val) && val >= 1 && val <= 144)
                                RecordingService.customFramerate = val;
                            else
                                text = RecordingService.customFramerate === 0 ? "Auto" : RecordingService.customFramerate.toString();
                        }
                    }

                    validator: IntValidator {
                        bottom: 1
                        top: 144
                    }

                }

            }

        }

    }

    WindowDialogTitle {
        text: qsTr("Screen Recording")
    }

    WindowDialogSeparator {
        visible: !RecordingService.isRecording
    }

    // Recording status indicator
    StyledIndeterminateProgressBar {
        visible: RecordingService.isRecording
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Rounding.large
        Layout.rightMargin: -Rounding.large
    }

    // Recording status when active
    ColumnLayout {
        visible: RecordingService.isRecording
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignCenter
        spacing: 8

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Recording in progress...")
            font.bold: true
            color: Colors.colError
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: RecordingService.getFormattedDuration()
            font.pixelSize: Fonts.sizes.verylarge
            color: Colors.colOnSurfaceVariant
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: `${RecordingService.getRecordingModeText()} • ${RecordingService.getAudioModeText()}`
            font.pixelSize: Fonts.sizes.small
            color: Colors.colOnSurfaceVariant
            opacity: 0.7
        }

    }

    WindowDialogSeparator {
        visible: RecordingService.isRecording
    }

    // Settings list when not recording
    StyledListView {
        visible: !RecordingService.isRecording
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 8
        clip: true

        model: ListModel {
            ListElement {
                sectionType: "mode"
                title: "Recording Mode"
                icon: "screenshot_monitor"
            }

            ListElement {
                sectionType: "audio"
                title: "Audio"
                icon: "volume_up"
            }

            ListElement {
                sectionType: "quality"
                title: "Quality"
                icon: "high_quality"
            }

            ListElement {
                sectionType: "options"
                title: "Options"
                icon: "tune"
            }

        }

        delegate: Item {
            id: settingItem

            required property string sectionType
            required property string title
            required property string icon
            property bool expanded: false

            width: ListView.view.width
            height: contentColumn.implicitHeight

            ColumnLayout {
                id: contentColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.leftMargin: 16
                spacing: 12

                // Header row - clickable
                DialogListItem {
                    Layout.fillWidth: true
                    enabled: !RecordingService.isRecording
                    active: settingItem.expanded
                    onClicked: {
                        settingItem.expanded = !settingItem.expanded;
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        MaterialSymbol {
                            font.pixelSize: Fonts.sizes.verylarge
                            text: settingItem.icon
                            color: Colors.colOnSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            color: Colors.colOnSurfaceVariant
                            elide: Text.ElideRight
                            text: settingItem.title
                        }

                        StyledText {
                            color: Colors.colOnSurfaceVariant
                            opacity: 0.7
                            font.pixelSize: Fonts.sizes.small
                            text: {
                                switch (settingItem.sectionType) {
                                case "mode":
                                    return RecordingService.getRecordingModeText();
                                case "audio":
                                    return RecordingService.getAudioModeText();
                                case "quality":
                                    return RecordingService.getQualityText();
                                case "options":
                                    return RecordingService.showCursor ? "Cursor On" : "Cursor Off";
                                default:
                                    return "";
                                }
                            }
                        }

                        MaterialSymbol {
                            text: settingItem.expanded ? "expand_less" : "expand_more"
                            font.pixelSize: Fonts.sizes.verylarge
                            color: Colors.colOnSurfaceVariant
                        }

                    }

                }

                // Expanded content loader
                ColumnLayout {
                    visible: settingItem.expanded
                    Layout.fillWidth: true
                    spacing: 4

                    Loader {
                        Layout.fillWidth: true
                        sourceComponent: {
                            switch (settingItem.sectionType) {
                            case "mode":
                                return modeSettingsComponent;
                            case "audio":
                                return audioSettingsComponent;
                            case "quality":
                                return qualitySettingsComponent;
                            case "options":
                                return optionsSettingsComponent;
                            default:
                                return undefined;
                            }
                        }
                    }

                }

            }

        }

    }

    WindowDialogButtonRow {
        implicitHeight: 50

        DialogButton {
            colText: Colors.colOnPrimary
            buttonText: RecordingService.isRecording ? qsTr("Stop") : qsTr("Record")
            colBackground: RecordingService.isRecording ? Colors.colError : Colors.colPrimary
            colBackgroundHover: RecordingService.isRecording ? Colors.colErrorHover : Colors.colPrimaryHover
            onClicked: {
                RecordingService.toggleRecording();
                if (!RecordingService.isRecording)
                    root.dismiss();

            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: qsTr("Done")
            enabled: true
            onClicked: {
                dismiss();
            }
        }

    }

}
