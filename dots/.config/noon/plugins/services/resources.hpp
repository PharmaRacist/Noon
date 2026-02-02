#ifndef RESOURCESSERVICE_H
#define RESOURCESSERVICE_H

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QTimer>
#include <qqmlengine.h>

class ResourcesService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QVariantMap stats READ stats NOTIFY statsChanged)

public:
    static ResourcesService* instance();
    static ResourcesService* create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
    QVariantMap stats() const { return m_stats; }

signals:
    void statsChanged();

private:
    explicit ResourcesService(QObject *parent = nullptr);
    ~ResourcesService() override = default;

    ResourcesService(const ResourcesService&) = delete;
    ResourcesService& operator=(const ResourcesService&) = delete;

    void updateStats();
    void readCpuStats(double &cpuPercent, double &cpuFreqGhz, double &cpuTemp);
    // This is the line that needs to match the .cpp
    void readMemoryAndSwapStats(quint64 &memTotal, quint64 &memAvailable, quint64 &swapTotal, quint64 &swapFree);
    QVariantList readGpuStats();

    QVariantMap m_stats;
    QTimer *m_updateTimer;
    quint64 m_prevTotal;
    quint64 m_prevIdle;
    static ResourcesService *s_instance;
};

#endif
