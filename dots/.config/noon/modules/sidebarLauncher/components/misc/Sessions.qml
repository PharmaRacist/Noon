import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common.widgets

Rectangle {
    id: root

    width: 600
    height: 400
    color: "#1e1e2e"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Active Sessions"
                font.pixelSize: 24
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }

            Button {
                text: "Add Session"
                font.pixelSize: 14

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#1e1e2e"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? "#a6e3a1" : "#94e2d5"
                    radius: 6
                }

                onClicked: {
                    console.log("Add session clicked");
                    addDialog.visible = true;
                }
            }

            Button {
                text: "Refresh"
                font.pixelSize: 14

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#1e1e2e"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? "#89b4fa" : "#74c7ec"
                    radius: 6
                }

                onClicked: {
                    // LoginctlData.updateSessions();
                    console.log("Refresh clicked");
                    loadMockData();
                }
            }
        }

        // Session List
        StyledListView {
            id: sessionListView
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 8
            clip: true
            colBackground: "#181825"
            radius: 8
            animateMovement: false
            popin: true

            model: sessionModel

            delegate: Rectangle {
                width: sessionListView.width - 20
                height: 80
                color: "#1e1e2e"
                radius: 6
                border.color: "#313244"
                border.width: 1
                x: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    // Session Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Session: " + model.session
                            font.pixelSize: 16
                            font.bold: true
                            color: "#cdd6f4"
                        }

                        Label {
                            text: "User: " + model.user + " (UID: " + model.uid + ")"
                            font.pixelSize: 13
                            color: "#a6adc8"
                        }

                        Label {
                            text: "Seat: " + model.seat
                            font.pixelSize: 13
                            color: "#a6adc8"
                        }
                    }

                    // Terminate Button
                    Button {
                        text: "Terminate"
                        font.pixelSize: 13
                        Layout.preferredWidth: 100

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: "#1e1e2e"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.hovered ? "#f38ba8" : "#eba0ac"
                            radius: 6
                        }

                        onClicked: {
                            confirmDialog.sessionId = model.session;
                            confirmDialog.visible = true;
                        }
                    }
                }
            }

            // Empty state
            Label {
                anchors.centerIn: parent
                text: "No active sessions"
                font.pixelSize: 16
                color: "#6c7086"
                visible: sessionListView.count === 0
            }
        }
    }

    // Confirmation Dialog
    Rectangle {
        id: confirmDialog
        anchors.centerIn: parent
        width: 400
        height: 180
        color: "#1e1e2e"
        radius: 10
        border.color: "#313244"
        border.width: 2
        visible: false
        z: 100

        property string sessionId: ""

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Label {
                text: "Terminate Session?"
                font.pixelSize: 20
                font.bold: true
                color: "#cdd6f4"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Are you sure you want to terminate session " + confirmDialog.sessionId + "?"
                font.pixelSize: 14
                color: "#a6adc8"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#cdd6f4"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#45475a" : "#313244"
                        radius: 6
                    }

                    onClicked: confirmDialog.visible = false
                }

                Button {
                    text: "Terminate"
                    Layout.fillWidth: true

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#1e1e2e"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#f38ba8" : "#eba0ac"
                        radius: 6
                    }

                    onClicked: {
                        console.log("Terminating session:", confirmDialog.sessionId);
                        // LoginctlData.terminateSession(confirmDialog.sessionId);
                        removeSession(confirmDialog.sessionId);
                        confirmDialog.visible = false;
                    }
                }
            }
        }
    }

    // Add Session Dialog
    Rectangle {
        id: addDialog
        anchors.centerIn: parent
        width: 400
        height: 200
        color: "#1e1e2e"
        radius: 10
        border.color: "#313244"
        border.width: 2
        visible: false
        z: 100

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: "Add Session"
                font.pixelSize: 20
                font.bold: true
                color: "#cdd6f4"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Note: Sessions are typically created by the login process.\nThis is for demonstration purposes."
                font.pixelSize: 12
                color: "#a6adc8"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "Close"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 100

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: "#cdd6f4"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? "#45475a" : "#313244"
                    radius: 6
                }

                onClicked: addDialog.visible = false
            }
        }
    }

    // Mock Data Model
    ListModel {
        id: sessionModel
    }

    Component.onCompleted: {
        loadMockData();
        // In real usage, connect to LoginctlData:
        // sessionModel.clear();
        // for (var i = 0; i < LoginctlData.sessions.length; i++) {
        //     sessionModel.append(LoginctlData.sessions[i]);
        // }
    }

    function loadMockData() {
        sessionModel.clear();
        sessionModel.append({
            session: "1",
            uid: "1000",
            user: "john",
            seat: "seat0"
        });
        sessionModel.append({
            session: "2",
            uid: "1001",
            user: "jane",
            seat: "seat0"
        });
        sessionModel.append({
            session: "c3",
            uid: "1000",
            user: "john",
            seat: ""
        });
    }

    function removeSession(sessionId) {
        for (var i = 0; i < sessionModel.count; i++) {
            if (sessionModel.get(i).session === sessionId) {
                sessionModel.remove(i);
                break;
            }
        }
    }
}
