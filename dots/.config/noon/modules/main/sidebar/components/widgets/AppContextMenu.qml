import QtQuick
import Quickshell
import qs.common
import qs.common.widgets

StyledMenu {
    content: [
        {
            "text": " Launch",
            "materialIcon": "launch",
            "action": function () {
                appGridView.appLaunched(model);
            }
        },
        {
            "text": "Pin",
            "materialIcon": "push_pin",
            "action": function () {
                const normalizedAppId = appItem.appId.toLowerCase();
                if (appItem.isPinned) {
                    Mem.states.favorites.apps = Mem.states.favorites.apps.filter(id => id.toLowerCase() !== normalizedAppId);
                } else {
                    if (!Mem.states.favorites.apps.some(id => id.toLowerCase() === normalizedAppId)) {
                        Mem.states.favorites.apps = [...Mem.states.favorites.apps, appItem.appId];
                    }
                }
            }
        }
    ]
}
