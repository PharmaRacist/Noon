pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.functions
import qs.common.utils

Singleton {
    signal textReady(string text)

    function extract(pdfFile: string) {
        proc.input_path = FileUtils.trimFileProtocol(pdfFile);
        proc.running = true;
    }

    Process {
        id: proc
        property string input_path
        command: ["pdftotext", input_path, "-"]

        onExited: exitCode => {
            if (exitCode === 0)
                textReady(stdout.data);
        }

        stdout: StdioCollector {
            id: stdout
        }
    }
}
