import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.common
import qs.common.utils
import "startMenu"
import "wallpaper"
import "controlPanel"
import "bar"


/*  TODOs -->
    - [-] Bar
        - [ ] System Tray Finalization  
            - [ ] New Menu Items
        - [ ] Figure out A Better Gradiant Border Thingie
        - [ ] Pinned Apps Section
    - [ ] Animation Feedbacks
    - [ ] Colors
        - [-] Support for 3 other palettes
        - [ ] Enhance Shadows
    - [ ] Control Panel Window 
    - [ ] StartMenu
        - [-] Just A Dummy on Beam IPC
    - [ ] Desktop Shortcuts
    - [ ] Nixus Dock Replica
    - [ ] A Sort of Wallpaper Selector
    - [ ] An integration with external Qt, GTK Theming, Icon
    - [ ] Configuration Way for not missing Main Noon
        - [ ] Preferably Modularized Plugins System
*/

Scope {
    Component.onCompleted: Noon.playSound("init","xp")
    WidgetLoader {
        Bar {}
    }
    WidgetLoader {
        StartMenu {}
    }
    WidgetLoader {
        ControlPanel {}
    }
    WidgetLoader {
        enabled: Mem.options.desktop.bg.useQs && Mem.states.desktop.bg.currentBg.length > 1 && !ToplevelManager?.activeToplevel?.fullscreen && !Mem.states.desktop.bg.isLive
        Wallpaper {}
    }
}
