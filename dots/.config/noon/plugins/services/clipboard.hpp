#pragma once
#include <QObject>
#include <QClipboard>
#include <QSqlDatabase>
#include <QStringList>
#include <QImage>
#include <QMimeData>
#include <QTimer>
#include <QQmlEngine>
#include <qqml.h>

class ClipboardService : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QStringList entries READ entries NOTIFY entriesChanged)
    Q_PROPERTY(int maxEntries READ maxEntries WRITE setMaxEntries NOTIFY maxEntriesChanged)

public:
    static ClipboardService* create(QQmlEngine* engine, QJSEngine*) {
        static ClipboardService* instance = nullptr;
        if (!instance) {
            instance = new ClipboardService();
            if (engine) {
                QQmlEngine::setObjectOwnership(instance, QQmlEngine::CppOwnership);
            }
        }
        return instance;
    }

    QStringList entries() const {
        return m_entries;
    }

    int maxEntries() const {
        return m_maxEntries;
    }

    void setMaxEntries(int max);

    Q_INVOKABLE void init();
    Q_INVOKABLE void copyByIndex(int index);
    Q_INVOKABLE void copy(const QString& text);
    Q_INVOKABLE void deleteEntry(int index);
    Q_INVOKABLE void wipe();
    Q_INVOKABLE bool isImage(int index) const;
    Q_INVOKABLE QString getImagePath(int index) const;

signals:
    void entriesChanged();
    void entriesRefreshed();
    void maxEntriesChanged();

private:
    explicit ClipboardService(QObject* parent = nullptr);
    ~ClipboardService();

    void initDatabase();
    void loadHistory();
    void scheduleReload();
    void storeText(const QString& text);
    void storeImage(const QImage& image);

private slots:
    void onClipboardChanged();
    void performScheduledReload();

private:
    QClipboard* m_clipboard;
    QSqlDatabase m_db;
    QStringList m_entries;
    int m_maxEntries = 300;
    bool m_ignoreNextChange = false;
    QTimer* m_reloadTimer;
    bool m_isProcessing = false;
    QString m_lastClipboardHash;
    bool m_initialized = false;

    struct Entry {
        int id;
        QString type;
        QString content;
        QString imagePath;
        qint64 timestamp;
    };

    QList<Entry> m_fullEntries;
};
