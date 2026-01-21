#include "latex.h"
#include <QCryptographicHash>
#include <QDir>
#include <QDebug>

LatexService* LatexService::s_instance = nullptr;

LatexService::LatexService(QObject *parent)
    : QObject(parent)
    , m_renderPadding(4)
    , m_latexOutputPath()
    , m_microtexBinaryDir("/opt/MicroTeX")
    , m_microtexBinaryName("LaTeX")
{
}

LatexService::~LatexService() {
    // Clean up any running processes
    for (auto it = m_activeProcesses.constBegin(); it != m_activeProcesses.constEnd(); ++it) {
        QProcess* process = it.key();
        if (process->state() != QProcess::NotRunning) {
            process->kill();
        }
        process->deleteLater();
    }
    m_activeProcesses.clear();
    s_instance = nullptr;
}

LatexService* LatexService::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine) {
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)

    if (!s_instance) {
        s_instance = new LatexService();
    }

    QQmlEngine::setObjectOwnership(s_instance, QQmlEngine::CppOwnership);
    return s_instance;
}

QString LatexService::hashExpression(const QString& expression) const {
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(expression.toUtf8());
    return QString(hash.result().toHex());
}

QVariantList LatexService::processedHashes() const {
    QVariantList list;
    for (const QString& hash : m_processedHashes) {
        list.append(hash);
    }
    return list;
}

QVariantMap LatexService::processedExpressions() const {
    QVariantMap map;
    for (auto it = m_processedExpressions.constBegin(); it != m_processedExpressions.constEnd(); ++it) {
        map.insert(it.key(), it.value());
    }
    return map;
}

QVariantMap LatexService::renderedImagePaths() const {
    QVariantMap map;
    for (auto it = m_renderedImagePaths.constBegin(); it != m_renderedImagePaths.constEnd(); ++it) {
        map.insert(it.key(), it.value());
    }
    return map;
}

void LatexService::setRenderPadding(int padding) {
    if (m_renderPadding != padding) {
        m_renderPadding = padding;
        emit renderPaddingChanged();
    }
}

void LatexService::setLatexOutputPath(const QString& path) {
    if (m_latexOutputPath != path) {
        m_latexOutputPath = path;

        QDir dir;
        if (!dir.exists(path)) {
            dir.mkpath(path);
        }

        emit latexOutputPathChanged();
    }
}

void LatexService::setMicrotexBinaryDir(const QString& dir) {
    if (m_microtexBinaryDir != dir) {
        m_microtexBinaryDir = dir;
        emit microtexBinaryDirChanged();
    }
}

void LatexService::setMicrotexBinaryName(const QString& name) {
    if (m_microtexBinaryName != name) {
        m_microtexBinaryName = name;
        emit microtexBinaryNameChanged();
    }
}

QString LatexService::getImagePath(const QString& hash) const {
    return m_renderedImagePaths.value(hash, QString());
}

bool LatexService::isProcessed(const QString& hash) const {
    return m_processedHashes.contains(hash);
}

QString LatexService::escapeShellArg(const QString& arg) const {
    // Escape single quotes and backslashes for shell
    QString escaped = arg;
    escaped.replace("\\", "\\\\");
    escaped.replace("'", "'\\''");
    return escaped;
}

void LatexService::renderWithProcess(
    const QString& expression,
    const QString& hash,
    const QString& outputPath,
    int textSize,
    const QString& foregroundColor,
    const QString& backgroundColor,
    double maxWidth)
{
    QProcess* process = new QProcess(this);
    m_activeProcesses[process] = hash;

    // Build command
    QString command = QString("cd %1 && ./%2 -headless '-input=%3' '-output=%4' '-textsize=%5' '-padding=%6' '-foreground=%7' -maxwidth=%8")
        .arg(m_microtexBinaryDir)
        .arg(m_microtexBinaryName)
        .arg(escapeShellArg(expression))
        .arg(outputPath)
        .arg(textSize)
        .arg(m_renderPadding)
        .arg(foregroundColor)
        .arg(maxWidth);

    if (!backgroundColor.isEmpty()) {
        command += QString(" '-background=%1'").arg(backgroundColor);
    }

    qDebug() << "[LatexService] Executing command:" << command;

    // Connect signals
    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &LatexService::onProcessFinished);

    // Start process
    process->start("bash", QStringList() << "-c" << command);
}

void LatexService::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    QProcess* process = qobject_cast<QProcess*>(sender());
    if (!process) return;

    QString hash = m_activeProcesses.value(process);
    m_activeProcesses.remove(process);

    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        QString imagePath = QString("%1/%2.svg").arg(m_latexOutputPath, hash);
        m_renderedImagePaths[hash] = imagePath;
        emit renderedImagePathsChanged();
        emit renderFinished(hash, imagePath);
        qDebug() << "[LatexService] Successfully rendered:" << hash;
    } else {
        QString errorMsg = process->readAllStandardError();
        qWarning() << "[LatexService] Render failed for hash:" << hash
                   << "Exit code:" << exitCode
                   << "Error:" << errorMsg;

        // Remove from processed since it failed
        m_processedHashes.remove(hash);
        m_processedExpressions.remove(hash);
        emit renderError(hash, QString("Process failed with exit code %1: %2").arg(exitCode).arg(errorMsg));
    }

    process->deleteLater();
}

QVariantList LatexService::requestRender(const QString& expression) {
    return requestRenderWithOptions(
        expression,
        16,        // default text size
        "#FFFFFF", // default foreground
        QString(), // no background
        0.85       // default max width
    );
}

QVariantList LatexService::requestRenderWithOptions(
    const QString& expression,
    int textSize,
    const QString& foregroundColor,
    const QString& backgroundColor,
    double maxWidth)
{
    const QString hash = hashExpression(expression);
    const QString imagePath = QString("%1/%2.svg").arg(m_latexOutputPath, hash);

    // Check if already processed
    if (m_processedHashes.contains(hash)) {
        emit renderFinished(hash, imagePath);
        return QVariantList{hash, false};
    }

    // Mark as processed
    m_processedHashes.insert(hash);
    m_processedExpressions[hash] = expression;
    emit processedHashesChanged();
    emit processedExpressionsChanged();

    qDebug() << "[LatexService] Rendering expression:" << expression;
    qDebug() << "                Hash:" << hash;
    qDebug() << "                Output:" << imagePath;

    // Render using process
    renderWithProcess(
        expression,
        hash,
        imagePath,
        textSize,
        foregroundColor,
        backgroundColor,
        maxWidth
    );

    return QVariantList{hash, true};
}
