pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.common.utils
import qs.common.functions
import qs.common.widgets
import qs.services

/*
    Just a dictionary service
*/
Singleton {
    id: root

    function lookup(word) {
        mainProc.word = word;
        mainProc.running = false;
        mainProc.running = true;
        return getTheFirstMeaning();
    }

    function getTheFirstMeaning() {
        if (mainProc.data) {
            let meaning = mainProc.data[0]?.meanings[0]?.definitions[0]?.definition;
            return meaning;
        }
    }

    Process {
        id: mainProc
        property string word
        property var data
        command: ["curl", "-s", `https://api.dictionaryapi.dev/api/v2/entries/en/${word}`]
        stdout: SplitParser {
            onRead: data => {
                const parsed = JSON.parse(data);
                mainProc.data = null;
                mainProc.data = parsed;
            }
        }
    }
}
