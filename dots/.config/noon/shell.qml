//@ pragma UseQApplication
//@ pragma RespectSystemStyle
//@ pragma Env QT_AUTO_SCREEN_SCALE_FACTOR=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import qs.common
import qs.common.utils
import qs.modules.main
import qs.modules.xp

ShellRoot {
    property string mode: Mem.options.desktop.shell.mode ?? "main" // "xp" "main:noon"

    WidgetLoader {
        active: mode === "xp"

        XP {
        }

    }

    WidgetLoader {
        active: mode !== "xp"

        Main {
        }

    }

    WidgetLoader {
        IPC {
        }

    }

}
