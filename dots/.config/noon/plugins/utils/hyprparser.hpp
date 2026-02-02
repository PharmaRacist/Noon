#pragma once

#include <QObject>
#include <QString>
#include <QQmlPropertyMap>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QUrl>
#include <QtQml/qqmlregistration.h>
#include <QtConcurrent/QtConcurrent>

class HyprParser : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QQmlPropertyMap* variables READ variables CONSTANT)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY isLoadedChanged)

public:
    explicit HyprParser(QObject *parent = nullptr);

    QString path() const { return m_path; }
    void setPath(const QString &path);
    QQmlPropertyMap* variables() const { return m_vars; }
    bool isLoaded() const { return m_isLoaded; }

    Q_INVOKABLE void reload();
    Q_INVOKABLE void forceSave();

signals:
    void pathChanged();
    void isLoadedChanged();

private slots:
    void onPropertyUpdated(const QString &key);
    void executeSave();

private:
    QString m_path;
    QQmlPropertyMap *m_vars;
    QFileSystemWatcher *m_watcher;
    QTimer *m_saveTimer;

    bool m_isLoaded = false;
    bool m_internalUpdating = false;

    static QVariantMap parseFileContent(const QString &filePath);
    static QVariant fastParseValue(QStringView str);
    static QString fastFormatValue(const QVariant &val);
};
