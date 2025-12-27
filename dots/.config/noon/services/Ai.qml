pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.store
import qs.common.utils
import qs.common.functions as CF
import qs.services.ai

/**
 * Basic service to handle LLM chats. Supports Google's and OpenAI's API formats.
 * Supports Gemini and OpenAI models.
 */

Singleton {
    id: root

    signal responseFinished
    Component.onCompleted: setModel(currentModelId, false, false);

    property Component aiMessageComponent: AiMessageData {}
    property Component aiModelComponent: AiModel {}
    property Component geminiApiStrategy: GeminiApiStrategy {}
    property Component openaiApiStrategy: OpenAiApiStrategy {}
    property Component claudeApiStrategy: ClaudeApiStrategy {}
    property Component mistralApiStrategy: MistralApiStrategy {}
    
    readonly property string interfaceRole: "interface"
    readonly property string apiKeyEnvVarName: "API_KEY"

    property string systemPrompt: {
        let prompt = Mem.options.ai?.systemPrompt ?? "";
        for (let key in root.promptSubstitutions) {
            prompt = prompt.split(key).join(root.promptSubstitutions[key]);
        }
        return prompt;
    }
    // property var messages: []
    property var messageIDs: []
    property var messageByID: ({})
    readonly property var apiKeys: KeyringStorage.keyringData?.apiKeys ?? {}
    readonly property var apiKeysLoaded: KeyringStorage.loaded
    property var postResponseHook
    property real temperature: Mem.options.ai?.temperature ?? 0.5
    property QtObject tokenCount: QtObject {
        property int input: -1
        property int output: -1
        property int total: -1
    }
    readonly property bool currentModelHasApiKey: {
        const model = models[currentModelId];
        if (!model || !model.requires_key)
            return true;
        if (!apiKeysLoaded)
            return false;
        const key = apiKeys[model.key_id];
        return (key?.length > 0);
    }
    
    property ApiStrategy currentApiStrategy: apiStrategies[models[currentModelId]?.api_format || "openai"]
    property string requestScriptFilePath: "/tmp/noon/ai/request.sh"
    property string pendingFilePath: ""
    property var models: AiStore.models 
    property var modelList: Object.keys(root.models)
    property var currentModelId: Mem.options.ai?.model || modelList[0]
    property list<var> defaultPrompts: []
    property list<var> userPrompts: []
    property list<var> promptFiles: [...defaultPrompts, ...userPrompts]
    property list<var> savedChats: []
    property var promptSubstitutions: AiStore.promptSubstitutions ?? {}
    property string currentTool: Mem.options.ai.tool ?? "search"
    property var tools: AiStore?.tools ?? {}
    property list<var> availableTools: Object.keys(root.tools[models[currentModelId]?.api_format])
    property var toolDescriptions: {
        "functions": qsTr("Commands, edit configs, search.\nTakes an extra turn to switch to search mode if that's needed"),
        "search": qsTr("Gives the model search capabilities (immediately)"),
        "none": qsTr("Disable tools")
    }
    property var apiStrategies: {
        "openai": openaiApiStrategy.createObject(this),
        "gemini": geminiApiStrategy.createObject(this),
        "mistral": mistralApiStrategy.createObject(this),
        "claude":claudeApiStrategy.createObject(this)
    }

    function guessModelLogo(model) {
        if (model.includes("llama"))
            return "ollama-symbolic";
        if (model.includes("gemma"))
            return "google-gemini-symbolic";
        if (model.includes("deepseek"))
            return "deepseek-symbolic";
        if (/^phi\d*:/i.test(model))
            return "microsoft-symbolic";
        return "ollama-symbolic";
    }

    function guessModelName(model) {
        const replaced = model.replace(/-/g, ' ').replace(/:/g, ' ');
        let words = replaced.split(' ');
        words[words.length - 1] = words[words.length - 1].replace(/(\d+)b$/, (_, num) => `${num}B`);
        words = words.map(word => {
            return (word.charAt(0).toUpperCase() + word.slice(1));
        });
        if (words[words.length - 1] === "Latest")
            words.pop();
        else
            words[words.length - 1] = `(${words[words.length - 1]})`; // Surround the last word with square brackets
        const result = words.join(' ');
        return result;
    }

    function addModel(modelName, data) {
        root.models[modelName] = aiModelComponent.createObject(this, data);
    }

    Process {
        id: getOllamaModels
        running: true
        command: ["bash", "-c", `${Directories.scriptsDir}/ai/show-installed-ollama-models.sh`.replace(/file:\/\//, "")]
        stdout: SplitParser {
            onRead: data => {
                try {
                    if (data.length === 0)
                        return;
                    const dataJson = JSON.parse(data);
                    root.modelList = [...root.modelList, ...dataJson];
                    dataJson.forEach(model => {
                        const safeModelName = root.safeModelName(model);
                        root.addModel(safeModelName, {
                            "name": guessModelName(model),
                            "icon": guessModelLogo(model),
                            "description": qsTr("Local Ollama model | %1").arg(model),
                            "homepage": `https://ollama.com/library/${model}`,
                            "endpoint": "http://localhost:11434/v1/chat/completions",
                            "model": model,
                            "requires_key": false
                        });
                    });

                    root.modelList = Object.keys(root.models);
                } catch (e) {
                    console.log("Could not fetch Ollama models:", e);
                }
            }
        }
    }

    Process {
        id: getDefaultPrompts
        running: true
        command: ["ls", "-1", Directories.defaultAiPrompts]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                root.defaultPrompts = text.split("\n").filter(fileName => fileName.endsWith(".md") || fileName.endsWith(".txt")).map(fileName => `${Directories.defaultAiPrompts}/${fileName}`);
            }
        }
    }

    Process {
        id: getUserPrompts
        running: true
        command: ["ls", "-1", Directories.userAiPrompts]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                root.userPrompts = text.split("\n").filter(fileName => fileName.endsWith(".md") || fileName.endsWith(".txt")).map(fileName => `${Directories.userAiPrompts}/${fileName}`);
            }
        }
    }

    Process {
        id: getSavedChats
        running: true
        command: ["ls", "-1", Directories.aiChats]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                root.savedChats = text.split("\n").filter(fileName => fileName.endsWith(".json")).map(fileName => `${Directories.aiChats}/${fileName}`);
            }
        }
    }

    FileView {
        id: promptLoader
        watchChanges: false
        onLoadedChanged: {
            if (!promptLoader.loaded)
                return;
            Mem.options.ai.systemPrompt = promptLoader.text();
            root.addMessage(qsTr("Loaded the following system prompt\n\n---\n\n%1").arg(Mem.options.ai.systemPrompt), root.interfaceRole);
        }
    }

    function printPrompt() {
        root.addMessage(qsTr("The current system prompt is\n\n---\n\n%1").arg(Mem.options.ai.systemPrompt), root.interfaceRole);
    }

    function loadPrompt(filePath) {
        promptLoader.path = ""; // Unload
        promptLoader.path = filePath; // Load
        promptLoader.reload();
    }

    function addMessage(message, role) {
        if (message.length === 0)
            return;
        const aiMessage = aiMessageComponent.createObject(root, {
            "role": role,
            "content": message,
            "rawContent": message,
            "thinking": false,
            "done": true
        });
        const id = idForMessage(aiMessage);
        root.messageIDs = [...root.messageIDs, id];
        root.messageByID[id] = aiMessage;
    }

    function removeMessage(index) {
        if (index < 0 || index >= messageIDs.length)
            return;
        const id = root.messageIDs[index];
        root.messageIDs.splice(index, 1);
        root.messageIDs = [...root.messageIDs];
        delete root.messageByID[id];
    }

    function addApiKeyAdvice(model) {
        root.addMessage(qsTr('To set an API key, pass it with the %4 command\n\nTo view the key, pass "get" with the command<br/>\n\n### For %1:\n\n**Link**: %2\n\n%3').arg(model.name).arg(model.key_get_link).arg(model.key_get_description ?? qsTr("<i>No further instruction provided</i>")).arg("/key"), Ai.interfaceRole);
    }

    function getModel() {
        return models[currentModelId];
    }

    function setModel(modelId, feedback = true, setConfigState = true) {
        if (!modelId)
            modelId = "";
        modelId = modelId.toLowerCase();
        if (modelList.indexOf(modelId) !== -1) {
            const model = models[modelId];
            // Fetch API keys if needed
            if (model?.requires_key)
                KeyringStorage.reload();
            // See if policy prevents online models
            if (Mem.options.policies.ai === 2 && !model.endpoint.includes("localhost")) {
                root.addMessage(qsTr("Online models disallowed\n\nControlled by `policies.ai` config option"), root.interfaceRole);
                return;
            }
            if (setConfigState)
                Mem.options.ai.model = modelId;
            if (feedback)
                root.addMessage(qsTr("Model set to %1").arg(model.name), root.interfaceRole);
            if (model.requires_key) {
                // If key not there show advice
                if (root.apiKeysLoaded && (!root.apiKeys[model.key_id] || root.apiKeys[model.key_id].length === 0)) {
                    root.addApiKeyAdvice(model);
                }
            }
        } else {
            if (feedback)
                root.addMessage(qsTr("Invalid model. Supported: \n```\n") + modelList.join("\n```\n```\n"), Ai.interfaceRole) + "\n```";
        }
    }

    function setTool(tool) {
        if (!root.tools[models[currentModelId]?.api_format] || !(tool in root.tools[models[currentModelId]?.api_format])) {
            root.addMessage(qsTr("Invalid tool. Supported tools:\n- %1").arg(root.availableTools.join("\n- ")), root.interfaceRole);
            return false;
        }
        Mem.options.ai.tool = tool;
        return true;
    }

    function getTemperature() {
        return root.temperature;
    }

    function setTemperature(value) {
        if (value == NaN || value < 0 || value > 2) {
            root.addMessage(qsTr("Temperature must be between 0 and 2"), Ai.interfaceRole);
            return;
        }
        Mem.options.ai.temperature = value;
        root.temperature = value;
        root.addMessage(qsTr("Temperature set to %1").arg(value), Ai.interfaceRole);
    }

    function setApiKey(key) {
        const model = models[currentModelId];
        if (!model.requires_key) {
            root.addMessage(qsTr("%1 does not require an API key").arg(model.name), Ai.interfaceRole);
            return;
        }
        if (!key || key.length === 0) {
            const model = models[currentModelId];
            root.addApiKeyAdvice(model);
            return;
        }
        KeyringStorage.setNestedField(["apiKeys", model.key_id], key.trim());
        root.addMessage(qsTr("API key set for %1").arg(model.name), Ai.interfaceRole);
    }

    function printApiKey() {
        const model = models[currentModelId];
        if (model.requires_key) {
            const key = root.apiKeys[model.key_id];
            if (key) {
                root.addMessage(qsTr("API key:\n\n```txt\n%1\n```").arg(key), Ai.interfaceRole);
            } else {
                root.addMessage(qsTr("No API key set for %1").arg(model.name), Ai.interfaceRole);
            }
        } else {
            root.addMessage(qsTr("%1 does not require an API key").arg(model.name), Ai.interfaceRole);
        }
    }

    function printTemperature() {
        root.addMessage(qsTr("Temperature: %1").arg(root.temperature), Ai.interfaceRole);
    }

    function clearMessages() {
        root.messageIDs = [];
        root.messageByID = ({});
        root.tokenCount.input = -1;
        root.tokenCount.output = -1;
        root.tokenCount.total = -1;
    }

    FileView {
        id: requesterScriptFile
    }

    Process {
        id: requester
        property list<string> baseCommand: ["bash"]
        property AiMessageData message
        property ApiStrategy currentStrategy

        function markDone() {
            requester.message.done = true;
            if (root.postResponseHook) {
                root.postResponseHook();
                root.postResponseHook = null; // Reset hook after use
            }
            root.saveChat("lastSession");
            root.responseFinished();
        }

        function makeRequest() {
            const model = models[currentModelId];
            requester.currentStrategy = root.currentApiStrategy;
            requester.currentStrategy.reset(); // Reset strategy state

            /* Put API key in environment variable */
            if (model.requires_key)
                requester.environment[`${root.apiKeyEnvVarName}`] = root.apiKeys ? (root.apiKeys[model.key_id] ?? "") : "";

            /* Build endpoint, request data */
            const endpoint = root.currentApiStrategy.buildEndpoint(model);
            const messageArray = root.messageIDs.map(id => root.messageByID[id]);
            const filteredMessageArray = messageArray.filter(message => message.role !== Ai.interfaceRole);
            const data = root.currentApiStrategy.buildRequestData(model, filteredMessageArray, root.systemPrompt, root.temperature, root.tools[model.api_format][root.currentTool], root.pendingFilePath);
            // console.log("[Ai] Request data: ", JSON.stringify(data, null, 2));

            let requestHeaders = {
                "Content-Type": "application/json"
            };

            /* Create local message object */
            requester.message = root.aiMessageComponent.createObject(root, {
                "role": "assistant",
                "model": currentModelId,
                "content": "",
                "rawContent": "",
                "thinking": true,
                "done": false
            });
            const id = idForMessage(requester.message);
            root.messageIDs = [...root.messageIDs, id];
            root.messageByID[id] = requester.message;

            /* Build header string for curl */
            let headerString = Object.entries(requestHeaders).filter(([k, v]) => v && v.length > 0).map(([k, v]) => `-H '${k}: ${v}'`).join(' ');

            /* Get authorization header from strategy */
            const authHeader = requester.currentStrategy.buildAuthorizationHeader(root.apiKeyEnvVarName);

            /* Script shebang */
            const scriptShebang = "#!/usr/bin/env bash\n";

            /* Create extra setup when there's an attached file */
            let scriptFileSetupContent = "";
            if (root.pendingFilePath && root.pendingFilePath.length > 0) {
                requester.message.localFilePath = root.pendingFilePath;
                scriptFileSetupContent = requester.currentStrategy.buildScriptFileSetup(root.pendingFilePath);
                root.pendingFilePath = "";
            }

            /* Create command string */
            let scriptRequestContent = "";
            scriptRequestContent += `curl --no-buffer "${endpoint}"` + ` ${headerString}` + (authHeader ? ` ${authHeader}` : "") + ` --data '${CF.StringUtils.shellSingleQuoteEscape(JSON.stringify(data))}'` + "\n";

            /* Send the request */
            const scriptContent = requester.currentStrategy.finalizeScriptContent(scriptShebang + scriptFileSetupContent + scriptRequestContent);
            const shellScriptPath = CF.FileUtils.trimFileProtocol(root.requestScriptFilePath);
            requesterScriptFile.path = Qt.resolvedUrl(shellScriptPath);
            requesterScriptFile.setText(scriptContent);
            requester.command = baseCommand.concat([shellScriptPath]);
            requester.running = true;
        }

        stdout: SplitParser {
            onRead: data => {
                if (data.length === 0)
                    return;
                if (requester.message.thinking)
                    requester.message.thinking = false;
       
                // Handle response line
                try {
                    const result = requester.currentStrategy.parseResponseLine(data, requester.message);
       
                    if (result.functionCall) {
                        requester.message.functionCall = result.functionCall;
                        root.handleFunctionCall(result.functionCall.name, result.functionCall.args, requester.message);
                    }
                    if (result.tokenUsage) {
                        root.tokenCount.input = result.tokenUsage.input;
                        root.tokenCount.output = result.tokenUsage.output;
                        root.tokenCount.total = result.tokenUsage.total;
                    }
                    if (result.finished) {
                        requester.markDone();
                    }
                } catch (e) {
                    console.log("[AI] Could not parse response: ", e);
                    requester.message.rawContent += data;
                    requester.message.content += data;
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            const result = requester.currentStrategy.onRequestFinished(requester.message);

            if (result.finished) {
                requester.markDone();
            } else if (!requester.message.done) {
                requester.markDone();
            }

            // Handle error responses
            if (requester.message.content.includes("API key not valid")) {
                root.addApiKeyAdvice(models[requester.message.model]);
            }
        }
    }

    function sendUserMessage(message) {
        if (message.length === 0)
            return;
        root.addMessage(message, "user");
        requester.makeRequest();
    }

    function attachFile(filePath: string) {
        root.pendingFilePath = CF.FileUtils.trimFileProtocol(filePath);
    }

    function regenerate(messageIndex) {
        if (messageIndex < 0 || messageIndex >= messageIDs.length) return;
        const id = root.messageIDs[messageIndex];
        const message = root.messageByID[id];
        if (message.role !== "assistant") return;
        for (let i = root.messageIDs.length - 1; i >= messageIndex; i--) {
            root.removeMessage(i);
        }
        requester.makeRequest();
    }

    function createFunctionOutputMessage(name, output, includeOutputInChat = true) {
        return aiMessageComponent.createObject(root, {
            "role": "user",
            "content": `[[ Output of ${name} ]]${includeOutputInChat ? ("\n\n<think>\n" + output + "\n</think>") : ""}`,
            "rawContent": `[[ Output of ${name} ]]${includeOutputInChat ? ("\n\n<think>\n" + output + "\n</think>") : ""}`,
            "functionName": name,
            "functionResponse": output,
            "thinking": false,
            "done": true,
            "visibleToUser": false
        });
    }

    function addFunctionOutputMessage(name, output) {
        const aiMessage = createFunctionOutputMessage(name, output);
        const id = idForMessage(aiMessage);
        root.messageIDs = [...root.messageIDs, id];
        root.messageByID[id] = aiMessage;
    }

    function rejectCommand(message: AiMessageData) {
        if (!message.functionPending)
            return;
        message.functionPending = false; // User decided, no more "thinking"
        addFunctionOutputMessage(message.functionName, qsTr("Command rejected by user"));
    }

    function approveCommand(message: AiMessageData) {
        if (!message.functionPending)
            return;
        message.functionPending = false; // User decided, no more "thinking"

        const responseMessage = createFunctionOutputMessage(message.functionName, "", false);
        const id = idForMessage(responseMessage);
        root.messageIDs = [...root.messageIDs, id];
        root.messageByID[id] = responseMessage;

        commandExecutionProc.message = responseMessage;
        commandExecutionProc.baseMessageContent = responseMessage.content;
        commandExecutionProc.shellCommand = message.functionCall.args.command;
        commandExecutionProc.running = true; // Start the command execution
    }

    Process {
        id: commandExecutionProc
        property string shellCommand: ""
        property AiMessageData message
        property string baseMessageContent: ""
        command: ["bash", "-c", shellCommand]
        stdout: SplitParser {
            onRead: output => {
                commandExecutionProc.message.functionResponse += output + "\n\n";
                const updatedContent = commandExecutionProc.baseMessageContent + `\n\n<think>\n<tt>${commandExecutionProc.message.functionResponse}</tt>\n</think>`;
                commandExecutionProc.message.rawContent = updatedContent;
                commandExecutionProc.message.content = updatedContent;
            }
        }
        onExited: (exitCode, exitStatus) => {
            commandExecutionProc.message.functionResponse += `[[ Command exited with code ${exitCode} (${exitStatus}) ]]\n`;
            requester.makeRequest(); // Continue
        }
    }
    
    function handleFunctionCall(name, args, message) {
        const executor = AiStore.executors[name];
        if (executor) {
            try {
                executor(args, message);
            } catch (e) {
                console.log(`Error executing function ${name}:`, e);
                root.addMessage(qsTr("Error executing function: %1").arg(name), "assistant");
            }
        } else {
            root.addMessage(qsTr("Unknown function call: %1").arg(name), "assistant");
        }
    }

    
    function chatToJson() {
        return root.messageIDs.map(id => {
            const message = root.messageByID[id];
            return ({
                    "role": message.role,
                    "rawContent": message.rawContent,
                    "fileMimeType": message.fileMimeType,
                    "fileUri": message.fileUri,
                    "localFilePath": message.localFilePath,
                    "model": message.model,
                    "thinking": false,
                    "done": true,
                    "annotations": message.annotations,
                    "annotationSources": message.annotationSources,
                    "functionName": message.functionName,
                    "functionCall": message.functionCall,
                    "functionResponse": message.functionResponse,
                    "visibleToUser": message.visibleToUser
                });
        });
    }

    FileView {
        id: chatSaveFile
        property string chatName: ""
        path: chatName.length > 0 ? `${Directories.aiChats}/${chatName}.json` : ""
        blockLoading: true // Prevent race conditions
    }
    
    function idForMessage(message) {
        return Date.now().toString(36) + Math.random().toString(36).substr(2, 8);
    }

    function safeModelName(modelName) {
        return modelName.replace(/:/g, "_").replace(/ /g, "-").replace(/\//g, "-");
    }

    function saveChat(chatName) {
        chatSaveFile.chatName = chatName.trim();
        const saveContent = JSON.stringify(root.chatToJson());
        chatSaveFile.setText(saveContent);
        getSavedChats.running = true;
    }

    function loadChat(chatName) {
        try {
            chatSaveFile.chatName = chatName.trim();
            chatSaveFile.reload();
            const saveContent = chatSaveFile.text();
            const saveData = JSON.parse(saveContent);
            root.clearMessages();
            root.messageIDs = saveData.map((_, i) => {
                return i;
            });
            for (let i = 0; i < saveData.length; i++) {
                const message = saveData[i];
                root.messageByID[i] = root.aiMessageComponent.createObject(root, {
                    "role": message.role,
                    "rawContent": message.rawContent,
                    "content": message.rawContent,
                    "fileMimeType": message.fileMimeType,
                    "fileUri": message.fileUri,
                    "localFilePath": message.localFilePath,
                    "model": message.model,
                    "thinking": message.thinking,
                    "done": message.done,
                    "annotations": message.annotations,
                    "annotationSources": message.annotationSources,
                    "functionName": message.functionName,
                    "functionCall": message.functionCall,
                    "functionResponse": message.functionResponse,
                    "visibleToUser": message.visibleToUser
                });
            }
        } catch (e) {
            console.log("[AI] Could not load chat: ", e);
        } finally {
            getSavedChats.running = true;
        }
    }

}
