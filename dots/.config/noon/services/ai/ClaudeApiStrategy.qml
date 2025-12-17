import QtQuick

ApiStrategy {
    property bool isReasoning: false

    function buildEndpoint(model: AiModel): string {
        console.log("[AI] Claude endpoint:", model.endpoint);
        return model.endpoint;
    }

    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string) {
        let baseData = {
            "model": model.model,
            "system": systemPrompt,
            "messages": messages.map(message => {
                return {
                    "role": message.role === "assistant" ? "assistant" : "user",
                    "content": message.rawContent,
                }
            }),
            "stream": true,
            "max_tokens": 4096,
            "temperature": temperature,
        };

        if (tools && tools.length > 0) {
            baseData.tools = tools;
        }

        console.log("[AI] Claude request data:", JSON.stringify(baseData, null, 2));
        return model.extraParams ? Object.assign({}, baseData, model.extraParams) : baseData;
    }

    function buildAuthorizationHeader(apiKeyEnvVarName: string): string {
        // Claude needs x-api-key header instead of Authorization Bearer
        return `-H "x-api-key: \${${apiKeyEnvVarName}}" -H "anthropic-version: 2023-06-01" -H "content-type: application/json"`;
    }

    function buildScriptFileSetup(filePath: string): string {
        return "";
    }

    function finalizeScriptContent(scriptContent: string): string {
        return scriptContent;
    }

    function parseResponseLine(line, message) {
        console.log("[AI] Claude raw line:", line);

        let cleanData = line.trim();
        if (cleanData.startsWith("event:")) {
            console.log("[AI] Claude event:", cleanData);
            return {};
        }

        if (cleanData.startsWith("data:")) {
            cleanData = cleanData.slice(5).trim();
        }

        if (!cleanData || cleanData.startsWith(":")) return {};

        try {
            const dataJson = JSON.parse(cleanData);
            console.log("[AI] Claude parsed type:", dataJson.type);

            // Handle error responses
            if (dataJson.type === "error") {
                console.error("[AI] Claude error:", JSON.stringify(dataJson.error));
                message.content += `\n\nError: ${dataJson.error.message || JSON.stringify(dataJson.error)}`;
                message.rawContent += `\n\nError: ${dataJson.error.message || JSON.stringify(dataJson.error)}`;
                return { finished: true };
            }

            let newContent = "";

            if (dataJson.type === "content_block_start") {
                if (dataJson.content_block?.type === "thinking") {
                    isReasoning = true;
                    const startBlock = "\n\n<think>\n\n";
                    message.rawContent += startBlock;
                    message.content += startBlock;
                }
                return {};
            }

            if (dataJson.type === "content_block_delta") {
                const delta = dataJson.delta;

                if (delta?.type === "text_delta") {
                    if (isReasoning) {
                        isReasoning = false;
                        const endBlock = "\n\n</think>\n\n";
                        message.content += endBlock;
                        message.rawContent += endBlock;
                    }
                    newContent = delta.text || "";
                } else if (delta?.type === "thinking_delta") {
                    if (!isReasoning) {
                        isReasoning = true;
                        const startBlock = "\n\n<think>\n\n";
                        message.rawContent += startBlock;
                        message.content += startBlock;
                    }
                    newContent = delta.thinking || "";
                }

                message.content += newContent;
                message.rawContent += newContent;
                return {};
            }

            if (dataJson.type === "content_block_stop") {
                if (isReasoning) {
                    isReasoning = false;
                    const endBlock = "\n\n</think>\n\n";
                    message.content += endBlock;
                    message.rawContent += endBlock;
                }
                return {};
            }

            if (dataJson.type === "message_delta") {
                if (dataJson.usage) {
                    return {
                        tokenUsage: {
                            input: dataJson.usage.input_tokens ?? -1,
                            output: dataJson.usage.output_tokens ?? -1,
                            total: (dataJson.usage.input_tokens ?? 0) + (dataJson.usage.output_tokens ?? 0)
                        }
                    };
                }
                if (dataJson.delta?.stop_reason) {
                    return { finished: true };
                }
            }

            if (dataJson.type === "message_stop") {
                return { finished: true };
            }

        } catch (e) {
            console.log("[AI] Claude: Could not parse line:", e);
            message.rawContent += line;
            message.content += line;
        }

        return {};
    }

    function onRequestFinished(message) {
        if (isReasoning) {
            const endBlock = "\n\n</think>\n\n";
            message.content += endBlock;
            message.rawContent += endBlock;
            isReasoning = false;
        }
        return { finished: true };
    }

    function reset() {
        isReasoning = false;
    }
}
