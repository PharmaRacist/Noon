import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.services
import "./../common"
import qs.common.widgets

StyledIconImage {
    id: root
    source: NoonUtils.iconPath("edit-paste-symbolic")
    implicitSize: 18
    z: 99
    required property var bar
    property Component _clipboard_popup: GClipboardPopup {}
    Loader {
        id: _popup_loader
        active: false
        asynchronous: true
        sourceComponent: _clipboard_popup
        onLoaded: {
            _popup_loader.item.bar = bar;
            _popup_loader.item.visible = true;
        }
        onActiveChanged: if (active && _popup_loader.item) {
            _popup_loader.item.visible = true;
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onPressed: event => {
            if (event.button == Qt.LeftButton) {
                _popup_loader.active = !_popup_loader.active;
            } else if (event.button == Qt.RightButton) {
                _clipboard_context_menu.popup();
            }
        }
    }
}
