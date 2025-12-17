import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleButton {
    id: root

    buttonName: ""
    buttonIcon: "linked_services"
    onClicked: {
        root.toggled = !root.toggled;
        if (root.toggled)
            Quickshell.execDetached(["bash", "-c", "syncthing serve"]);
        else
            Quickshell.execDetached(["bash", "-c", "syncthing cli operations shutdown"]);
    }

    Process {
        id: updateState

        running: true
        command: ["pidof", "syncthing"]
        onExited: (exitCode, exitStatus) => {
            root.toggled = exitCode === 0;
        }
    }

    Process {
        id: fetchAvailability

        running: true
        command: ["bash", "-c", "command -v syncthing"]
        onExited: (exitCode, exitStatus) => {
            root.visible = exitCode === 0;
        }
    }

    StyledToolTip {
        content: qsTr("Syncthing toggle")
    }

}
