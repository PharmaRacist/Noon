import Noon.Utils.Dialogs
import qs.common

RippleButtonWithIcon {
    id: root
    implicitSize: 45
    colBackground: root.colors.colLayer3
    materialIcon: "match_case"
    materialIconFill: true
    property alias value: fontDialog.selectedFont.family

    FontDialog {
        id: fontDialog
        title: "Select a Font"
        onFontSelected: NoonUtils.callIpc("sidebar unpin")
    }
    onClicked: {
        fontDialog.open();
        NoonUtils.callIpc("sidebar pin");
    }
}
