pragma Singleton
pragma ComponentBehavior: Bound
import Noon.Utils.Latex
import QtQuick
import Quickshell

Singleton {
    id: root

    property var processedHashes: new Set()
    property var renderedImagePaths: ({})
    property var latexExpressions: ({})

    signal renderFinished(string hash, string imagePath)

    readonly property LatexRenderer renderer: LatexRenderer {
        fontSize: 18
        padding: 4
    }

    function detectAndRenderLatex(content, colorHex = "#000000") {
        const contentStr = String(content ?? "");
        if (!contentStr)
            return [];

        const regex = /\$\$([\s\S]+?)\$\$|\$([^\$\n]+?)\$|\\\[([\s\S]+?)\\\]|\\\(([\s\S]+?)\\\)/g;
        let match;
        const hashes = [];

        while ((match = regex.exec(contentStr)) !== null) {
            if (!match?.[0])
                continue;

            const expression = match[1] || match[2] || match[3] || match[4];
            if (!expression?.trim())
                continue;

            const fullMatch = match[0];
            const trimmedExpression = expression.trim();
            const hash = Qt.md5(trimmedExpression);

            latexExpressions[hash] = fullMatch;
            hashes.push(hash);

            requestRender(trimmedExpression, colorHex);
        }

        return hashes;
    }

    function replaceLatexWithImages(content, hashes) {
        let result = String(content ?? "");

        for (const hash of hashes) {
            const imagePath = renderedImagePaths?.[hash];
            const originalExpression = latexExpressions?.[hash];

            if (imagePath && originalExpression && result.includes(originalExpression)) {
                const markdownImage = `![latex](${imagePath})`;
                result = result.replace(originalExpression, markdownImage);
            }
        }

        return result;
    }

    function requestRender(expression, colorHex = "#000000") {
        const hash = Qt.md5(expression);

        if (processedHashes.has(hash)) {
            const imagePath = renderedImagePaths[hash];
            Qt.callLater(() => renderFinished(hash, imagePath));
            return [hash, false];
        }

        processedHashes.add(hash);

        const imagePath = renderer.render(expression, colorHex);

        if (imagePath) {
            renderedImagePaths[hash] = imagePath;
            Qt.callLater(() => renderFinished(hash, imagePath));
        }

        return [hash, true];
    }
}
