pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var subScripts: ({
            "0": "\u2080",
            "1": "\u2081",
            "2": "\u2082",
            "3": "\u2083",
            "4": "\u2084",
            "5": "\u2085",
            "6": "\u2086",
            "7": "\u2087",
            "8": "\u2088",
            "9": "\u2089",
            "+": "\u208A",
            "-": "\u208B",
            "=": "\u208C",
            "(": "\u208D",
            ")": "\u208E",
            "a": "\u2090",
            "e": "\u2091",
            "o": "\u2092",
            "x": "\u2093",
            "h": "\u2095",
            "k": "\u2096",
            "l": "\u2097",
            "m": "\u2098",
            "n": "\u2099",
            "p": "\u209A",
            "s": "\u209B",
            "t": "\u209C"
        })

    readonly property var superScripts: ({
            "0": "\u2070",
            "1": "\u00B9",
            "2": "\u00B2",
            "3": "\u00B3",
            "4": "\u2074",
            "5": "\u2075",
            "6": "\u2076",
            "7": "\u2077",
            "8": "\u2078",
            "9": "\u2079",
            "+": "\u207A",
            "-": "\u207B",
            "=": "\u207C",
            "(": "\u207D",
            ")": "\u207E",
            "n": "\u207F",
            "i": "\u1D62"
        })

    // Regex for symbol mapping
    readonly property var symbolMap: ({
            "->": "\u2192",
            "<-": "\u2190",
            "<=>": "\u21CC",
            "+/-": "\u00B1",
            "deg": "\u00B0",
            "micro": "\u03BC",
            "alpha": "\u03B1",
            "beta": "\u03B2",
            "gamma": "\u03B3",
            "delta": "\u03B4",
            "ohm": "\u2126",
            "prescription": "\u211E" // ℞ symbol
            ,
            "approx": "\u2248"
        })

    function toSub(text) {
        return String(text).split('').map(c => subScripts[c] || c).join('');
    }

    function toSuper(text) {
        return String(text).split('').map(c => superScripts[c] || c).join('');
    }

    function cleanFormula(content) {
        if (!content)
            return "";
        let res = String(content);

        // Subscripts: H_2O
        res = res.replace(/_([0-9a-z\+\-\=\(\)]+)/g, (_, p1) => toSub(p1));

        // Superscripts: x^2
        res = res.replace(/\^([0-9a-z\+\-\=\(\)]+)/g, (_, p1) => toSuper(p1));

        // Symbols: replacing defined keywords with a single regex match
        const pattern = new RegExp(Object.keys(symbolMap).map(k => k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|'), 'g');
        res = res.replace(pattern, matched => symbolMap[matched]);

        return res;
    }
}
