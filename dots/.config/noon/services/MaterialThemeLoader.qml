pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.store

Singleton {
    id: root

    property string filePath: Directories.generatedMaterialThemePath

    onFilePathChanged: {
        if (themeFileView.loaded) {
            root.applyColors(themeFileView.text());
        }
    }

    // Simple vibrance controls
    property bool enableChroma: true
    property real chromaMultiplier: Mem.states.desktop.appearance.colors.chroma
    property string themesDir: 'root:/store/colorPresets'

    onChromaMultiplierChanged: if (themeFileView.loaded) {
        root.applyColors(themeFileView.text());
        delayedThemeRefresh.restart();
    }

    // Theme system
    property string currentThemePreset: Mem.options.appearance.colors.palatteName
    property bool useThemePresets: Mem.options.appearance.colors.palatte
    property var customColors: ({})

    // Loaded themes cache
    property var loadedThemes: ({})

    // Available theme files (add new themes here)
    readonly property var availableThemes: ThemeData.availableColorPalettes ?? []
    onCurrentThemePresetChanged: if (themeFileView.loaded) {
        root.applyColors(themeFileView.text());
    }

    onUseThemePresetsChanged: {
        if (themeFileView.loaded) {
            root.applyColors(themeFileView.text());
        }
    }

    onCustomColorsChanged: {
        if (themeFileView.loaded) {
            root.applyColors(themeFileView.text());
        }
    }

    function reapplyTheme() {
        themeFileView.reload();
    }

    function boostColorVibrance(color, multiplier) {
        if (!color || multiplier === 1.0)
            return color;
        return Qt.hsla(color.hslHue, Math.min(1.0, color.hslSaturation * multiplier), color.hslLightness, color.hslAlpha);
    }

    function loadTheme(themeName) {
        if (loadedThemes.hasOwnProperty(themeName)) {
            return loadedThemes[themeName];
        }

        try {
            const component = Qt.createComponent(`${themesDir}/${themeName}.qml`);
            if (component.status === Component.Ready) {
                const themeObject = component.createObject(root);
                if (themeObject && themeObject.colors) {
                    loadedThemes[themeName] = themeObject.colors;
                    return themeObject.colors;
                }
            } else {
                console.warn(`Failed to load theme ${themeName}:`, component.errorString());
            }
        } catch (e) {
            console.warn(`Error loading theme ${themeName}:`, e);
        }

        return null;
    }

    function applyColors(fileContent) {
        const json = JSON.parse(fileContent);

        for (const key in json) {
            if (json.hasOwnProperty(key)) {
                const camelCaseKey = key.replace(/_([a-z])/g, g => g[1].toUpperCase());
                const m3Key = `m3${camelCaseKey}`;

                let finalColor;

                // Priority: Custom Colors > Theme Presets > Generated Colors
                if (customColors.hasOwnProperty(key)) {
                    finalColor = customColors[key];
                } else if (useThemePresets && currentThemePreset !== "auto") {
                    const themeColors = loadTheme(currentThemePreset);
                    if (themeColors && themeColors.hasOwnProperty(key)) {
                        finalColor = themeColors[key];
                    } else {
                        finalColor = json[key];
                        if (enableChroma && chromaMultiplier !== 1.0) {
                            finalColor = boostColorVibrance(Qt.color(finalColor), chromaMultiplier);
                        }
                    }
                } else {
                    finalColor = json[key];
                    if (enableChroma && chromaMultiplier !== 1.0) {
                        finalColor = boostColorVibrance(Qt.color(finalColor), chromaMultiplier);
                    }
                }

                Colors.m3[m3Key] = finalColor;
            }
        }
        WallpaperService.changeAccentColor(Colors.m3.m3primaryFixed);

        // Apply theme/custom colors not in generated file
        const colorsToApply = [];

        if (useThemePresets && currentThemePreset !== "auto") {
            const themeColors = loadTheme(currentThemePreset);
            if (themeColors) {
                colorsToApply.push(themeColors);
            }
        }

        colorsToApply.push(customColors);

        for (let colorSet of colorsToApply) {
            for (const key in colorSet) {
                if (colorSet.hasOwnProperty(key) && !json.hasOwnProperty(key)) {
                    const camelCaseKey = key.replace(/_([a-z])/g, g => g[1].toUpperCase());
                    const m3Key = `m3${camelCaseKey}`;
                    Colors.m3[m3Key] = colorSet[key];
                }
            }
        }

        Colors.m3.darkmode = (Colors.m3.m3background.hslLightness < 0.5);
    }

    // Helper functions
    function setThemePreset(presetName) {
        if (availableThemes.includes(presetName) || presetName === "auto") {
            currentThemePreset = presetName;
            useThemePresets = (presetName !== "auto");
        } else {
            console.warn(`Theme preset '${presetName}' not found`);
        }
    }

    function getAvailableThemes() {
        return availableThemes;
    }

    function setCustomColor(key, color) {
        let newCustom = Object.assign({}, customColors);
        newCustom[key] = color;
        customColors = newCustom;
    }

    function removeCustomColor(key) {
        let newCustom = Object.assign({}, customColors);
        delete newCustom[key];
        customColors = newCustom;
    }

    function clearCustomColors() {
        customColors = {};
    }

    function reloadTheme(themeName) {
        if (loadedThemes.hasOwnProperty(themeName)) {
            delete loadedThemes[themeName];
        }
        if (currentThemePreset === themeName) {
            reapplyTheme();
        }
    }

    Timer {
        id: delayedThemeRefresh
        interval: 50
        onTriggered: WallpaperService.updateScheme()
    }

    Timer {
        id: delayedFileRead
        interval: 100
        onTriggered: root.applyColors(themeFileView.text())
    }

    FileView {
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload();
            delayedFileRead.start();
        }
        onLoadedChanged: {
            const fileContent = themeFileView.text();
            root.applyColors(fileContent);
        }
    }
}
