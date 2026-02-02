#pragma once
#include <QObject>
#include <QProcess>
#include <QList>
#include <QDir>
#include <QDebug>
#include <vector>
#include <QtQml/qqmlregistration.h>

class CavaWatcher : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QList<double> data READ data NOTIFY dataChanged)
    Q_PROPERTY(int smoothing READ smoothing WRITE setSmoothing NOTIFY smoothingChanged)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(int barCount READ barCount CONSTANT)
    Q_PROPERTY(QString configPath READ configPath WRITE setConfigPath NOTIFY configPathChanged)

public:
    explicit CavaWatcher(QObject *parent = nullptr);
    ~CavaWatcher();

    QList<double> data() const { return m_data; }
    int smoothing() const { return m_smoothing; }
    void setSmoothing(int s) {
        if(m_smoothing != s) {
            m_smoothing = s;
            m_previousWeights.assign(m_barCount, 0.0);
            emit smoothingChanged();
        }
    }

    bool active() const { return m_active; }
    void setActive(bool a);
    int barCount() const { return m_barCount; }

    QString configPath() const { return m_configPath; }
    void setConfigPath(const QString& path) {
        if (m_configPath != path) {
            m_configPath = path;
            emit configPathChanged();
            // Restart if already active
            if (m_active) {
                setActive(false);
                setActive(true);
            }
        }
    }

signals:
    void dataChanged();
    void smoothingChanged();
    void activeChanged();
    void configPathChanged();

private slots:
    void onReadyRead();
    void onProcessError(QProcess::ProcessError error);
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    static const int m_barCount = 30;
    QProcess *m_process;
    QList<double> m_data;
    std::vector<double> m_previousWeights;
    QString m_configPath;
    int m_smoothing = 1;
    bool m_active = false;
};
