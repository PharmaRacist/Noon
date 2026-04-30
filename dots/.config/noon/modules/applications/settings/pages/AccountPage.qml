import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.store
import qs.services
import qs.common
import qs.common.widgets
import qs.common.functions

StyledRect {
    anchors.fill: parent
    anchors.margins: Padding.large
    color: Colors.colLayer1
    radius: Rounding.verylarge

    Item {
        id: header
        height: 180
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Padding.massive
        RowLayout {
            anchors.fill: parent
            spacing: Padding.massive
            StyledRect {
                radius: Rounding.full
                implicitSize: 150
                color: Colors.colLayer3
                clip: true
                CroppedImage {
                    z: 2
                    clip: true
                    radius: Rounding.full
                    anchors.margins: Padding.huge
                    anchors.fill: parent
                    source: SysInfoService.userPfp
                }
                Symbol {
                    z: 1
                    text: "person"
                    color: Colors.colOnLayer2
                    anchors.centerIn: parent
                    font.pixelSize: 80
                    fill: 1
                }
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: -Padding.normal
                StyledText {
                    text: StringUtils.capitalizeFirstLetter(SysInfoService.username)
                    color: Colors.colOnLayer3
                    font.pixelSize: Fonts.sizes.title
                    font.variableAxes: Fonts.variableAxes.title
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }
                StyledText {
                    text: SysInfoService.distroName
                    wrapMode: Text.Wrap
                    color: Colors.colSubtext
                    font.pixelSize: Fonts.sizes.subTitle
                    font.variableAxes: Fonts.variableAxes.main
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }
            }
            GroupButtonWithIcon {
                Layout.alignment: Qt.AlignBottom
                implicitSize: 50
                materialIcon: "restart_alt"
                releaseAction: () => AuthManager.reload()
            }
        }
    }
    StyledRect {
        anchors.top: header.bottom
        anchors.margins: Padding.huge
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        color: Colors.colLayer2
        radius: Rounding.verylarge
        StyledListView {
            hint: false
            anchors.fill: parent
            anchors.margins: Padding.massive
            spacing: Padding.large
            _model: Object.values(AuthManager.integrations)
            delegate: AccountAuthSection {}
        }
    }
    component AccountAuthSection: StyledRect {
        required property var modelData
        required property int index
        readonly property bool isAuth: AuthManager?.isAuth(modelData.authId) ?? false // false
        color: Colors.colLayer3
        radius: Rounding.huge
        anchors.right: parent?.right
        anchors.left: parent?.left
        height: 85

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Padding.massive
            anchors.rightMargin: Padding.massive
            spacing: Padding.huge

            StyledRect {
                implicitSize: 65
                color: Colors.colLayer4
                radius: Rounding.full
                clip: true
                Favicon {
                    anchors.centerIn: parent
                    domainName: modelData?.domain
                    size: parent.implicitSize * 0.7
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: modelData.name
                    color: Colors.colOnLayer4
                    font.pixelSize: Fonts.sizes.large
                    font.variableAxes: Fonts.variableAxes.title
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }
                StyledText {
                    text: modelData.description
                    wrapMode: Text.Wrap
                    color: Colors.colSubtext
                    font.pixelSize: Fonts.sizes.normal
                    font.variableAxes: Fonts.variableAxes.main
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }
            }
            ButtonGroup {
                spacing: Padding.large

                GroupButtonWithIcon {
                    enabled: isAuth
                    implicitSize: 45
                    buttonRadius: Rounding.full
                    colBackground: Colors.colLayer4Hover
                    materialIcon: "logout"
                    releaseAction: () => {
                        AuthManager.revoke(modelData.authId);
                    }
                }

                GroupButton {
                    baseHeight: 45
                    baseWidth: 75
                    buttonRadius: Rounding.full
                    buttonRadiusPressed: Rounding.small
                    clickedWidth: baseWidth + 40
                    toggled: isAuth
                    colBackground: Colors.colLayer4Hover
                    Symbol {
                        anchors.centerIn: parent
                        text: isAuth ? "check" : "add"
                        font.pixelSize: 24
                        color: isAuth ? Colors.colOnPrimary : Colors.colOnLayer4
                    }
                    releaseAction: () => {
                        AuthManager.auth(modelData.id);
                    }
                }
            }
        }
    }
}
