import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Noon
import QtWebEngine
import qs.common
import qs.common.widgets
import qs.common.functions
import qs.services

StyledRect {
    id: root
    color: "transparent"
    radius: Rounding.verylarge
    anchors.fill: parent
    clip: true
    property alias web_view: view
    property string searchQuery
    property bool obsolete: false
    onSearchQueryChanged: view.url = Mem.options.networking.searchPrefix + searchQuery
    focus: true

    Component.onCompleted: {
        WebEngine.settings.localStorageEnabled = true;
        WebEngine.settings.focusOnNavigationEnabled = true;
        WebEngine.settings.dnsPrefetchEnabled = true;
        // WebEngine.settings.errorPageEnabled = true;
        // WebEngine.settings.fullScreenSupportEnabled = true;
        // WebEngine.settings.defaultTextEncoding = "utf-8";
        // WebEngine.settings.hyperlinkAuditingEnabled = true;
        // WebEngine.settings.pdfViewerEnabled = true;
        // WebEngine.settings.touchIconsEnabled = true;
        // WebEngine.settings.pluginsEnabled = true;
        // WebEngine.settings.allowWindowActivationFromJavaScript = true;
        // WebEngine.settings.javascriptCanAccessClipboard = true;
        // WebEngine.settings.webRTCPublicInterfacesOnly = true;
        WebEngine.settings.navigateOnDropEnabled = true;
        WebEngine.settings.spatialNavigationEnabled = true;
        WebEngine.settings.webGLEnabled = true;
        WebEngine.settings.accelerated2dCanvasEnabled = true;
        if (Colors.m3.darkmode)
            WebEngine.settings.forceDarkMode = true;
    }
    WebEngineProfilePrototype {
        id: webProfile
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        persistentPermissionsPolicy: WebEngineProfile.AskEveryTime
        storageName: "NoonWebBrowser"
    }
    function handleAddBlocker() {
        AddBlocker.filePath = FileUtils.trimFileProtocol(Directories.assets) + "/addlist.txt";
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

    ColumnLayout {
        anchors.fill: parent

        WebEngineView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true
            url: Mem.states.sidebar.web.currentUrl || Mem.options.sidebar.web.landingUrl
            profile: webProfile
        }

        StyledIndeterminateProgressBar {
            visible: view.loading
            Layout.fillWidth: true
        }
    }
    WebBrowserBottomDialog {}
    Binding {
        target: Mem.states.sidebar.web
        property: "currentUrl"
        value: view.url
    }
}
