pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.common
import qs.common.functions

Singleton {
    id: root

    readonly property int renderPadding: 4
    readonly property string microtexBinaryDir: "/opt/MicroTeX"
    readonly property string microtexBinaryName: "LaTeX"
    readonly property string latexOutputPath: Directories.services.latex

    property var processedHashes: new Set()
    property var renderedImagePaths: ({})

    signal renderFinished(string hash, string imagePath)

    function requestRender(expression) {
        const hash = Qt.md5(expression);
        const imagePath = `${latexOutputPath}/${hash}.svg`;

        if (processedHashes.has(hash)) {
            renderFinished(hash, imagePath);
            return [hash, false];
        }

        processedHashes.add(hash);

        const commandArgs = ["bash", "-c", `cd ${microtexBinaryDir} && ./${microtexBinaryName} ` + `-headless ` + `'-input=${StringUtils.shellSingleQuoteEscape(StringUtils.escapeBackslashes(expression))}' ` + `'-output=${imagePath}' ` + `'-textsize=${Fonts.sizes.normal}' ` + `'-padding=${renderPadding}' ` + `'-foreground=${Colors.colOnLayer1}' ` + `-maxwidth=0.85`];

        const processConfig = {
            command: commandArgs,
            running: true
        };

        const process = Qt.createQmlObject(`import Quickshell.Io; Process {}`, root);

        process.onExited.connect(exitCode => {
            if (exitCode === 0) {
                renderedImagePaths[hash] = imagePath;
                root.renderFinished(hash, imagePath);
            }
            process.destroy();
        });

        process.command = commandArgs;
        process.running = true;

        return [hash, true];
    }
}
