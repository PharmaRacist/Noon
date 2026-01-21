#ifndef LATEXSERVICE_H
#define LATEXSERVICE_H

#include <QObject>
#include <QString>
#include <QHash>
#include <QSet>
#include <QVariantList>
#include <QVariantMap>
#include <QQmlEngine>
#include <QProcess>

class LatexService : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int renderPadding READ renderPadding WRITE setRenderPadding NOTIFY renderPaddingChanged)
    Q_PROPERTY(QString latexOutputPath READ latexOutputPath WRITE setLatexOutputPath NOTIFY latexOutputPathChanged)
    Q_PROPERTY(QString microtexBinaryDir READ microtexBinaryDir WRITE setMicrotexBinaryDir NOTIFY microtexBinaryDirChanged)
    Q_PROPERTY(QString microtexBinaryName READ microtexBinaryName WRITE setMicrotexBinaryName NOTIFY microtexBinaryNameChanged)
    Q_PROPERTY(QVariantList processedHashes READ processedHashes NOTIFY processedHashesChanged)
    Q_PROPERTY(QVariantMap processedExpressions READ processedExpressions NOTIFY processedExpressionsChanged)
    Q_PROPERTY(QVariantMap renderedImagePaths READ renderedImagePaths NOTIFY renderedImagePathsChanged)

public:
    explicit LatexService(QObject *parent = nullptr);
    ~LatexService() override;

    // Singleton instance getter (for QML)
    static LatexService* create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    // Property getters
    int renderPadding() const { return m_renderPadding; }
    QString latexOutputPath() const { return m_latexOutputPath; }
    QString microtexBinaryDir() const { return m_microtexBinaryDir; }
    QString microtexBinaryName() const { return m_microtexBinaryName; }
    QVariantList processedHashes() const;
    QVariantMap processedExpressions() const;
    QVariantMap renderedImagePaths() const;

    // Property setters
    void setRenderPadding(int padding);
    void setLatexOutputPath(const QString& path);
    void setMicrotexBinaryDir(const QString& dir);
    void setMicrotexBinaryName(const QString& name);

    // Main rendering function
    Q_INVOKABLE QVariantList requestRender(const QString& expression);
    Q_INVOKABLE QVariantList requestRenderWithOptions(
        const QString& expression,
        int textSize,
        const QString& foregroundColor,
        const QString& backgroundColor = QString(),
        double maxWidth = 0.85
    );

    // Utility functions
    Q_INVOKABLE QString getImagePath(const QString& hash) const;
    Q_INVOKABLE bool isProcessed(const QString& hash) const;

signals:
    void renderFinished(const QString& hash, const QString& imagePath);
    void renderPaddingChanged();
    void latexOutputPathChanged();
    void microtexBinaryDirChanged();
    void microtexBinaryNameChanged();
    void processedHashesChanged();
    void processedExpressionsChanged();
    void renderedImagePathsChanged();
    void renderError(const QString& hash, const QString& error);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QString hashExpression(const QString& expression) const;
    void renderWithProcess(
        const QString& expression,
        const QString& hash,
        const QString& outputPath,
        int textSize,
        const QString& foregroundColor,
        const QString& backgroundColor,
        double maxWidth
    );

    QString escapeShellArg(const QString& arg) const;

    // Member variables
    int m_renderPadding;
    QString m_latexOutputPath;
    QString m_microtexBinaryDir;
    QString m_microtexBinaryName;
    QSet<QString> m_processedHashes;
    QHash<QString, QString> m_processedExpressions;
    QHash<QString, QString> m_renderedImagePaths;
    QHash<QProcess*, QString> m_activeProcesses; // Maps process to hash

    static LatexService* s_instance;
};

#endif // LATEXSERVICE_H
