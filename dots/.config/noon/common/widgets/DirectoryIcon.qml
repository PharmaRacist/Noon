// From https://github.com/caelestia-dots/shell with modifications.
// License: GPLv3

import QtQuick
import Quickshell
import qs.common
import qs.common.functions

Image {
    id: root

    required property var fileModelData

    asynchronous: true
    fillMode: Image.PreserveAspectFit
    source: {
        if (!fileModelData.fileIsDir)
            return NoonUtils.iconPath("application-x-zerosize");

        if ([Directories.standard.documents, Directories.standard.downloads, Directories.standard.music, Directories.standard.pictures, Directories.standard.videos].some((dir) => {
            return FileUtils.trimFileProtocol(dir) === fileModelData.filePath;
        }))
            return NoonUtils.iconPath(`folder-${fileModelData.fileName.toLowerCase()}`);

        return NoonUtils.iconPath("inode-directory");
    }
    onStatusChanged: {
        if (status === Image.Error)
            source = NoonUtils.iconPath("error");

    }

    Process {
        running: !fileModelData.fileIsDir
        command: ["file", "--mime", "-b", fileModelData.filePath]

        stdout: StdioCollector {
            onStreamFinished: {
                const mime = text.split(";")[0].replace("/", "-");
                root.source = Images.validImageTypes.some((t) => {
                    return mime === `image-${t}`;
                }) ? fileModelData.fileUrl : NoonUtils.iconPath(mime);
            }
        }

    }

}
