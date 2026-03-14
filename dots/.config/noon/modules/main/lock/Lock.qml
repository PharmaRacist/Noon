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
            GlobalStates.main.locked = false;
        }
    }

    Connections {
        function onLockedChanged() {
            if (GlobalStates.main.locked) {
                NoonUtils.playSound("locked");
                lock.locked = true;
            } else if (!GlobalStates.main.locked) {
                NoonUtils.playSound("unlocked");
                lock.locked = false;
            }
        }

        target: GlobalStates.main
    }

    WlSessionLock {
        id: lock

        locked: GlobalStates.main.locked

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
