pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.common.widgets
import qs.services

Singleton {
    id: root

    readonly property var availableModes: Mem.options.bar.workspaces.availableModes ?? ["normal", "japanese", "roman", "custom", "words"]
    property string currentMode: {
        const configured = Mem.options.bar.workspaces.displayMode ?? "normal";
        return availableModes.includes(configured) ? configured : "normal";
    }
    property var customMapping: Mem.options.bar.workspaces.customMapping ?? ["○", "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩"]
    property string customFallback: Mem.options.bar.workspaces.customFallback ?? "●"
    readonly property var japaneseDigits: ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    readonly property var wordMapping: Mem.options.bar.workspaces.wordMapping ?? ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve"]

    function getFontFamily(mode) {
        switch (mode) {
        case "japanese":
            return "Noto Sans CJK JP";
        case "custom":
            return Fonts.family.iconMaterial;
        default:
            return "Rubik";
        }
    }

    function getFontWeight(mode) {
        switch (mode) {
        case "japanese":
        case "custom":
            return 300;
        default:
            return 400;
        }
    }

    function getFontPixelSize(mode, text) {
        switch (mode) {
        case "custom":
            return Fonts.sizes.huge;
        case "japanese":
            return Fonts.sizes.small;
        case "roman":
        case "words":
            return Fonts.sizes.small - ((text.length - 1) * 2);
        default:
            return Fonts.sizes.small - ((text.length - 1) * (text !== "10") * 2);
        }
    }

    function getTextStyle(mode, text) {
        return {
            "family": getFontFamily(mode),
            "weight": getFontWeight(mode),
            "pixelSize": getFontPixelSize(mode, text)
        };
    }

    function toRomanNumeral(num) {
        if (num < 1 || num > 3999)
            return num.toString();

        const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
        const numerals = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
        let result = "";
        let remaining = num;
        for (let i = 0; i < values.length; i++) {
            while (remaining >= values[i]) {
                result += numerals[i];
                remaining -= values[i];
            }
        }
        return result;
    }

    function toJapaneseNumber(num) {
        if (num < 1)
            return num.toString();

        if (num >= 10000) {
            const man = Math.floor(num / 10000);
            const remainder = num % 10000;
            let result = toJapaneseNumber(man) + "万";
            if (remainder > 0)
                result += toJapaneseNumber(remainder);

            return result;
        }
        let result = "";
        let temp = num;
        const units = [
            {
                "value": 1000,
                "char": "千"
            },
            {
                "value": 100,
                "char": "百"
            },
            {
                "value": 10,
                "char": "十"
            }
        ];
        for (const unit of units) {
            if (temp >= unit.value) {
                const count = Math.floor(temp / unit.value);
                result += (count === 1 ? "" : japaneseDigits[count]) + unit.char;
                temp %= unit.value;
            }
        }
        if (temp > 0)
            result += japaneseDigits[temp];

        return result;
    }

    function toCustomNumber(num) {
        if (num >= 0 && num < customMapping.length)
            return customMapping[num];

        return customFallback;
    }

    function toWordNumber(num) {
        if (num >= 0 && num < wordMapping.length)
            return wordMapping[num];

        return num.toString();
    }

    function getDisplayText(num) {
        switch (currentMode) {
        case "japanese":
            return toJapaneseNumber(num);
        case "roman":
            return toRomanNumeral(num);
        case "custom":
            return toCustomNumber(num);
        case "words":
            return toWordNumber(num);
        case "normal":
        default:
            return num.toString();
        }
    }

    function getDisplayTextForMode(num, mode) {
        switch (mode) {
        case "japanese":
            return toJapaneseNumber(num);
        case "roman":
            return toRomanNumeral(num);
        case "custom":
            return toCustomNumber(num);
        case "words":
            return toWordNumber(num);
        case "normal":
        default:
            return num.toString();
        }
    }
}
