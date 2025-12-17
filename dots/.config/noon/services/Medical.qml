pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Qt.labs.platform
import QtQuick

/**
 * Basic service to handle medical dictionary lookups using Merriam-Webster API
 */

Singleton {
    id: root

    readonly property string apiKeyEnvVarName: "MW_API_KEY"
    readonly property string baseEndpoint: "https://www.dictionaryapi.com/api/v3/references/medical/json"

    property var results: []
    property string apiKey:  KeyringStorage.keyringData?.apiKeys?.medicalApiKey
    readonly property bool apiKeyLoaded: KeyringStorage.loaded
    readonly property bool hasApiKey: apiKey.length > 0

    Component.onCompleted: {
        if (!hasApiKey && apiKeyLoaded) {
            addApiKeyAdvice();
        }
    }

    function addApiKeyAdvice() {
        console.log("API Key required for Merriam-Webster Medical Dictionary");
        console.log("Get your key at: https://dictionaryapi.com/register/index");
        console.log("Set key with: setApiKey(\"your-key-here\")");
    }

    function setApiKey(key) {
        if (!key || key.length === 0) {
            addApiKeyAdvice();
            return;
        }
        KeyringStorage.setNestedField(["apiKeys", "medicalApiKey"], key.trim());
        console.log("API key set for Merriam-Webster Medical Dictionary");
    }

    function clearResults() {
        root.results = [];
    }

    Process {
        id: requester
        property var baseCommand: ["bash", "-c"]
        property string searchTerm: ""
        property string responseBuffer: ""

        function makeRequest(term) {
            if (!root.hasApiKey) {
                console.log("No API key set. Use setApiKey() first.");
                root.addApiKeyAdvice();
                return;
            }

            if (!term || term.length === 0) {
                console.log("Search term cannot be empty");
                return;
            }

            requester.searchTerm = term.toLowerCase().trim();
            requester.environment[root.apiKeyEnvVarName] = root.apiKey;

            const endpoint = `${root.baseEndpoint}/${encodeURIComponent(requester.searchTerm)}?key=\$\{${root.apiKeyEnvVarName}\}`;
            const requestCommand = `curl -s "${endpoint}"`;

            requester.command = baseCommand.concat([requestCommand]);
            requester.responseBuffer = "";
            requester.running = true;
        }

        stdout: SplitParser {
            onRead: data => {
                if (data.length === 0)
                    return;
                requester.responseBuffer += data;
            }
        }

        onExited: (exitCode, exitStatus) => {
            try {
                const response = JSON.parse(requester.responseBuffer);

                // Debug logging - remove this in production
                console.log("Raw API response:", JSON.stringify(response, null, 2));

                if (Array.isArray(response) && response.length > 0) {
                    // Check if first item is a string (suggestions for misspelled words)
                    if (typeof response[0] === 'string') {
                        console.log(`No exact match found for "${requester.searchTerm}". Suggestions:`, response.join(', '));
                        root.results = response.map(suggestion => ({
                                    type: 'suggestion',
                                    word: suggestion
                                }));
                        return;
                    }

                    // Parse medical dictionary entries with improved definition parsing
                    root.results = response.map(entry => {
                        const word = entry.meta?.id || entry.hwi?.hw || requester.searchTerm;
                        const partOfSpeech = entry.fl || '';

                        // Improved definition parsing
                        let definitions = [];

                        if (entry.def && Array.isArray(entry.def)) {
                            entry.def.forEach(defSection => {
                                if (defSection.sseq && Array.isArray(defSection.sseq)) {
                                    defSection.sseq.forEach(sense => {
                                        if (Array.isArray(sense)) {
                                            sense.forEach(item => {
                                                if (Array.isArray(item) && item[0] === 'sense') {
                                                    const senseData = item[1];
                                                    if (senseData.dt && Array.isArray(senseData.dt)) {
                                                        senseData.dt.forEach(dtItem => {
                                                            if (Array.isArray(dtItem) && dtItem[0] === 'text') {
                                                                let defText = dtItem[1];
                                                                // Clean up the definition text
                                                                defText = defText.replace(/\{[^}]*\}/g, ''); // Remove markup
                                                                defText = defText.replace(/^\s*:\s*/, ''); // Remove leading colon
                                                                defText = defText.trim();
                                                                if (defText) {
                                                                    definitions.push(defText);
                                                                }
                                                            }
                                                        });
                                                    }
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }

                        // Fallback: try to extract from shortdef if no definitions found
                        if (definitions.length === 0 && entry.shortdef && Array.isArray(entry.shortdef)) {
                            definitions = entry.shortdef.filter(def => def && def.trim().length > 0);
                        }

                        // Additional fallback: try alternate parsing structure
                        if (definitions.length === 0 && entry.def && Array.isArray(entry.def)) {
                            entry.def.forEach(defSection => {
                                if (defSection.sseq && Array.isArray(defSection.sseq)) {
                                    const flatSseq = defSection.sseq.flat(3);
                                    flatSseq.forEach(item => {
                                        if (item && item.dt && Array.isArray(item.dt)) {
                                            item.dt.forEach(dtItem => {
                                                if (Array.isArray(dtItem) && dtItem[0] === 'text') {
                                                    let defText = dtItem[1];
                                                    defText = defText.replace(/\{[^}]*\}/g, '');
                                                    defText = defText.replace(/^\s*:\s*/, '');
                                                    defText = defText.trim();
                                                    if (defText) {
                                                        definitions.push(defText);
                                                    }
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }

                        return {
                            type: 'definition',
                            word: word.replace(/\*/g, ''),
                            partOfSpeech: partOfSpeech,
                            definitions: definitions,
                            pronunciation: entry.hwi?.prs?.[0]?.mw || ''
                        };
                    });

                    console.log(`Found ${root.results.length} result(s) for "${requester.searchTerm}"`);

                    // Debug: log parsed results
                    root.results.forEach((result, index) => {
                        console.log(`Result ${index + 1}:`, JSON.stringify(result, null, 2));
                    });
                } else {
                    console.log(`No results found for "${requester.searchTerm}"`);
                    root.results = [];
                }
            } catch (e) {
                console.log("Error parsing response:", e);
                console.log("Raw response:", requester.responseBuffer);
                root.results = [];
            }
        }
    }

    function search(term) {
        if (!term || term.length === 0) {
            console.log("Please provide a search term");
            return;
        }

        requester.makeRequest(term);
    }

    function printResults() {
        if (root.results.length === 0) {
            console.log("No results to display");
            return;
        }

        root.results.forEach((result, index) => {
            if (result.type === 'suggestion') {
                console.log(`Suggestion ${index + 1}: ${result.word}`);
            } else if (result.type === 'definition') {
                console.log(`\n--- ${result.word} ---`);
                if (result.partOfSpeech) {
                    console.log(`Part of speech: ${result.partOfSpeech}`);
                }
                if (result.pronunciation) {
                    console.log(`Pronunciation: ${result.pronunciation}`);
                }
                if (result.definitions.length > 0) {
                    result.definitions.forEach((def, defIndex) => {
                        console.log(`${defIndex + 1}. ${def}`);
                    });
                } else {
                    console.log("No definitions found");
                }
            }
        });
    }
    IpcHandler {
        target: "medical_terminology"
        function set_api_key(key:string) {
            root.setApiKey(key)
        }
    }
}
