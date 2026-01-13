#pragma once
#include <QObject>
#include <QProcess>
#include <QList>
#include <vector>
#include <QtQml/qqmlregistration.h>

class CavaWatcher : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QList<double> data READ data NOTIFY dataChanged)
    Q_PROPERTY(int smoothing READ smoothing WRITE setSmoothing NOTIFY smoothingChanged)

public:
    explicit CavaWatcher(QObject *parent = nullptr);
    ~CavaWatcher();

    QList<double> data() const { return m_data; }

    int smoothing() const { return m_smoothing; }
    void setSmoothing(int s) { if(m_smoothing != s) { m_smoothing = s; emit smoothingChanged(); } }

signals:
    void dataChanged();
    void smoothingChanged();

private slots:
    void onReadyRead();

private:
    QProcess *m_process;
    QList<double> m_data;
    std::vector<double> m_previousWeights; // For temporal smoothing
    int m_smoothing = 2;
};
