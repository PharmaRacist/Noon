import QtQuick
import QtWebEngine
import qs.common
import qs.common.widgets

StyledRect {
    id: root
    anchors.fill: parent

    clip: true
    color: "transparent"
    radius: Rounding.verylarge

    property alias web_view: view
    property string searchQuery

    onSearchQueryChanged: view.url = Mem.options.networking.searchPrefix + searchQuery

    function loadSettings() {
        var settings = WebEngine.settings;

        settings.forceDarkMode = Colors.m3.darkmode;
        settings.localStorageEnabled = true;
        settings.focusOnNavigationEnabled = true;
        settings.dnsPrefetchEnabled = true;
        settings.navigateOnDropEnabled = true;
        settings.spatialNavigationEnabled = true;
        settings.webGLEnabled = true;
        settings.accelerated2dCanvasEnabled = true;
        settings.javascriptCanAccessClipboard = true;
    }

    WebEngineProfilePrototype {
        id: webProfile
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        persistentPermissionsPolicy: WebEngineProfile.AskEveryTime
        storageName: "NoonWebBrowser"
    }

    WebEngineView {
        id: view
        anchors.fill: parent
        url: Mem.states.sidebar.web.currentUrl || "https://www.google.com"
        profile: webProfile
        onUrlChanged: Mem.states.sidebar.web.currentUrl = view.url
        Component.onCompleted: loadSettings()
    }

    StyledIndeterminateProgressBar {
        visible: view.loading
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    WebBrowserBottomDialog {}
}
