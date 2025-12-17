pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Provides access to loginctl session data.
 */
Singleton {
    id: root

    property var sessions: []
    property var sessionIds: []
    property var sessionById: ({})

    function updateSessions() {
        getSessions.running = true;
    }

    function terminateSession(sessionId) {
        Quickshell.execDetached(["pkexec","loginctl", "terminate-session", sessionId])
    }

    function updateAll() {
        updateSessions();
    }

    Component.onCompleted: {
        updateAll();
    }

    // Auto-refresh every 5 seconds
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.updateAll()
    }

    Process {
        id: getSessions
        command: ["loginctl", "list-sessions", "-j"]
        stdout: StdioCollector {
            id: sessionsCollector
            onStreamFinished: {
                try {
                    root.sessions = JSON.parse(sessionsCollector.text);

                    let tempSessionById = {};
                    for (var i = 0; i < root.sessions.length; ++i) {
                        var session = root.sessions[i];
                        tempSessionById[session.session] = session;
                    }
                    root.sessionById = tempSessionById;
                    root.sessionIds = root.sessions.map(s => s.session);
                } catch (e) {
                    console.error("Error parsing loginctl sessions:", e);
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.error("loginctl error:", text);
                }
            }
        }
    }
}
