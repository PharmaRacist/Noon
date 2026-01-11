import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.functions
import qs.common.widgets
import qs.services
import qs.store

BottomDialog {
    id: root

    property bool expanded: parent.expanded
    property int comboWidth: 240

    function findIndex(array, value, valueRole) {
        for (let i = 0; i < array.length; i++) {
            if (array[i][valueRole] === value)
                return i;
        }
        return 0;
    }

    enableStagedReveal: false
    bottomAreaReveal: true
    hoverHeight: 180
    collapsedHeight: 120
    expand: true
    clip: true

    bgAnchors {
        leftMargin: expanded ? 500 : undefined
        rightMargin: expanded ? 500 : undefined
    }

    anchors {
        rightMargin: Padding.normal
        leftMargin: Padding.normal
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.verylarge
        spacing: Padding.large

        RowLayout {
            Layout.fillWidth: true
            spacing: Padding.large

            StyledComboBox {
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                model: ThemeStore.themes
                textRole: "name"
                valueRole: "value"
                currentIndex: root.findIndex(ThemeStore.themes, Mem.states.desktop.appearance.theme, "value")
                onActivated: index => {
                    if (index >= 0 && index < ThemeStore.themes.length)
                        GowallService.convertTheme(ThemeStore.themes[index].value);
                }
            }

            StyledComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                model: ThemeStore.modes
                textRole: "name"
                valueRole: "value"
                currentIndex: root.findIndex(ThemeStore.modes, Mem.states.desktop.appearance.scheme, "value")
                onActivated: index => {
                    if (index >= 0 && index < ThemeStore.modes.length)
                        WallpaperService.updateScheme(ThemeStore.modes[index].value);
                }
            }

            StyledComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                model: ThemeStore.palettes
                textRole: "name"
                valueRole: "name"
                displayText: Mem.options.appearance.colors.palatteName
                onActivated: index => {
                    if (index >= 0 && index < ThemeStore.palettes.length)
                        Mem.options.appearance.colors.palatteName = ThemeStore.palettes[index];
                }
            }
        }
        StyledTextField {
            property string sanitizedAddress: "~" + FileUtils.trimFileProtocol(Mem.states.desktop.bg.currentFolder.slice(Directories.standard.home.length))
            Layout.preferredHeight: 45
            Layout.fillWidth: true
            text: sanitizedAddress
            placeholderText: "Wallpaper folder path..."
            placeholderTextColor: Colors.colOnLayer1
            color: Colors.colOnLayer1
            Keys.onEscapePressed: focus = false
            onAccepted: Mem.states.desktop.bg.currentFolder = Qt.resolvedUrl(text.replace("~", Directories.standard.home))
        }
    }
}
