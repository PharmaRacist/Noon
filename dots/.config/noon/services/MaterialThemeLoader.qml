pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.store

Singleton {
    id: root

    property string filePath: currentThemePreset !== "auto"
        ? 'root:/store/colorPresets/' + currentThemePreset + '.json'
        : Directories.generatedMaterialThemePath

    property string currentThemePreset: Mem.options.appearance.colors.palatteName
    property var customColors: ({})
    readonly property var snakeToCamelRegex: /_([a-z])/g
    onCurrentThemePresetChanged:delayedFileRead.restart()

    function reapplyTheme() {
        themeFileView.reload();
    }

    function toM3Key(key) {
        var camelCase = key.replace(snakeToCamelRegex, function(g) { return g[1].toUpperCase(); });
        return 'm3' + camelCase;
    }

    function applyColors(fileContent) {
        var json = JSON.parse(fileContent);
        var colors = Colors.m3;

        var key, m3Key, finalColor;

        for (key in json) {
            m3Key = toM3Key(key);

            if (customColors.hasOwnProperty(key)) {
                finalColor = customColors[key];
            } else {
                finalColor = json[key];
            }

            colors[m3Key] = finalColor;
        }

        WallpaperService.changeAccentColor(colors.m3primaryFixed);

        for (key in customColors) {
            if (!json.hasOwnProperty(key)) {
                colors[toM3Key(key)] = customColors[key];
            }
        }

        colors.darkmode = (colors.m3background.hslLightness < 0.5);
    }

    Timer {
        id: delayedFileRead
        interval: 50
        onTriggered: root.applyColors(themeFileView.text())
    }

    FileView {
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            reload();
            delayedFileRead.restart();
        }
        onLoadedChanged: {
            if (loaded) {
                delayedFileRead.restart();
            }
        }
    }
}
