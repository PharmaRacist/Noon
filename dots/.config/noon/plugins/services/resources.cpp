#include "resources.hpp"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QDebug>
#include <QProcess>
#include <QTimer>
#include <sys/sysinfo.h>

ResourcesService* ResourcesService::s_instance = nullptr;

ResourcesService::ResourcesService(QObject *parent)
    : QObject(parent)
    , m_prevTotal(0)
    , m_prevIdle(0)
{
    m_stats = QVariantMap{
        {"cpu_percent", 0.0},
        {"cpu_freq_ghz", 0.0},
        {"cpu_temp", 0.0},
        {"mem_total", 0},
        {"mem_available", 0},
        {"swap_total", 0},
        {"swap_free", 0},
        {"gpus", QVariantList()}
    };

    m_updateTimer = new QTimer(this);
    connect(m_updateTimer, &QTimer::timeout, this, &ResourcesService::updateStats);
    m_updateTimer->start(2000);

    updateStats();
}

ResourcesService* ResourcesService::instance()
{
    if (!s_instance) {
        s_instance = new ResourcesService();
    }
    return s_instance;
}

ResourcesService* ResourcesService::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    ResourcesService *inst = instance();
    QJSEngine::setObjectOwnership(inst, QJSEngine::CppOwnership);
    return inst;
}

void ResourcesService::updateStats()
{
    double cpuPercent = 0.0, cpuFreqGhz = 0.0, cpuTemp = 0.0;
    quint64 memTotal = 0, memAvailable = 0;
    quint64 swapTotal = 0, swapFree = 0;

    readCpuStats(cpuPercent, cpuFreqGhz, cpuTemp);
    readMemoryAndSwapStats(memTotal, memAvailable, swapTotal, swapFree);
    QVariantList gpus = readGpuStats();

    m_stats = QVariantMap{
        {"cpu_percent", cpuPercent},
        {"cpu_freq_ghz", cpuFreqGhz},
        {"cpu_temp", cpuTemp},
        {"mem_total", static_cast<qint64>(memTotal)},
        {"mem_available", static_cast<qint64>(memAvailable)},
        {"swap_total", static_cast<qint64>(swapTotal)},
        {"swap_free", static_cast<qint64>(swapFree)},
        {"gpus", gpus}
    };

    emit statsChanged();
}

void ResourcesService::readCpuStats(double &cpuPercent, double &cpuFreqGhz, double &cpuTemp)
{
    // 1. CPU Usage: Parse /proc/stat
    QFile statFile("/proc/stat");
    if (statFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString line = statFile.readLine();
        QStringList parts = line.simplified().split(' ');
        if (parts.size() >= 5) {
            quint64 user = parts[1].toULongLong();
            quint64 nice = parts[2].toULongLong();
            quint64 system = parts[3].toULongLong();
            quint64 idle = parts[4].toULongLong();
            quint64 iowait = parts.size() > 5 ? parts[5].toULongLong() : 0;

            quint64 total = user + nice + system + idle + iowait;
            if (m_prevTotal != 0) {
                double totalDiff = static_cast<double>(total - m_prevTotal);
                double idleDiff = static_cast<double>(idle - m_prevIdle);
                if (totalDiff > 0) {
                    cpuPercent = 100.0 * (totalDiff - idleDiff) / totalDiff;
                }
            }
            m_prevTotal = total;
            m_prevIdle = idle;
        }
    }

    // 2. CPU Clock: Read from sysfs scaling driver (Live data)
    QFile freqFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
    if (freqFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        cpuFreqGhz = freqFile.readAll().trimmed().toDouble() / 1000000.0;
    }

    // 3. CPU Temp: Search hwmon for real silicon sensors
    QDir hwmonDir("/sys/class/hwmon");
    QStringList hwmons = hwmonDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &dir : hwmons) {
        QString path = "/sys/class/hwmon/" + dir;
        QFile nameFile(path + "/name");
        if (nameFile.open(QIODevice::ReadOnly)) {
            QString name = nameFile.readAll().trimmed();
            // Check for common CPU thermal drivers
            if (name == "coretemp" || name == "k10temp" || name == "cpu_thermal" || name == "soc_thermal") {
                QFile tempFile(path + "/temp1_input");
                if (tempFile.open(QIODevice::ReadOnly)) {
                    cpuTemp = tempFile.readAll().trimmed().toDouble() / 1000.0;
                    if (cpuTemp > 0) break;
                }
            }
        }
    }
}

void ResourcesService::readMemoryAndSwapStats(quint64 &memTotal, quint64 &memAvailable, quint64 &swapTotal, quint64 &swapFree)
{
    struct sysinfo info;
    if (sysinfo(&info) == 0) {
        quint64 unit = info.mem_unit;

        memTotal = static_cast<quint64>(info.totalram) * unit;
        memAvailable = static_cast<quint64>(info.freeram + info.bufferram) * unit;

        swapTotal = static_cast<quint64>(info.totalswap) * unit;
        swapFree = static_cast<quint64>(info.freeswap) * unit;
    } else {
        qDebug() << "Failed to get sysinfo stats";
    }
}

QVariantList ResourcesService::readGpuStats()
{
    QVariantList gpus;
    QProcess process;

    // Updated query to include power usage and limits
    QStringList arguments;
    arguments << "--query-gpu=name,temperature.gpu,utilization.gpu,memory.total,memory.used,power.draw,power.limit"
              << "--format=csv,noheader,nounits";

    process.start("nvidia-smi", arguments);
    if (!process.waitForFinished(500)) return gpus;

    QString output = QString::fromLocal8Bit(process.readAllStandardOutput());
    QStringList lines = output.split('\n', Qt::SkipEmptyParts);

    for (int i = 0; i < lines.size(); ++i) {
        QStringList fields = lines[i].split(',');
        if (fields.size() >= 7) {
            QVariantMap gpu;
            gpu["index"] = i;
            gpu["name"] = fields[0].trimmed();
            gpu["temperature"] = fields[1].trimmed().toDouble();
            gpu["utilization"] = fields[2].trimmed().toDouble();
            // QML expects MB for the display text you wrote
            gpu["memory_total"] = fields[3].trimmed().toDouble();
            gpu["memory_used"] = fields[4].trimmed().toDouble();
            gpu["power_draw"] = fields[5].trimmed().toDouble();
            gpu["power_limit"] = fields[6].trimmed().toDouble();

            gpus.append(gpu);
        }
    }
    return gpus;
}
