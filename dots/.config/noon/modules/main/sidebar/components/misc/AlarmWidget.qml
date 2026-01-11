import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services

FocusScope {
    id: root

    property bool revealAddDialog: false

    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier)) {
            if (event.key === Qt.Key_L)
                AlarmService.clearAll();

            if (event.key === Qt.Key_R)
                AlarmService.reload();

            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.gigantic

        StyledText {
            text: "Alarms"
            font.pixelSize: Fonts.sizes.subTitle
            color: Colors.colOnLayer1
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: Padding.normal
            Layout.topMargin: Padding.normal
        }

        StyledListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Padding.normal
            clip: true
            model: AlarmService.alarms

            PagePlaceholder {
                shown: !AlarmService.hasAlarms
                icon: "timer"
                title: "No active alarms"
                description: "Swipe Below to add new Alarm"
            }

            delegate: AlarmItem {
                required property int index
                required property var modelData

                width: listView.width
                alarmData: modelData
                alarmIndex: index
            }
        }
    }

    BottomDialog {
        id: bottomDialog

        show: revealAddDialog
        collapsedHeight: 380
        enableStagedReveal: false
        bottomAreaReveal: true
        hoverHeight: 200
        onShowChanged: root.revealAddDialog = bottomDialog.show
        expand: true

        contentItem: Item {
            function addTimer() {
                const time = `${timePicker.hour}:${timePicker.minute}`;
                const message = nameField.text || `Alarm ${timePicker.hour}:${String(timePicker.minute).padStart(2, '0')}`;
                AlarmService.addTimer(time, message);
                nameField.text = "";
                bottomDialog.show = false;
            }

            anchors.fill: parent

            ColumnLayout {
                id: content

                spacing: Padding.normal

                anchors {
                    fill: parent
                    margins: Padding.massive
                }

                RowLayout {
                    id: header

                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 50
                    Layout.bottomMargin: 0
                    Layout.margins: Padding.normal

                    StyledText {
                        text: "Add Alarm"
                        font.pixelSize: Fonts.sizes.subTitle
                        color: Colors.colOnLayer2
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    }

                    Spacer {}

                    RippleButtonWithIcon {
                        materialIcon: "close"
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        releaseAction: () => {
                            return bottomDialog.show = false;
                        }
                    }
                }

                Separator {}

                RowLayout {
                    id: nameArea

                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    TextField {
                        id: nameField

                        Layout.fillWidth: true
                        Layout.leftMargin: Padding.normal
                        placeholderText: "Alarm Name (optional)"
                        background: null
                        selectionColor: Colors.colPrimaryContainer
                        selectedTextColor: Colors.m3.m3onPrimaryContainer
                        color: Colors.colOnLayer0
                        placeholderTextColor: Colors.colSubtext
                        selectByMouse: true
                        onAccepted: parent.parent.parent.addTimer()
                    }
                }

                TimePicker {
                    id: timePicker

                    clockPicker: true
                }

                Spacer {}
            }

            RippleButton {
                id: saveButton

                visible: bottomDialog.height > 300
                buttonRadius: Rounding.verylarge
                colBackground: Colors.colPrimaryContainer
                implicitWidth: 100
                implicitHeight: 50
                releaseAction: () => {
                    return parent.addTimer();
                }

                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    margins: 20
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Padding.normal

                    Symbol {
                        text: "add"
                        fill: 1
                        font.pixelSize: Fonts.sizes.large
                        color: Colors.colOnPrimaryContainer
                    }

                    StyledText {
                        color: Colors.colOnPrimaryContainer
                        font.pixelSize: Fonts.sizes.normal
                        text: "Add"
                    }
                }
            }
        }
    }

    component AlarmItem: RippleButton {
        id: alarmRoot

        required property int alarmIndex
        property var alarmData: null
        readonly property int timeUntilSeconds: {
            if (!alarmData || !alarmData.time)
                return 0;

            let alarmTime = new Date(alarmData.time);
            let now = new Date();
            return alarmTime > now ? Math.floor((alarmTime - now) / 1000) : 0;
        }

        implicitHeight: 110
        colBackground: Colors.colLayer1
        buttonRadius: Rounding.normal
        clip: true
        visible: alarmData !== null && alarmData !== undefined
        releaseAction: () => {
            if (alarmData)
                toggleSwitch.checked = !toggleSwitch.checked;
        }

        RowLayout {
            id: mainRow

            anchors {
                fill: parent
                margins: Padding.large
                leftMargin: Padding.gigantic
                rightMargin: Padding.massive
            }

            ColumnLayout {
                id: infoColumn

                Layout.fillHeight: true
                Layout.preferredWidth: parent.width / 2
                spacing: 0

                StyledText {
                    id: alarmTime

                    Layout.fillWidth: true
                    font.pixelSize: Fonts.sizes.subTitle
                    color: Colors.colOnLayer1
                    maximumLineCount: 1
                    font.variableAxes: Fonts.variableAxes.numbers
                    horizontalAlignment: Text.AlignLeft
                    text: alarmData ? AlarmService.formatTime(alarmData.time) : ""
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    StyledText {
                        id: alarmName

                        Layout.fillWidth: true
                        font.pixelSize: Fonts.sizes.normal
                        color: Colors.colOnLayer1
                        maximumLineCount: 1
                        horizontalAlignment: Text.AlignLeft
                        text: alarmData ? (alarmData.message || "Alarm") : ""
                    }

                    StyledText {
                        id: remainingTime
                        font.pixelSize: Fonts.sizes.small
                        color: Colors.colSubtext
                        text: AlarmService.formatUntil(alarmRoot.timeUntilSeconds)
                        Layout.alignment: Qt.AlignLeft
                        Timer {
                            interval: 60000
                            running: true
                            repeat: true
                            onTriggered: remainingTime.text = AlarmService.formatUntil(alarmRoot.timeUntilSeconds)
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Padding.small

                StyledSwitch {
                    id: toggleSwitch

                    scale: 1
                    checked: alarmData ? (alarmData.active || false) : false
                    enabled: alarmData && alarmRoot.timeUntilSeconds >= 0
                    onCheckedChanged: {
                        if (alarmData)
                            AlarmService.toggleAlarm(alarmRoot.alarmIndex, checked);
                    }
                }

                RippleButtonWithIcon {
                    materialIcon: "delete"
                    enabled: alarmData !== null
                    onClicked: AlarmService.removeAlarm(alarmRoot.alarmIndex)
                }
            }
        }
    }
}
