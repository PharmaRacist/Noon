import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pam
import qs.common
import qs.common.utils
import qs.services

Scope {
    id: root

    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false;
            GlobalStates.locked = false;
        }
    }

    Connections {
        function onLockedChanged() {
            if (GlobalStates.locked) {
                Noon.playSound("locked");
                lock.locked = true;
            } else if (!GlobalStates.locked) {
                Noon.playSound("unlocked");
                lock.locked = false;
            }
        }

        target: GlobalStates
    }

    WlSessionLock {
        id: lock

        locked: GlobalStates.locked

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }

        }

    }

}
