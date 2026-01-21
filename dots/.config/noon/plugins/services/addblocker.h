#pragma once

#include <QObject>
#include <QStringList>
#include <QtWebEngineCore/QWebEngineUrlRequestInterceptor>
#include <QtQml/qqmlregistration.h>

class AddBlocker : public QWebEngineUrlRequestInterceptor {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit AddBlocker(QObject *parent = nullptr) : QWebEngineUrlRequestInterceptor(parent) {}

    QString filePath() const { return m_filePath; }
    void setFilePath(const QString &path);

    bool enabled() const { return m_enabled; }
    void setEnabled(bool e);

    // Official override for network filtering
    void interceptRequest(QWebEngineUrlRequestInfo &info) override;

    // Official way to get CSS for injection
    Q_INVOKABLE QString getElementHidingStyles() const;

signals:
    void filePathChanged();
    void enabledChanged();

private:
    void parseFilterFile();
    QString m_filePath;
    bool m_enabled = true;
    QStringList m_urlFilters;
    QStringList m_elementFilters;
};
