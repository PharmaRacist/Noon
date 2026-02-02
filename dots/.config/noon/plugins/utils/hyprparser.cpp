#include "hyprparser.hpp"
#include <QFile>
#include <QSaveFile>
#include <QTextStream>
#include <QRegularExpression>

HyprParser::HyprParser(QObject *parent) : QObject(parent) {
    m_vars = new QQmlPropertyMap(this);
    m_watcher = new QFileSystemWatcher(this);
    m_saveTimer = new QTimer(this);

    m_saveTimer->setSingleShot(true);
    m_saveTimer->setInterval(300);

    connect(m_vars, &QQmlPropertyMap::valueChanged, this, &HyprParser::onPropertyUpdated);
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &HyprParser::reload);
    connect(m_saveTimer, &QTimer::timeout, this, &HyprParser::executeSave);
}

void HyprParser::setPath(const QString &path) {
    QString localPath = path.startsWith("file://") ? QUrl(path).toLocalFile() : path;
    if (m_path == localPath) return;
    if (!m_path.isEmpty()) m_watcher->removePath(m_path);
    m_path = localPath;
    if (QFile::exists(m_path)) {
        m_watcher->addPath(m_path);
        reload();
    }
    emit pathChanged();
}

void HyprParser::reload() {
    if (m_path.isEmpty()) return;
    if (!m_watcher->files().contains(m_path) && QFile::exists(m_path)) m_watcher->addPath(m_path);

    QtConcurrent::run([path = m_path]() {
        return parseFileContent(path);
    }).then(this, [this](const QVariantMap &results) {
        m_internalUpdating = true;
        for (auto it = results.begin(); it != results.end(); ++it) {
            m_vars->insert(it.key(), it.value());
        }
        m_internalUpdating = false;
        if (!m_isLoaded) {
            m_isLoaded = true;
            emit isLoadedChanged();
        }
    });
}

void HyprParser::onPropertyUpdated(const QString &key) {
    Q_UNUSED(key)
    if (!m_internalUpdating) m_saveTimer->start();
}

void HyprParser::forceSave() {
    m_saveTimer->stop();
    executeSave();
}

void HyprParser::executeSave() {
    if (m_path.isEmpty() || m_internalUpdating) return;

    QString path = m_path;
    QVariantMap currentData;
    for (const QString &key : m_vars->keys()) {
        currentData[key] = m_vars->value(key);
    }

    (void)QtConcurrent::run([path, currentData]() {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

        QStringList lines;
        QTextStream in(&file);
        while (!in.atEnd()) {
            QString line = in.readLine();
            bool matched = false;
            QString trimmed = line.trimmed();

            if (trimmed.startsWith('$')) {
                int eqIdx = trimmed.indexOf('=');
                if (eqIdx > 1) {
                    QString key = trimmed.mid(1, eqIdx - 1).trimmed();
                    if (currentData.contains(key)) {
                        int commentIdx = line.indexOf('#');
                        QString comment = (commentIdx != -1) ? line.mid(commentIdx) : "";
                        lines << QString("$%1 = %2 %3").arg(key, fastFormatValue(currentData[key]), comment).trimmed();
                        matched = true;
                    }
                }
            }
            if (!matched) lines << line;
        }
        file.close();

        QSaveFile outFile(path);
        if (outFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&outFile);
            out << lines.join("\n") << "\n";
            outFile.commit();
        }
    });
}

QVariantMap HyprParser::parseFileContent(const QString &filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return {};

    QVariantMap map;
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (!line.startsWith('$')) continue;
        int eqIdx = line.indexOf('=');
        if (eqIdx <= 1) continue;

        QString key = line.mid(1, eqIdx - 1).trimmed();
        QString valPart = line.mid(eqIdx + 1);
        int hashIdx = valPart.indexOf('#');
        if (hashIdx != -1) valPart = valPart.left(hashIdx);

        map.insert(key, fastParseValue(QStringView(valPart).trimmed()));
    }
    return map;
}

QVariant HyprParser::fastParseValue(QStringView str) {
    if (str.startsWith('"') && str.endsWith('"')) return str.mid(1, str.size() - 2).toString();
    if (str == u"true") return true;
    if (str == u"false") return false;
    bool ok;
    double num = str.toDouble(&ok);
    return ok ? QVariant(num) : QVariant(str.toString());
}

QString HyprParser::fastFormatValue(const QVariant &val) {
    if (val.userType() == QMetaType::Bool) return val.toBool() ? "true" : "false";
    if (val.userType() == QMetaType::Double || val.userType() == QMetaType::Int) return val.toString();
    QString s = val.toString();
    return s.contains(' ') ? QString("\"%1\"").arg(s) : s;
}
