import QtQuick
import Quickshell
import Quickshell.Services.Greetd

pragma Singleton

Singleton {
    id: root

    signal authenticationSuccess()
    signal authenticationFailed(string error)

    property bool isAuthenticating: false
    property string lastError: ""
    property string pendingPassword: ""

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            console.log("Greetd: Auth message -", message, "error:", error, "response required:", responseRequired)

            if (error) {
                // This is a recoverable error (like fingerprint scan failed)
                console.log("Greetd: Recoverable error:", message)
                return
            }

            if (responseRequired) {
                // Greetd is asking for the password
                console.log("Greetd: Responding with password")
                Greetd.respond(root.pendingPassword)
                root.pendingPassword = "" // Clear password from memory
            }
        }

        function onAuthenticationSuccess() {
            console.log("Greetd: Authentication succeeded")
            root.isAuthenticating = false
            root.lastError = ""
            root.authenticationSuccess()
        }

        function onAuthFailure(message) {
            console.log("Greetd: Authentication failed -", message)
            root.isAuthenticating = false
            root.lastError = message
            root.pendingPassword = ""
            root.authenticationFailed(message)
        }

        function onError(message) {
            console.log("Greetd: Error -", message)
            root.isAuthenticating = false
            root.lastError = message
            root.pendingPassword = ""
            root.authenticationFailed(message)
        }

        function onLaunched() {
            console.log("Greetd: Session launched, quickshell will exit")
        }
    }

    function authenticate(username, password) {
        if (!username || !password) {
            authenticationFailed(qsTr("Username and password required"))
            return
        }

        if (!Greetd.available) {
            console.error("Greetd: Service is not available. Make sure:")
            console.error("  1. greetd is installed and running")
            console.error("  2. GREETD_SOCK environment variable is set")
            console.error("  3. The user has permission to access the socket")
            authenticationFailed(qsTr("Greetd service is not available"))
            return
        }

        console.log("Greetd: Starting authentication for user:", username)
        root.isAuthenticating = true
        root.lastError = ""
        root.pendingPassword = password

        try {
            // Create session for the user - this will trigger authMessage
            Greetd.createSession(username)
        } catch (error) {
            console.error("Greetd: Authentication error:", error)
            root.isAuthenticating = false
            root.lastError = error.toString()
            root.pendingPassword = ""
            authenticationFailed(error.toString())
        }
    }

    function shutdown() {
        console.log("Greetd: Shutting down system")
        try {
            if (Greetd.available) {
                Greetd.cancel()
            }
            Quickshell.Process.exec("systemctl", ["poweroff"])
        } catch (error) {
            console.error("Greetd: Shutdown error:", error)
        }
    }

    function reboot() {
        console.log("Greetd: Rebooting system")
        try {
            if (Greetd.available) {
                Greetd.cancel()
            }
            Quickshell.Process.exec("systemctl", ["reboot"])
        } catch (error) {
            console.error("Greetd: Reboot error:", error)
        }
    }

    function cancel() {
        console.log("Greetd: Cancelling authentication")
        root.isAuthenticating = false
        root.pendingPassword = ""
        if (Greetd.available) {
            Greetd.cancel()
        }
    }

    // Called when authentication succeeds and we're ready to launch
    function launchSession(command) {
        if (!Greetd.available) {
            console.error("Greetd: Not available, cannot launch session")
            return
        }

        if (Greetd.state !== GreetdState.ReadyToLaunch) {
            console.error("Greetd: Not ready to launch session. Current state:", Greetd.state)
            return
        }

        // Launch with the specified command (or default session)
        // The true parameter means quickshell will exit automatically
        if (command) {
            console.log("Greetd: Launching session with command:", command)
            Greetd.launch(command, [], true)
        } else {
            console.log("Greetd: Launching default session")
            Greetd.launch()
        }
    }

    Component.onCompleted: {
        console.log("Greetd Service initialized")
        console.log("Greetd available:", Greetd.available)
        console.log("Greetd state:", Greetd.state)
        console.log("GREETD_SOCK:", Quickshell.env("GREETD_SOCK"))

        if (!Greetd.available) {
            console.warn("========================================")
            console.warn("WARNING: Greetd is not available!")
            console.warn("Make sure greetd is running and GREETD_SOCK is set")
            console.warn("========================================")
        }
    }
}
