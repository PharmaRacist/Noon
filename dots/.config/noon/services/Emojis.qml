pragma Singleton
pragma ComponentBehavior: Bound
import qs.modules.common.functions
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Emojis with usage tracking.
 */
Singleton {
    id: root
    property string emojiScriptPath: Directories.scriptsDir + "/emoji_service.sh"
    property string lineBeforeData: "### DATA ###"
    property list<var> list

    // Dynamic frequent emojis based on actual usage
    readonly property list<var> frequentEmojis: {
        const emojiArray = Mem.states.services.emojis?.frequentEmojies || [];

        // Count occurrences in the array
        const counts = {};
        for (let i = 0; i < emojiArray.length; i++) {
            const emoji = emojiArray[i];
            counts[emoji] = (counts[emoji] || 0) + 1;
        }

        // Sort by frequency and get top 12
        const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]).slice(0, 12).map(([emoji, _]) => emoji);

        return sorted;
    }

    readonly property var preparedEntries: list.map(a => ({
                name: Fuzzy.prepare(`${a}`),
                entry: a
            }))

    function recordEmojiUse(emoji: string) {
        const emojiChar = emoji.split(' ')[0];

        // Create new array to trigger reactivity
        const newArray = Mem.states.services.emojis.frequentEmojies.slice();
        newArray.push(emojiChar);

        Mem.states.services.emojis.frequentEmojies = newArray;
    }
    function resetUsageStats() {
        if (!Mem.states.services.emojis) {
            Mem.states.services.emojis = {};
        }
        Mem.states.services.emojis.frequentEmojies = {};
    }

    function fuzzyQuery(search: string): var {
        if (root.sloppySearch) {
            const results = entries.slice(0, 100).map(str => ({
                        entry: str,
                        score: Levendist.computeTextMatchScore(str.toLowerCase(), search.toLowerCase())
                    })).filter(item => item.score > root.scoreThreshold).sort((a, b) => b.score - a.score);
            return results.map(item => item.entry);
        }

        return Fuzzy.go(search, preparedEntries, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry;
        });
    }

    function load() {
        emojiFileView.reload();
    }

    function updateEmojis(fileContent) {
        const lines = fileContent.split("\n");
        const dataIndex = lines.indexOf(root.lineBeforeData);
        if (dataIndex === -1) {
            console.warn("No data section found in emoji script file.");
            return;
        }
        const emojis = lines.slice(dataIndex + 1).filter(line => line.trim() !== "");
        root.list = emojis.map(line => line.trim());
    }

    FileView {
        id: emojiFileView
        path: Qt.resolvedUrl(root.emojiScriptPath)
        onLoadedChanged: {
            const fileContent = emojiFileView.text();
            root.updateEmojis(fileContent);
        }
    }
}
