import Noon.Utils.Qr
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common
import qs.common.utils
import qs.common.widgets
import qs.services

Item {
    id: root
    anchors.fill: parent

    property var selectedFiles: []

    QtObject {
        id: incomingTransfer
        property bool pending: false
        property string sender: ""
        property var files: []
        property int totalBytes: 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.small
        spacing: Padding.veryhuge

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: Padding.small

            StyledText {
                text: "QuickShare"
                Layout.fillWidth: true
                color: Colors.colOnLayer1
                font.variableAxes: Fonts.variableAxes.title
                font.family: Fonts.family.main
                font.pixelSize: Fonts.sizes.title
            }

            StyledText {
                id: statusText
                text: ""
                visible: text.length > 0
                Layout.fillWidth: true
                font.pixelSize: Fonts.sizes.small
            }
        }

        // Receive / Discover buttons
        RLayout {
            Layout.fillWidth: true
            Layout.maximumHeight: 45

            OptionButton {
                toggled: QuickShareService.receiving
                downAction: () => {
                    QuickShareService.receiving ? QuickShareService.stopReceiving() : QuickShareService.startReceiving();
                }
                materialIcon: "cloud_download"
                label: "Receive"
            }

            OptionButton {
                materialIcon: "search"
                label: "Discover"
                downAction: () => {
                    QuickShareService.discoverDevices();
                }
                toggled: QuickShareService.discoveredDevices.length > 0
            }
        }

        // ── Receive-info card ────────────────────────────────────────────────
        // Appears once the backend is advertising and receiveInfo is valid.
        // Shows ip:port, endpoint name, optional PIN, and a QR canvas.
        StyledRect {
            visible: QuickShareService.receiving && QuickShareService.receiveInfo.valid
            color: Colors.colLayer1
            radius: Rounding.large
            Layout.fillWidth: true
            implicitHeight: rcvRow.implicitHeight + Padding.huge * 2

            RLayout {
                id: rcvRow
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Padding.large
                }
                spacing: Padding.large

                // QR-code box
                StyledRect {
                    implicitWidth: 120
                    implicitHeight: 120
                    radius: Rounding.normal
                    color: "white"

                    QrCode {
                        anchors.fill: parent
                        anchors.margins: Padding.small
                        text: QuickShareService.receiveInfo.qrData
                    }
                }

                // Endpoint details
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Padding.verysmall

                    StyledText {
                        text: QuickShareService.receiveInfo.endpointName || "This device"
                        font.pixelSize: Fonts.sizes.large
                        font.weight: 600
                        color: Colors.colOnLayer1
                    }

                    StyledText {
                        visible: QuickShareService.receiveInfo.valid
                        text: QuickShareService.receiveInfo.ip + ":" + QuickShareService.receiveInfo.port
                        font.pixelSize: Fonts.sizes.small
                        color: Colors.colSubtext
                    }

                    // PIN badge – only shown when the backend supplies one
                    StyledRect {
                        visible: QuickShareService.receiveInfo.authToken !== ""
                        color: Colors.colSecondaryContainer
                        radius: Rounding.small
                        implicitHeight: 28
                        implicitWidth: pinLabel.implicitWidth + Padding.large * 2

                        StyledText {
                            id: pinLabel
                            anchors.centerIn: parent
                            text: "PIN: " + QuickShareService.receiveInfo.authToken
                            font.pixelSize: Fonts.sizes.normal
                            font.weight: 700
                            color: Colors.colOnSecondaryContainer
                        }
                    }

                    StyledText {
                        text: "Waiting for sender…"
                        font.pixelSize: Fonts.sizes.small
                        color: Colors.colSubtext
                    }
                }
            }
        }

        // ── Incoming-transfer banner ─────────────────────────────────────────
        StyledRect {
            visible: incomingTransfer.pending
            color: Colors.colSecondaryContainer
            radius: Rounding.large
            Layout.fillWidth: true
            implicitHeight: 84

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Padding.large
                spacing: Padding.small

                StyledText {
                    Layout.fillWidth: true
                    text: `Incoming from ${incomingTransfer.sender}: ${incomingTransfer.files.join(", ")}`
                    font.pixelSize: Fonts.sizes.normal
                    color: Colors.colOnSecondaryContainer
                    elide: Text.ElideRight
                }

                RLayout {
                    Layout.fillWidth: true
                    Spacer {}
                    RippleButtonWithIcon {
                        materialIcon: "check"
                        colBackground: Colors.colPrimary
                        colBackgroundHover: Colors.colPrimaryHover
                        iconColor: Colors.colOnPrimary
                        buttonRadius: Rounding.massive
                        releaseAction: () => {
                            QuickShareService.startReceiving();
                            incomingTransfer.pending = false;
                            setStatus("Accepting transfer…");
                        }
                    }

                    RippleButtonWithIcon {
                        materialIcon: "close"
                        colBackground: Colors.colError
                        colBackgroundHover: Colors.colErrorHover
                        iconColor: Colors.colOnError
                        buttonRadius: Rounding.massive
                        releaseAction: () => {
                            incomingTransfer.pending = false;
                            QuickShareService.stopReceiving();
                            setStatus("Transfer declined.");
                        }
                    }
                }
            }
        }

        StyledText {
            text: "Nearby Devices"
            font.pixelSize: Fonts.sizes.normal
            color: Colors.colOnLayer1
        }

        StyledRect {
            color: Colors.colLayer1
            radius: Rounding.large
            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledListView {
                id: deviceList
                anchors.fill: parent
                anchors.margins: Padding.large
                clip: true
                model: QuickShareService.discoveredDevices
                spacing: Padding.verysmall

                delegate: StyledDelegateItem {
                    required property var modelData
                    height: 64
                    width: deviceList.width
                    buttonRadius: Rounding.large
                    title: modelData.name
                    materialIcon: "devices"
                    releaseAction: () => {
                        if (root.selectedFiles.length === 0) {
                            setStatus("Select files first.");
                            return;
                        }
                        for (var i = 0; i < root.selectedFiles.length; i++)
                            QuickShareService.sendFile(modelData.index, root.selectedFiles[i]);
                        setStatus(`Sending ${root.selectedFiles.length} file(s) to ${modelData.name}…`);
                    }
                }

                PagePlaceholder {
                    shown: deviceList.count === 0
                    icon: "share"
                    iconFill: 1
                    title: "No devices found"
                    shape: MaterialShape.Shape.Clover4Leaf
                    iconSize: 100
                }
            }
        }

        // ── Footer ───────────────────────────────────────────────────────────
        StyledRect {
            color: Colors.colPrimary
            radius: Rounding.large
            implicitHeight: selectedFilesList.visible ? 125 : 72
            Layout.fillWidth: true
            Layout.margins: Padding.small

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: Padding.massive
                anchors.rightMargin: Padding.massive

                Spacer {
                    visible: selectedFilesList.visible
                }

                RLayout {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.minimumHeight: 55
                    Layout.fillHeight: selectedFilesList.visible

                    StyledText {
                        Layout.fillWidth: true
                        text: selectedFilesList.visible ? root.selectedFiles.length + " file(s) selected" : "Add Files"
                        font {
                            pixelSize: Fonts.sizes.large
                            weight: 500
                        }
                        color: Colors.colOnPrimary
                    }

                    RippleButtonWithIcon {
                        toggled: root.selectedFiles.length > 0
                        materialIcon: toggled ? "send" : "attach_file_add"
                        iconColor: toggled ? Colors.colOnSecondaryContainer : Colors.colOnPrimary
                        buttonRadius: 999
                        implicitSize: 42
                        materialIconFill: true
                        colBackgroundToggledHover: Colors.colSecondaryContainerHover
                        colBackgroundToggled: Colors.colSecondaryContainer
                        colBackground: "transparent"
                        colBackgroundHover: "transparent"
                        colRipple: Colors.colPrimaryContainerActive
                        releaseAction: () => {
                            if (!toggled)
                                filePicker.open();
                        }
                    }

                    RippleButtonWithIcon {
                        visible: root.selectedFiles.length > 0
                        materialIcon: "delete"
                        iconColor: Colors.colOnPrimary
                        buttonRadius: 999
                        implicitSize: 36
                        colBackground: "transparent"
                        colBackgroundHover: "transparent"
                        colRipple: Colors.colPrimaryContainerActive
                        releaseAction: () => {
                            root.selectedFiles = [];
                            setStatus("File selection cleared.");
                        }
                    }
                }

                StyledListView {
                    id: selectedFilesList
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    visible: root.selectedFiles.length > 0
                    clip: true
                    hint: false
                    orientation: ListView.Horizontal
                    spacing: Padding.verysmall
                    model: root.selectedFiles

                    delegate: StyledRect {
                        required property var modelData
                        required property int index
                        implicitWidth: 42
                        implicitHeight: 42
                        radius: Rounding.large
                        color: Colors.colSecondaryContainer

                        Symbol {
                            anchors.centerIn: parent
                            fill: 1
                            color: Colors.colOnSecondaryContainer
                            font.pixelSize: 18
                            text: "draft"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                var updated = root.selectedFiles.slice();
                                updated.splice(index, 1);
                                root.selectedFiles = updated;
                            }
                            StyledToolTip {
                                extraVisibleCondition: parent.containsMouse
                                content: modelData.split("/").pop() + "\n(click to remove)"
                            }
                        }
                    }
                }
            }
        }
    }

    FilePicker {
        id: filePicker
        title: "Select files to share via QuickShare"
        multipleSelection: true
        fileFilters: [filePicker.filterPresets.ALL]
        onFileSelected: files => {
            var picked = Array.isArray(files) ? files : [files];
            var merged = root.selectedFiles.slice();
            for (var i = 0; i < picked.length; i++)
                if (merged.indexOf(picked[i]) === -1)
                    merged.push(picked[i]);
            root.selectedFiles = merged;
            setStatus(picked.length + " file(s) added.");
        }
        onError: message => setStatus("Error: " + message, true)
    }

    Connections {
        target: QuickShareService

        function onReceiveInfoReady() {
            var info = QuickShareService.receiveInfo;
            setStatus("Advertising: " + info.endpointName + " @ " + info.ip + ":" + info.port);
        }

        function onTransferRequest(sender, files, totalBytes) {
            incomingTransfer.sender = sender;
            incomingTransfer.files = files;
            incomingTransfer.totalBytes = totalBytes;
            incomingTransfer.pending = true;
            setStatus(`Transfer request from ${sender}`);
        }

        function onTransferComplete(files, outputDir) {
            incomingTransfer.pending = false;
            setStatus(`Saved ${files.length} file(s) to ${outputDir}`);
        }

        function onSendComplete(fileName) {
            setStatus(`Sent: ${fileName.split("/").pop()}`);
            root.selectedFiles = [];
        }

        function onDeviceFound(index, name) {
            setStatus(`Found: ${name}`);
        }

        function onDiscoverDone(total) {
            setStatus(total > 0 ? `${total} device(s) found` : "No devices found");
        }

        function onError(message) {
            setStatus(`Error: ${message}`, true);
        }
    }

    function setStatus(msg, isError) {
        statusText.text = msg;
        statusText.color = isError ? Colors.colError : Colors.colSubtext;
        statusClear.restart();
    }

    Timer {
        id: statusClear
        interval: 3000
        onTriggered: {
            statusText.text = "";
            statusText.color = Colors.colSubtext;
        }
    }

    component OptionButton: GroupButton {
        id: optBtn
        property string label
        property string materialIcon
        buttonRadius: Rounding.massive
        buttonRadiusPressed: Rounding.small
        Layout.fillWidth: true
        Layout.fillHeight: true
        buttonTextPadding: Padding.huge
        baseHeight: 42
        contentItem: RLayout {
            spacing: 4
            Symbol {
                color: optBtn.toggled ? Colors.colOnPrimary : Colors.colOnLayer1
                Layout.leftMargin: Padding.massive
                text: optBtn.materialIcon
                fill: optBtn.toggled ? 1 : 0
                font.pixelSize: 20
            }
            StyledText {
                text: optBtn.label
                color: optBtn.toggled ? Colors.colOnPrimary : Colors.colOnLayer1
                font.pixelSize: Fonts.sizes.large
            }
        }
    }
}
