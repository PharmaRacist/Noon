#include "cava_watcher.hpp"
#include <algorithm>
#include <QUrl>

CavaWatcher::CavaWatcher(QObject *parent)
    : QObject(parent)
    , m_process(new QProcess(this))
{
    connect(m_process, &QProcess::readyReadStandardOutput, this, &CavaWatcher::onReadyRead);
    connect(m_process, &QProcess::errorOccurred, this, &CavaWatcher::onProcessError);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &CavaWatcher::onProcessFinished);

    // Initialize with zeros
    m_data.reserve(m_barCount);
    for (int i = 0; i < m_barCount; ++i) {
        m_data.append(0.0);
    }
    m_previousWeights.assign(m_barCount, 0.0);
}

void CavaWatcher::setActive(bool a) {
    if (m_active == a) return;

    m_active = a;

    if (m_active) {
        QString configPath;

        // Use custom config path if set
        if (!m_configPath.isEmpty()) {
            configPath = QUrl(m_configPath).toLocalFile();
        } else {
            // Try default locations
            QStringList defaultPaths = {
                QDir::homePath() + "/.config/noon/scripts/cava/raw_binary_config.txt",
                QDir::homePath() + "/.config/cava/raw_binary_config.txt"
            };

            for (const QString& path : defaultPaths) {
                if (QFile::exists(path)) {
                    configPath = path;
                    break;
                }
            }
        }

        if (!configPath.isEmpty() && !QFile::exists(configPath)) {
            qWarning() << "CAVA config not found at:" << configPath;
        }

        QStringList args;
        if (!configPath.isEmpty()) {
            args << "-p" << configPath;
        }

        m_process->start("cava", args);

        if (!m_process->waitForStarted(1000)) {
            qWarning() << "Failed to start CAVA:" << m_process->errorString();
            m_active = false;
        }
    } else {
        m_process->terminate();
        if (!m_process->waitForFinished(500)) {
            m_process->kill();
        }
        std::fill(m_data.begin(), m_data.end(), 0.0);
        m_previousWeights.assign(m_barCount, 0.0);
        emit dataChanged();
    }

    emit activeChanged();
}

void CavaWatcher::onReadyRead() {
    if (!m_active) return;

    QByteArray rawBytes = m_process->readAllStandardOutput();
    const int frameSize = m_barCount * sizeof(uint16_t);

    // Skip incomplete frames
    if (rawBytes.size() < frameSize) return;

    // Only process the latest frame, discard old buffered data
    const uint16_t* samples = reinterpret_cast<const uint16_t*>(
        rawBytes.constData() + rawBytes.size() - frameSize
    );

    // Pre-calculate smoothing factor
    const double smoothFactor = 1.0 / (m_smoothing + 1.0);
    const double inverseFactor = 1.0 - smoothFactor;

    // In-place update to avoid allocation
    for (int i = 0; i < m_barCount; ++i) {
        // Scale down from uint16_t (0-65535) to reasonable range
        double rawVal = samples[i] / 32.0;

        // Single-pass temporal smoothing
        double val = (rawVal * smoothFactor) + (m_previousWeights[i] * inverseFactor);
        m_previousWeights[i] = val;
        m_data[i] = val;
    }

    emit dataChanged();
}

void CavaWatcher::onProcessError(QProcess::ProcessError error) {
    qWarning() << "CAVA process error:" << error;
}

void CavaWatcher::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    if (m_active) {
        m_active = false;
        std::fill(m_data.begin(), m_data.end(), 0.0);
        emit dataChanged();
        emit activeChanged();
    }
}

CavaWatcher::~CavaWatcher() {
    if (m_process->state() != QProcess::NotRunning) {
        m_process->terminate();
        m_process->waitForFinished(500);
    }
}
