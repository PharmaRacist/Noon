#include "addblocker.h"
#include <QFile>
#include <QTextStream>
#include <QUrl>
#include <QDebug>

void AddBlocker::setFilePath(const QString &path) {
    if (m_filePath != path) {
        m_filePath = path;
        parseFilterFile();
        emit filePathChanged();
    }
}

void AddBlocker::setEnabled(bool e) {
    if (m_enabled != e) {
        m_enabled = e;
        emit enabledChanged();
    }
}

void AddBlocker::parseFilterFile() {
    m_urlFilters.clear();
    m_elementFilters.clear();
    QFile file(m_filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty() || line.startsWith("!")) continue;
        if (line.contains("##")) { // Element hiding
            QString selector = line.section("##", 1);
            if (!selector.isEmpty()) m_elementFilters << selector;
        } else { // URL blocking
            QString pattern = line.section('$', 0, 0).section(',', 0, 0);
            if (!pattern.isEmpty()) m_urlFilters << pattern;
        }
    }
}

void AddBlocker::interceptRequest(QWebEngineUrlRequestInfo &info) {
    if (!m_enabled || m_urlFilters.isEmpty()) return;
    QString url = info.requestUrl().toString();
    for (const QString &filter : m_urlFilters) {
        if (url.contains(filter)) {
            info.block(true);
            return;
        }
    }
}

QString AddBlocker::getElementHidingStyles() const {
    if (m_elementFilters.isEmpty()) return "";
    return m_elementFilters.join(", ") + " { display: none !important; }";
}
