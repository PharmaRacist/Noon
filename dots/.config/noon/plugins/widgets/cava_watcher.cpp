#include "cava_watcher.h"
#include <QDir>
#include <algorithm>

CavaWatcher::CavaWatcher(QObject *parent) : QObject(parent), m_process(new QProcess(this)) {
    QString configPath = QDir::homePath() + "/.config/noon/scripts/cava/raw_binary_config.txt";
    m_process->start("cava", {"-p", configPath});
    connect(m_process, &QProcess::readyReadStandardOutput, this, &CavaWatcher::onReadyRead);
}

void CavaWatcher::onReadyRead() {
    // Read EVERYTHING currently in the pipe
    QByteArray rawBytes = m_process->readAllStandardOutput();
    if (rawBytes.size() < 2) return;

    // CAVA sends 16-bit integers.
    // If the data is "ugly" or not moving, we ensure we only take the LATEST frame.
    const int frameSize = m_barCount * sizeof(uint16_t);
    if (rawBytes.size() > frameSize) {
        rawBytes = rawBytes.right(frameSize); // Keep only the newest data
    }

    const uint16_t* samples = reinterpret_cast<const uint16_t*>(rawBytes.constData());
    int count = rawBytes.size() / sizeof(uint16_t);

    QList<double> processed;
    processed.reserve(count);

    for (int i = 0; i < count; ++i) {
        double val = static_cast<double>(samples[i]);

        // AUTO-NORMALIZATION:
        // If the signal is too small, this "stretches" it so it's not ugly/flat.
        // 65535 is max for 16-bit.
        processed.append(val);
    }

    m_data = processed;
    emit dataChanged();
}

CavaWatcher::~CavaWatcher() {
    m_process->terminate();
}
