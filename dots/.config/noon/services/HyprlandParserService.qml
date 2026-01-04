import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
pragma Singleton
/*
    Simple Hyprland Parser to (read,write) to hyprland conf file
    - [ ] Prevent useless writes
*/

Singleton {
    id: root
    readonly property string configPath: Directories.standard.home + "/.config/noon/hypr/variables.conf"
    property var variables: ({})
    property bool isLoaded: false
    property bool initialLoadComplete: false

    function get(name) {
        return variables[name] !== undefined ? variables[name] : null;
    }

    function set(name, value) {
        if (!variables.hasOwnProperty(name))
            return false;
        // Convert value to match original type
        const originalValue = variables[name];
        const originalType = typeof originalValue;
        if (originalType === 'boolean')
            value = value === true || value === 1 || value === "1" || value === "true";
        else if (originalType === 'number')
            value = Number(value);
        else
            value = String(value);
        variables[name] = value;
        save();
        return true;
    }

    function getAll() {
        return variables;
    }

    function save() {
        if (!file.loaded || !initialLoadComplete) {
            console.error("HyprlandParser: Cannot save - file not ready");
            return false;
        }
        const content = file.text();
        if (!content)
            return false;
        const lines = content.split('\n').map((line) => {
            const match = line.match(/^\$(\w+)\s*=/);
            if (match && variables.hasOwnProperty(match[1])) {
                const name = match[1];
                const value = formatValue(variables[name]);
                const comment = line.match(/(\s+[#$].*)$/);
                return `$${name} = ${value}${comment ? comment[1] : ''}`;
            }
            return line;
        });
        const newContent = lines.join('\n');
        file.setText(newContent);
        console.log("HyprlandParser: File saved successfully");
        return true;
    }

    function reload() {
        if (!file.loaded)
            return;
        const parsed = {};
        file.text().split('\n').forEach((line) => {
            const match = line.match(/^\$(\w+)\s*=\s*(.+?)(?:\s+[#$].*)?$/);
            if (match)
                parsed[match[1]] = parseValue(match[2].trim());
        });
        variables = parsed;
        isLoaded = true;
    }

    function parseValue(str) {
        if (str.startsWith('"') && str.endsWith('"'))
            return str.slice(1, -1);
        if (str === 'true')
            return true;
        if (str === 'false')
            return false;
        const num = Number(str);
        return !isNaN(num) && !str.startsWith('$') ? num : str;
    }

    function formatValue(val) {
        if (typeof val === 'boolean')
            return val ? 'true' : 'false';
        if (typeof val === 'number')
            return String(val);
        return String(val).includes(' ') ? `"${val}"` : val;
    }

    FileView {
        id: file
        path: root.configPath
        watchChanges: true
        onLoadedChanged: {
            if (loaded)
                reload();
        }
        onTextChanged: {
            // Only reload on text changes after initial load
            if (initialLoadComplete)
                reload();
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            reload();
            initialLoadComplete = true;
        }
    }
}
