import Quickshell
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    function changePlasmaColor(colorSchemeName) {
        // This requires the 'plasma-apply-colorscheme' tool to be installed.
        return ['plasma-apply-colorscheme', colorSchemeName];
    }

    function changePlasmaAccentColor(accentColor) {
        // This requires the 'plasma-apply-colorscheme' tool to be installed.
        return ['plasma-apply-colorscheme', '-a', `"${accentColor}"`];
    }
    function changePlasmaFont({
        font,
        type = "font"
    }) {
        return ['kwriteconfig6', '--file', 'kdeglobals', '--group', 'General', '--key', type, '"JF Flat,11,-1,5,50,0,0,0,0,0"', font];
    }
    function changePlasmaIcons(iconThemeName) {
        // Uses 'kwriteconfig5' to directly modify the system settings.
        return ['kwriteconfig5', '--file', 'kdeglobals', '--group', 'Icons', '--key', 'Theme', iconThemeName];
    }

}
