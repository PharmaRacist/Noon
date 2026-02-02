pragma Singleton
pragma ComponentBehavior: Bound
import qs.common
import qs.store
import qs.common.utils
import qs.common.functions
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var list: EmojisStore.avilableEmojies
    readonly property var frequentEmojis: {
        const emojis = Mem.states.services.emojis.frequentEmojies || [];
        const counts = {};

        emojis.forEach(e => counts[e] = (counts[e] || 0) + 1);

        return Object.entries(counts).sort((a, b) => b[1] - a[1]).map(([e]) => e);
    }
    function recordEmojiUse(emoji: string) {
        const emojiChar = emoji.split(' ')[0];
        Mem.states.services.emojis.frequentEmojies.push(emojiChar);
    }

    function searchEmojis(query: string) {
        if (!query || query.trim() === "") {
            return root.list;
        }

        const lowerQuery = query.toLowerCase();
        return root.list.filter(emoji => {
            return emoji.name.toLowerCase().includes(lowerQuery) || emoji.category.toLowerCase().includes(lowerQuery) || emoji.subcategory.toLowerCase().includes(lowerQuery) || emoji.emoji.includes(query);
        });
    }
}
