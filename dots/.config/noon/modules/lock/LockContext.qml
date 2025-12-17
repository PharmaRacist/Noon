import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs
import qs.modules.common

Scope {
    id: root

    enum ActionEnum {
        Unlock,
        Poweroff,
        Reboot
    }

    // These properties are in the context and not individual lock surfaces
    // so all surfaces can share the same state.
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property var targetAction: LockContext.ActionEnum.Unlock

    signal shouldReFocus
    signal unlocked(var targetAction)
    signal failed

    function resetTargetAction() {
        root.targetAction = LockContext.ActionEnum.Unlock;
    }

    function clearText() {
        root.currentText = "";
    }

    function resetClearTimer() {
        passwordClearTimer.restart();
    }

    function reset() {
        root.resetTargetAction();
        root.clearText();
        root.unlockInProgress = false;
    }

    function tryUnlock() {
        root.unlockInProgress = true;
        pam.start();
    }

    onCurrentTextChanged: {
        if (currentText.length > 0) {
            showFailure = false;
            GlobalStates.screenUnlockFailed = false;
        }
        GlobalStates.screenLockContainsCharacters = currentText.length > 0;
        passwordClearTimer.restart();
    }

    Timer {
        id: passwordClearTimer

        interval: 10000
        onTriggered: {
            root.reset();
        }
    }

    PamContext {
        id: pam

        // pam_unix will ask for a response for the password prompt
        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText);
        }
        // pam_unix won't send any important messages so all we need is the completion status.
        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked(root.targetAction);
            } else {
                root.clearText();
                root.unlockInProgress = false;
                GlobalStates.screenUnlockFailed = true;
                root.showFailure = true;
            }
        }
    }
}
