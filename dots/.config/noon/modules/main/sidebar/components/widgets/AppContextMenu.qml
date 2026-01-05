import QtQuick
import Quickshell
import qs.common
import qs.common.widgets

StyledMenu {
    content:[
        {
            "text": " Launch",
            "materialIcon":"launch",
            "action": function(){
                appGridView.appLaunched(model)
            } 
        },
        {
            "text": "Pin",
            "materialIcon": "push_pin",
            "action": function(){ 
                const normalizedAppId = appItem.appId.toLowerCase();
                if (appItem.isPinned) {
                    Mem.states.dock.pinnedApps = Mem.states.dock.pinnedApps.filter(id => id.toLowerCase() !== normalizedAppId);
                } else {
                    if (!Mem.states.dock.pinnedApps.some(id => id.toLowerCase() === normalizedAppId)) {
                        Mem.states.dock.pinnedApps = [...Mem.states.dock.pinnedApps, appItem.appId];
                    }
                }
  
            }
        }
    ]
}
