import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services
import Noon

StyledRect {
    id: root
    color: "transparent"
    radius: Rounding.verylarge
    anchors.fill: parent
    clip: true

    property string searchQuery

    onSearchQueryChanged: view.url = Mem.options.networking.searchPrefix + searchQuery
    Component.onCompleted: {
        AddBlocker.filePath = FileUtils.trimFileProtocol(Directories.assets) + "/addlist.txt";
        WebEngine.settings.forceDarkMode = true;
        WebEngine.settings.hyperlinkAuditingEnabled = true;
        WebEngine.settings.javascriptCanAccessClipboard = true;
        WebEngine.settings.localStorageEnabled = true;
        WebEngine.settings.navigateOnDropEnabled = true;
        WebEngine.settings.pdfViewerEnabled = true;
        WebEngine.settings.pluginsEnabled = true;
        WebEngine.settings.showScrollBars = false;
        WebEngine.settings.spatialNavigationEnabled = true;
        WebEngine.settings.touchIconsEnabled = true;
        WebEngine.settings.webGLEnabled = true;
        WebEngine.settings.webRTCPublicInterfacesOnly = true;
        WebEngine.settings.accelerated2dCanvasEnabled = true;
        WebEngine.settings.allowWindowActivationFromJavaScript = true;
        WebEngine.settings.defaultTextEncoding = "utf-8";
        WebEngine.settings.dnsPrefetchEnabled = true;
        WebEngine.settings.errorPageEnabled = true;
        WebEngine.settings.focusOnNavigationEnabled = true;
        WebEngine.settings.fullScreenSupportEnabled = true;
    }

    WebEngineProfile {
        id: webProfile
        storageName: "NoonWebBrowser"
        offTheRecord: false
        downloadPath: Directories.standard.downloads
        spellCheckEnabled: false
        persistentPermissionsPolicy: WebEngineProfile.StoreOnDisk
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        httpCacheType: WebEngineProfile.DiskHttpCache
        httpUserAgent: Mem.options.networking.userAgent
    }

    ColumnLayout {
        anchors.fill: parent

        WebEngineView {
            id: view
            zoomFactor: 1.15
            Layout.fillWidth: true
            Layout.fillHeight: true
            url: Mem.states.sidebar.web.currentUrl || Mem.options.sidebar.web.landingUrl
            profile: webProfile
            Component.onCompleted: {
                view.userScripts.collection = [
                    {
                        name: "AdHider",
                        injectionPoint: WebEngineScript.DocumentReady,
                        worldId: WebEngineScript.MainWorld,
                        sourceCode: "(function() {
                                    let style = document.createElement('style');
                                    style.textContent = '" + AddBlocker.getElementHidingStyles() + "';
                                    document.head.appendChild(style);
                                })();"
                    }
                ];
            }
        }

        StyledIndeterminateProgressBar {
            visible: view.loading
            Layout.fillWidth: true
        }
    }

    Binding {
        target: Mem.states.sidebar.web
        property: "currentUrl"
        value: view.url
    }
}
