import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.common
pragma Singleton
pragma ComponentBehavior: Bound
import qs.services


Singleton {
    id: root
    property Component aiModelComponent: Ai.aiModelComponent
    property Component aiMessageComponent: Ai.aiMessageComponent
    property var promptSubstitutions: {
        "{DISTRO}": SystemInfo.distroName,
        "{DATETIME}": `${DateTimeService.time}, ${DateTimeService.collapsedCalendarFormat}`,
        "{WINDOWCLASS}": `${ToplevelManager.activeToplevel?.appId} ${ToplevelManager.activeToplevel?.title}` ?? "Unknown",
        "{DE}": `${SystemInfo.desktopEnvironment} (${SystemInfo.windowingSystem})`,
        "{TASKS}": TodoService.formatTasks(),
        "{TIMERS}": TimerService.formatTimers(),
        "{USER}": SystemInfo.username,
        "{LOCATION}": Mem.options.services.location,
        "{NOTES}": NotesService.content,
        "{PLAYING}": `title:${BeatsService.cleanedTitle}  artist:${BeatsService.artist}`,
        "{WEATHER}": WeatherService.weatherData.currentTemp,
        "{ALARMS}": AlarmService.alarms
    }
    property var tools: {
        "gemini": {
            "functions": [
                {
                    "functionDeclarations": [
                        {
                            "name": "get_timers",
                            "description": "Get all current timers with their status, duration, and remaining time"
                        },
                        {
                            "name": "add_timer",
                            "description": "Create a new timer with a name and duration",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "name": {
                                        "type": "string",
                                        "description": "Name/description of the timer"
                                    },
                                    "duration": {
                                        "type": "string",
                                        "description": "Duration in format like '25m', '1h30m', '45s', or just '25' for minutes"
                                    }
                                },
                                "required": ["name", "duration"]
                            }
                        },
                        {
                            "name": "start_timer",
                            "description": "Start or resume a timer by its ID",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "timer_id": {
                                        "type": "integer",
                                        "description": "The timer ID from get_timers"
                                    }
                                },
                                "required": ["timer_id"]
                            }
                        },
                        {
                            "name": "pause_timer",
                            "description": "Pause a running timer by its ID",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "timer_id": {
                                        "type": "integer",
                                        "description": "The timer ID from get_timers"
                                    }
                                },
                                "required": ["timer_id"]
                            }
                        },
                        {
                            "name": "reset_timer",
                            "description": "Reset a timer back to its original duration",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "timer_id": {
                                        "type": "integer",
                                        "description": "The timer ID from get_timers"
                                    }
                                },
                                "required": ["timer_id"]
                            }
                        },
                        {
                            "name": "delete_timer",
                            "description": "Remove/delete a timer completely",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "timer_id": {
                                        "type": "integer",
                                        "description": "The timer ID from get_timers"
                                    }
                                },
                                "required": ["timer_id"]
                            }
                        },
                        {
                            "name": "get_tasks",
                            "description": "Get the current to-do list with all tasks and their statuses. Use this to check tasks before modifying them."
                        },
                        {
                            "name": "add_task",
                            "description": "Add a new task to the to-do list",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "content": {
                                        "type": "string",
                                        "description": "The task description"
                                    }
                                },
                                "required": ["content"]
                            }
                        },
                        {
                            "name": "update_task_status",
                            "description": "Update the status of a task. Status values: 0=Not Started, 1=In Progress, 2=Final Touches, 3=Finished",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "index": {
                                        "type": "integer",
                                        "description": "The task index from get_tasks (0-based)"
                                    },
                                    "status": {
                                        "type": "integer",
                                        "description": "New status: 0=todo, 1=in_progress, 2=final_touches, 3=done"
                                    }
                                },
                                "required": ["index", "status"]
                            }
                        },
                        {
                            "name": "delete_task",
                            "description": "Delete a task from the to-do list",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "index": {
                                        "type": "integer",
                                        "description": "The task index from get_tasks (0-based)"
                                    }
                                },
                                "required": ["index"]
                            }
                        },
                        {
                            "name": "search_online_inbrowser",
                            "description": "Open Browser and search for a user request. The query should be valid https url will be used to search.",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "query": {
                                        "type": "string",
                                        "description": "Valid HTTPS URL"
                                    }
                                },
                                "required": ["query"]
                            }
                        },
                        {
                            "name": "edit_task",
                            "description": "Edit the content of a task",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "index": {
                                        "type": "integer",
                                        "description": "The task index from get_tasks (0-based)"
                                    },
                                    "content": {
                                        "type": "string",
                                        "description": "The new task content"
                                    }
                                },
                                "required": ["index", "content"]
                            }
                        },
                        {
                            "name": "switch_to_search_mode",
                            "description": "Search the web"
                        },
                        {
                            "name": "get_shell_config",
                            "description": "Get the desktop shell config file contents"
                        },
                        {
                            "name": "set_shell_config",
                            "description": "Set a field in the desktop graphical shell config file. Must only be used after `get_shell_config`.",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "key": {
                                        "type": "string",
                                        "description": "The key to set, e.g. `bar.borderless`. MUST NOT BE GUESSED, use `get_shell_config` to see what keys are available before setting."
                                    },
                                    "value": {
                                        "type": "string",
                                        "description": "The value to set, e.g. `true`"
                                    }
                                },
                                "required": ["key", "value"]
                            }
                        },
                        {
                            "name": "run_shell_command",
                            "description": "Run a shell command in bash and get its output. Use this only for quick commands that don't require user interaction. For commands that require interaction, ask the user to run manually instead.",
                            "parameters": {
                                "type": "object",
                                "properties": {
                                    "command": {
                                        "type": "string",
                                        "description": "The bash command to run"
                                    }
                                },
                                "required": ["command"]
                            }
                        },
                    ]
                }
            ],
            "search": [
                {
                    "google_search": {}
                }
            ],
            "none": []
        },
        "openai": {
            "functions": [
                {
                    "type": "function",
                    "function": {
                        "name": "search_online_inbrowser",
                        "description": "Open Browser and search for a user request. The query should be valid https url will be used to search.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "query": {
                                    "type": "string",
                                    "description": "Valid HTTP URL"
                                }
                            },
                            "required": ["query"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "get_timers",
                        "description": "Get all current timers with their status, duration, and remaining time",
                        "parameters": {
                            "type": "object",
                            "properties": {}
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "add_timer",
                        "description": "Create a new timer with a name and duration",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "name": {
                                    "type": "string",
                                    "description": "Name/description of the timer"
                                },
                                "duration": {
                                    "type": "string",
                                    "description": "Duration in format like '25m', '1h30m', '45s', or just '25' for minutes"
                                }
                            },
                            "required": ["name", "duration"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "start_timer",
                        "description": "Start or resume a timer by its ID",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "timer_id": {
                                    "type": "integer",
                                    "description": "The timer ID from get_timers"
                                }
                            },
                            "required": ["timer_id"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "pause_timer",
                        "description": "Pause a running timer by its ID",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "timer_id": {
                                    "type": "integer",
                                    "description": "The timer ID from get_timers"
                                }
                            },
                            "required": ["timer_id"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "reset_timer",
                        "description": "Reset a timer back to its original duration",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "timer_id": {
                                    "type": "integer",
                                    "description": "The timer ID from get_timers"
                                }
                            },
                            "required": ["timer_id"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "delete_timer",
                        "description": "Remove/delete a timer completely",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "timer_id": {
                                    "type": "integer",
                                    "description": "The timer ID from get_timers"
                                }
                            },
                            "required": ["timer_id"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "get_tasks",
                        "description": "Get the current to-do list with all tasks and their statuses. Use this to check tasks before modifying them.",
                        "parameters": {
                            "type": "object",
                            "properties": {}
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "add_task",
                        "description": "Add a new task to the to-do list",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "content": {
                                    "type": "string",
                                    "description": "The task description"
                                }
                            },
                            "required": ["content"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "update_task_status",
                        "description": "Update the status of a task. Status values: 0=Not Started, 1=In Progress, 2=Final Touches, 3=Finished",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "index": {
                                    "type": "integer",
                                    "description": "The task index from get_tasks (0-based)"
                                },
                                "status": {
                                    "type": "integer",
                                    "description": "New status: 0=todo, 1=in_progress, 2=final_touches, 3=done"
                                }
                            },
                            "required": ["index", "status"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "delete_task",
                        "description": "Delete a task from the to-do list",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "index": {
                                    "type": "integer",
                                    "description": "The task index from get_tasks (0-based)"
                                }
                            },
                            "required": ["index"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "edit_task",
                        "description": "Edit the content of a task",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "index": {
                                    "type": "integer",
                                    "description": "The task index from get_tasks (0-based)"
                                },
                                "content": {
                                    "type": "string",
                                    "description": "The new task content"
                                }
                            },
                            "required": ["index", "content"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "get_shell_config",
                        "description": "Get the desktop shell config file contents",
                        "parameters": {
                            "type": "object",
                            "properties": {}
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "set_shell_config",
                        "description": "Set a field in the desktop graphical shell config file. Must only be used after `get_shell_config`.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "key": {
                                    "type": "string",
                                    "description": "The key to set, e.g. `bar.borderless`. MUST NOT BE GUESSED, use `get_shell_config` to see what keys are available before setting."
                                },
                                "value": {
                                    "type": "string",
                                    "description": "The value to set, e.g. `true`"
                                }
                            },
                            "required": ["key", "value"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "run_shell_command",
                        "description": "Run a shell command in bash and get its output. Use this only for quick commands that don't require user interaction. For commands that require interaction, ask the user to run manually instead.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "command": {
                                    "type": "string",
                                    "description": "The bash command to run"
                                }
                            },
                            "required": ["command"]
                        }
                    }
                }
            ],
            "search": [],
            "none": []
        },
        "mistral": {
            "functions": [
                {
                    "type": "function",
                    "function": {
                        "name": "get_shell_config",
                        "description": "Get the desktop shell config file contents",
                        "parameters": {}
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "set_shell_config",
                        "description": "Set a field in the desktop graphical shell config file. Must only be used after `get_shell_config`.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "key": {
                                    "type": "string",
                                    "description": "The key to set, e.g. `bar.borderless`. MUST NOT BE GUESSED, use `get_shell_config` to see what keys are available before setting."
                                },
                                "value": {
                                    "type": "string",
                                    "description": "The value to set, e.g. `true`"
                                }
                            },
                            "required": ["key", "value"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "run_shell_command",
                        "description": "Run a shell command in bash and get its output. Use this only for quick commands that don't require user interaction. For commands that require interaction, ask the user to run manually instead.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "command": {
                                    "type": "string",
                                    "description": "The bash command to run"
                                }
                            },
                            "required": ["command"]
                        }
                    }
                },
            ],
            "search": [],
            "none": []
        }
    }

    property var models: Mem.options.policies.ai === 2 ? {
    } : {
        "gemini-2.5-flash": aiModelComponent.createObject(this, {
            "name": "Gemini 2.5 Flash",
            "icon": "google-gemini-symbolic",
            "description": qsTr("Online | Google's model\nNewer model that's slower than its predecessor but should deliver higher quality answers"),
            "homepage": "https://aistudio.google.com",
            "endpoint": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent",
            "model": "gemini-2.5-flash",
            "requires_key": true,
            "key_id": "gemini",
            "key_get_link": "https://aistudio.google.com/app/apikey",
            "key_get_description": qsTr("**Pricing**: free. Data used for training.\n\n**Instructions**: Log into Google account, allow AI Studio to create Google Cloud project or whatever it asks, go back and click Get API key"),
            "api_format": "gemini"
        }),
        "mistral-medium-3": aiModelComponent.createObject(this, {
            "name": "Mistral Medium 3",
            "icon": "mistral-symbolic",
            "description": qsTr("Online | %1's model | Delivers fast, responsive and well-formatted answers. Disadvantages: not very eager to do stuff; might make up unknown function calls").arg("Mistral"),
            "homepage": "https://mistral.ai/news/mistral-medium-3",
            "endpoint": "https://api.mistral.ai/v1/chat/completions",
            "model": "mistral-medium-2505",
            "requires_key": true,
            "key_id": "mistral",
            "key_get_link": "https://console.mistral.ai/api-keys",
            "key_get_description": qsTr("**Instructions**: Log into Mistral account, go to Keys on the sidebar, click Create new key"),
            "api_format": "mistral"
        }),
        "perplexity-sonar-deep-research": aiModelComponent.createObject(this, {
            "name": "Sonar Deep Research",
            "icon": "perplexity-symbolic",
            "description": qsTr("Online | Perplexity's model\nIn-depth analysis and comprehensive reports with exhaustive web research"),
            "homepage": "https://www.perplexity.ai",
            "endpoint": "https://api.perplexity.ai/chat/completions",
            "model": "sonar-deep-research",
            "requires_key": true,
            "key_id": "perplexity",
            "key_get_link": "https://www.perplexity.ai/settings/api",
            "key_get_description": qsTr("**Pricing**: Pay-as-you-go. Pro users get $5/month credit.\n\n**Instructions**: Log into Perplexity account, go to Settings > API, click Generate API Key"),
            "api_format": "openai"
        }),
        "perplexity-sonar-pro": aiModelComponent.createObject(this, {
            "name": "Sonar Pro",
            "icon": "perplexity-symbolic",
            "description": qsTr("Online | Perplexity's model\nAdvanced search with enhanced accuracy and detail"),
            "homepage": "https://www.perplexity.ai",
            "endpoint": "https://api.perplexity.ai/chat/completions",
            "model": "sonar-pro",
            "requires_key": true,
            "key_id": "perplexity",
            "key_get_link": "https://www.perplexity.ai/settings/api",
            "key_get_description": qsTr("**Pricing**: Pay-as-you-go. Pro users get $5/month credit.\n\n**Instructions**: Log into Perplexity account, go to Settings > API, click Generate API Key"),
            "api_format": "openai"
        }),
        "openai-gpt-4o-mini": aiModelComponent.createObject(this, {
            "name": "GPT-4o Mini",
            "icon": "openai-symbolic",
            "description": qsTr("Online | OpenAI's model\nFast and cost-efficient for everyday tasks and quick responses."),
            "homepage": "https://openai.com",
            "endpoint": "https://api.openai.com/v1/chat/completions",
            "model": "gpt-4o-mini",
            "requires_key": true,
            "key_id": "openai",
            "key_get_link": "https://platform.openai.com/api-keys",
            "key_get_description": qsTr("**Pricing**: Pay-as-you-go. See https://openai.com/pricing\n\n**Instructions**: Log into OpenAI account, go to API keys, click Create new secret key"),
            "api_format": "openai"
        }),
        "openai-gpt-5": aiModelComponent.createObject(this, {
            "name": "GPT-5",
            "icon": "openai-symbolic",
            "description": qsTr("Online | OpenAI's model\nState-of-the-art for complex reasoning, coding, and multimodal tasks."),
            "homepage": "https://openai.com",
            "endpoint": "https://api.openai.com/v1/chat/completions",
            "model": "gpt-5",
            "requires_key": true,
            "key_id": "openai",
            "key_get_link": "https://platform.openai.com/api-keys",
            "key_get_description": qsTr("**Pricing**: Pay-as-you-go. See https://openai.com/pricing\n\n**Instructions**: Log into OpenAI account, go to API keys, click Create new secret key"),
            "api_format": "openai"
        })
    }
    property var executors: {
        "switch_to_search_mode": function(args, message) {
            root.currentTool = "search";
            root.postResponseHook = () => { root.currentTool = "functions"; };
            root.addFunctionOutputMessage("switch_to_search_mode", qsTr("Switched to search mode. Continue with the user's request."));
            root.requester.makeRequest();
        },
        "get_shell_config": function(args, message) {
            const configJson = Utils.ObjectUtils.toPlainObject(Mem.options);
            root.addFunctionOutputMessage("get_shell_config", JSON.stringify(configJson));
            root.requester.makeRequest();
        },
        "set_shell_config": function(args, message) {
            if (!args.key || !args.value) {
                root.addFunctionOutputMessage("set_shell_config", qsTr("Invalid arguments. Must provide `key` and `value`."));
                return;
            }
            Mem.options.setNestedValue(args.key, args.value);
        },
        "run_shell_command": function(args, message) {
            if (!args.command || args.command.length === 0) {
                root.addFunctionOutputMessage("run_shell_command", qsTr("Invalid arguments. Must provide `command`."));
                return;
            }
            const contentToAppend = `\n\n**Command execution request**\n\n\`\`\`command\n${args.command}\n\`\`\``;
            message.rawContent += contentToAppend;
            message.content += contentToAppend;
            message.functionPending = true;
        },
        "get_tasks": function(args, message) {
            root.addFunctionOutputMessage("get_tasks", TodoService.formatTasks());
            root.requester.makeRequest();
        },
        "add_task": function(args, message) {
            if (!args.content || args.content.trim().length === 0) {
                root.addFunctionOutputMessage("add_task", qsTr("Invalid arguments. Must provide non-empty `content`."));
                return;
            }
            TodoService.addTask(args.content.trim());
            root.addFunctionOutputMessage("add_task", qsTr("Task added: %1").arg(args.content));
            root.requester.makeRequest();
        },
        "update_task_status": function(args, message) {
            if (args.index === undefined || args.status === undefined) {
                root.addFunctionOutputMessage("update_task_status", qsTr("Invalid arguments. Must provide `index` and `status`."));
                return;
            }
            if (args.index < 0 || args.index >= TodoService.list.length) {
                root.addFunctionOutputMessage("update_task_status", qsTr("Invalid task index: %1. Valid range: 0-%2").arg(args.index).arg(TodoService.list.length - 1));
                return;
            }
            if (args.status < TodoService.status_todo || args.status > TodoService.status_done) {
                root.addFunctionOutputMessage("update_task_status", qsTr("Invalid status: %1. Valid range: 0-3").arg(args.status));
                return;
            }
            TodoService.setStatus(args.index, args.status);
            root.addFunctionOutputMessage("update_task_status", qsTr("Task %1 status updated to %2").arg(args.index).arg(TodoService.getStatusName(args.status)));
            root.requester.makeRequest();
        },
        "delete_task": function(args, message) {
            if (args.index === undefined) {
                root.addFunctionOutputMessage("delete_task", qsTr("Invalid arguments. Must provide `index`."));
                return;
            }
            if (args.index < 0 || args.index >= TodoService.list.length) {
                root.addFunctionOutputMessage("delete_task", qsTr("Invalid task index: %1. Valid range: 0-%2").arg(args.index).arg(TodoService.list.length - 1));
                return;
            }
            const taskContent = TodoService.getItemContent(args.index);
            TodoService.deleteItem(args.index);
            root.addFunctionOutputMessage("delete_task", qsTr("Task deleted: %1").arg(taskContent));
            root.requester.makeRequest();
        },
        "edit_task": function(args, message) {
            if (args.index === undefined || !args.content) {
                root.addFunctionOutputMessage("edit_task", qsTr("Invalid arguments. Must provide `index` and `content`."));
                return;
            }
            if (args.index < 0 || args.index >= TodoService.list.length) {
                root.addFunctionOutputMessage("edit_task", qsTr("Invalid task index: %1. Valid range: 0-%2").arg(args.index).arg(TodoService.list.length - 1));
                return;
            }
            const success = TodoService.editItem(args.index, args.content);
            const output = success 
                ? qsTr("Task %1 updated to: %2").arg(args.index).arg(args.content)
                : qsTr("Failed to update task %1").arg(args.index);
            root.addFunctionOutputMessage("edit_task", output);
            root.requester.makeRequest();
        },
        "get_timers": function(args, message) {
            root.addFunctionOutputMessage("get_timers", TimerService.formatTimers());
            root.requester.makeRequest();
        },
        "add_timer": function(args, message) {
            if (!args.name || !args.duration) {
                root.addFunctionOutputMessage("add_timer", qsTr("Invalid arguments. Must provide 'name' and 'duration'."));
                return;
            }
            const durationSeconds = TimerService.parseTimeString(args.duration);
            if (durationSeconds <= 0) {
                root.addFunctionOutputMessage("add_timer", qsTr("Invalid duration format. Use formats like '25m', '1h30m', or '45'."));
                return;
            }
            const timerId = TimerService.addTimer(args.name, durationSeconds, null);
            root.addFunctionOutputMessage("add_timer", qsTr("Timer created with ID %1: %2 (%3)").arg(timerId).arg(args.name).arg(TimerService.formatTime(durationSeconds)));
            root.requester.makeRequest();
        },
        "start_timer": function(args, message) {
            if (args.timer_id === undefined) {
                root.addFunctionOutputMessage("start_timer", qsTr("Invalid arguments. Must provide 'timer_id'."));
                return;
            }
            const timer = TimerService.uiTimers.find(t => t.id === args.timer_id);
            if (!timer) {
                root.addFunctionOutputMessage("start_timer", qsTr("Timer with ID %1 not found").arg(args.timer_id));
                return;
            }
            TimerService.startTimer(args.timer_id);
            root.addFunctionOutputMessage("start_timer", qsTr("Timer %1 started: %2").arg(args.timer_id).arg(timer.name));
            root.requester.makeRequest();
        },
        "pause_timer": function(args, message) {
            if (args.timer_id === undefined) {
                root.addFunctionOutputMessage("pause_timer", qsTr("Invalid arguments. Must provide 'timer_id'."));
                return;
            }
            const timer = TimerService.uiTimers.find(t => t.id === args.timer_id);
            if (!timer) {
                root.addFunctionOutputMessage("pause_timer", qsTr("Timer with ID %1 not found").arg(args.timer_id));
                return;
            }
            TimerService.pauseTimer(args.timer_id);
            root.addFunctionOutputMessage("pause_timer", qsTr("Timer %1 paused: %2").arg(args.timer_id).arg(timer.name));
            root.requester.makeRequest();
        },
        "reset_timer": function(args, message) {
            if (args.timer_id === undefined) {
                root.addFunctionOutputMessage("reset_timer", qsTr("Invalid arguments. Must provide 'timer_id'."));
                return;
            }
            const timer = TimerService.uiTimers.find(t => t.id === args.timer_id);
            if (!timer) {
                root.addFunctionOutputMessage("reset_timer", qsTr("Timer with ID %1 not found").arg(args.timer_id));
                return;
            }
            TimerService.resetTimer(args.timer_id);
            root.addFunctionOutputMessage("reset_timer", qsTr("Timer %1 reset: %2").arg(args.timer_id).arg(timer.name));
            root.requester.makeRequest();
        },
        "delete_timer": function(args, message) {
            if (args.timer_id === undefined) {
                root.addFunctionOutputMessage("delete_timer", qsTr("Invalid arguments. Must provide 'timer_id'."));
                return;
            }
            const timer = TimerService.uiTimers.find(t => t.id === args.timer_id);
            if (!timer) {
                root.addFunctionOutputMessage("delete_timer", qsTr("Timer with ID %1 not found").arg(args.timer_id));
                return;
            }
            const timerName = timer.name;
            TimerService.removeTimer(args.timer_id);
            root.addFunctionOutputMessage("delete_timer", qsTr("Timer %1 deleted: %2").arg(args.timer_id).arg(timerName));
            root.requester.makeRequest();
        },
        "search_online_inbrowser": function(args, message) {
            if (!args.query || args.query.trim().length === 0) {
                root.addFunctionOutputMessage("search_online_inbrowser", qsTr("Invalid arguments. Must provide non-empty 'query'."));
                return;
            }
            Quickshell.execDetached(["xdg-open", args.query]);
        }
    }
}
