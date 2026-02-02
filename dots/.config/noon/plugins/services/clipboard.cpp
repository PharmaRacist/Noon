#include "clipboard.hpp"
#include <QGuiApplication>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QBuffer>

ClipboardService::ClipboardService(QObject* parent)
    : QObject(parent)
    , m_clipboard(QGuiApplication::clipboard())
    , m_reloadTimer(new QTimer(this))
{
    m_reloadTimer->setSingleShot(true);
    m_reloadTimer->setInterval(50);
    connect(m_reloadTimer, &QTimer::timeout, this, &ClipboardService::performScheduledReload);
}

ClipboardService::~ClipboardService() {
    if (m_db.isOpen()) {
        m_db.close();
    }
}

void ClipboardService::init() {
    if (m_initialized) {
        return;
    }

    initDatabase();
    loadHistory();
    connect(m_clipboard, &QClipboard::dataChanged, this, &ClipboardService::onClipboardChanged);

    m_initialized = true;
}

void ClipboardService::initDatabase() {
    QString dbPath = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation) + "/clipboard.db";
    QDir().mkpath(QFileInfo(dbPath).path());

    m_db = QSqlDatabase::addDatabase("QSQLITE", "clipboard_connection");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        return;
    }

    QSqlQuery query(m_db);

    query.exec(R"(
        CREATE TABLE IF NOT EXISTS clipboard_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            content TEXT,
            content_hash TEXT,
            image_path TEXT,
            timestamp INTEGER NOT NULL
        )
    )");

    QSqlQuery checkColumn(m_db);
    checkColumn.exec("PRAGMA table_info(clipboard_history)");
    bool hasHashColumn = false;
    while (checkColumn.next()) {
        if (checkColumn.value(1).toString() == "content_hash") {
            hasHashColumn = true;
            break;
        }
    }

    if (!hasHashColumn) {
        query.exec("ALTER TABLE clipboard_history ADD COLUMN content_hash TEXT");
    }

    query.exec("CREATE INDEX IF NOT EXISTS idx_timestamp ON clipboard_history(timestamp DESC)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_hash ON clipboard_history(content_hash)");
}

void ClipboardService::loadHistory() {
    if (m_isProcessing) {
        return;
    }

    m_isProcessing = true;

    QStringList oldEntries = m_entries;
    m_entries.clear();
    m_fullEntries.clear();

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM clipboard_history ORDER BY timestamp DESC LIMIT :limit");
    query.bindValue(":limit", m_maxEntries);

    if (!query.exec()) {
        m_isProcessing = false;
        return;
    }

    while (query.next()) {
        Entry entry;
        entry.id = query.value("id").toInt();
        entry.type = query.value("type").toString();
        entry.content = query.value("content").toString();
        entry.imagePath = query.value("image_path").toString();
        entry.timestamp = query.value("timestamp").toLongLong();

        m_fullEntries.append(entry);

        if (entry.type == "image") {
            m_entries.append("Image");
        } else {
            QString displayText = entry.content;
            displayText.replace('\n', ' ').replace('\t', ' ');
            if (displayText.length() > 100) {
                displayText = displayText.left(100) + "...";
            }
            m_entries.append(displayText);
        }
    }

    QSqlQuery cleanupQuery(m_db);
    cleanupQuery.prepare(R"(
        DELETE FROM clipboard_history
        WHERE id NOT IN (
            SELECT id FROM clipboard_history
            ORDER BY timestamp DESC
            LIMIT :limit
        )
    )");
    cleanupQuery.bindValue(":limit", m_maxEntries);
    cleanupQuery.exec();

    m_isProcessing = false;

    if (oldEntries != m_entries) {
        emit entriesChanged();
    }
    emit entriesRefreshed();
}

void ClipboardService::scheduleReload() {
    if (!m_reloadTimer->isActive()) {
        m_reloadTimer->start();
    }
}

void ClipboardService::performScheduledReload() {
    loadHistory();
}

void ClipboardService::onClipboardChanged() {
    if (m_ignoreNextChange) {
        m_ignoreNextChange = false;
        return;
    }

    if (m_isProcessing) {
        return;
    }

    const QMimeData* mimeData = m_clipboard->mimeData();
    if (!mimeData) return;

    QString currentHash;

    if (mimeData->hasImage()) {
        QImage image = qvariant_cast<QImage>(mimeData->imageData());
        if (!image.isNull()) {
            QByteArray imageData;
            QBuffer buffer(&imageData);
            buffer.open(QIODevice::WriteOnly);
            image.save(&buffer, "PNG");
            currentHash = QString::fromLatin1(
                QCryptographicHash::hash(imageData, QCryptographicHash::Md5).toHex()
            );

            if (currentHash == m_lastClipboardHash) {
                return;
            }

            m_lastClipboardHash = currentHash;
            storeImage(image);
        }
    } else if (mimeData->hasText()) {
        QString text = mimeData->text();
        if (!text.isEmpty()) {
            currentHash = QString::fromLatin1(
                QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Md5).toHex()
            );

            if (currentHash == m_lastClipboardHash) {
                return;
            }

            m_lastClipboardHash = currentHash;
            storeText(text);
        }
    }
}

void ClipboardService::storeText(const QString& text) {
    QByteArray hash = QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Sha256).toHex();

    QSqlQuery checkQuery(m_db);
    checkQuery.prepare("SELECT id FROM clipboard_history WHERE content_hash = :hash AND type = 'text' LIMIT 1");
    checkQuery.bindValue(":hash", QString::fromLatin1(hash));

    if (checkQuery.exec() && checkQuery.next()) {
        int existingId = checkQuery.value(0).toInt();
        QSqlQuery updateQuery(m_db);
        updateQuery.prepare("UPDATE clipboard_history SET timestamp = :timestamp WHERE id = :id");
        updateQuery.bindValue(":timestamp", QDateTime::currentSecsSinceEpoch());
        updateQuery.bindValue(":id", existingId);

        if (updateQuery.exec()) {
            scheduleReload();
        }
        return;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO clipboard_history (type, content, content_hash, timestamp)
        VALUES ('text', :content, :hash, :timestamp)
    )");
    query.bindValue(":content", text);
    query.bindValue(":hash", QString::fromLatin1(hash));
    query.bindValue(":timestamp", QDateTime::currentSecsSinceEpoch());

    if (query.exec()) {
        scheduleReload();
    }
}

void ClipboardService::storeImage(const QImage& image) {
    QString imagePath = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation) + "/clipboard_images/";
    QDir().mkpath(imagePath);

    QString filename = QString::number(QDateTime::currentMSecsSinceEpoch()) + ".png";
    QString fullPath = imagePath + filename;

    if (!image.save(fullPath)) {
        return;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO clipboard_history (type, image_path, timestamp)
        VALUES ('image', :path, :timestamp)
    )");
    query.bindValue(":path", fullPath);
    query.bindValue(":timestamp", QDateTime::currentSecsSinceEpoch());

    if (query.exec()) {
        scheduleReload();
    } else {
        QFile::remove(fullPath);
    }
}

void ClipboardService::copyByIndex(int index) {
    if (index < 0 || index >= m_fullEntries.size()) return;

    const Entry& entry = m_fullEntries[index];
    m_ignoreNextChange = true;

    if (entry.type == "image") {
        QImage image(entry.imagePath);
        if (!image.isNull()) {
            m_clipboard->setImage(image);
        } else {
            m_ignoreNextChange = false;
        }
    } else {
        m_clipboard->setText(entry.content);
    }
}

void ClipboardService::copy(const QString& text) {
    m_ignoreNextChange = true;
    m_lastClipboardHash.clear();
    m_clipboard->setText(text, QClipboard::Clipboard);
}

void ClipboardService::deleteEntry(int index) {
    if (index < 0 || index >= m_fullEntries.size()) return;

    const Entry& entry = m_fullEntries[index];
    int entryId = entry.id;
    QString imagePath = entry.imagePath;
    QString type = entry.type;

    if (type == "image" && !imagePath.isEmpty()) {
        QFile::remove(imagePath);
    }

    QSqlQuery query(m_db);
    query.prepare("DELETE FROM clipboard_history WHERE id = :id");
    query.bindValue(":id", entryId);

    if (query.exec()) {
        scheduleReload();
    }
}

void ClipboardService::wipe() {
    QString imagePath = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation) + "/clipboard_images/";
    QDir dir(imagePath);
    dir.removeRecursively();

    QSqlQuery query(m_db);
    if (!query.exec("DELETE FROM clipboard_history")) {
        return;
    }

    query.exec("DELETE FROM sqlite_sequence WHERE name='clipboard_history'");
    query.exec("VACUUM");

    scheduleReload();
}

bool ClipboardService::isImage(int index) const {
    if (index < 0 || index >= m_fullEntries.size()) return false;
    return m_fullEntries[index].type == "image";
}

QString ClipboardService::getImagePath(int index) const {
    if (index < 0 || index >= m_fullEntries.size()) return "";
    if (m_fullEntries[index].type == "image") {
        return m_fullEntries[index].imagePath;
    }
    return "";
}

void ClipboardService::setMaxEntries(int max) {
    if (max <= 0) return;

    if (m_maxEntries != max) {
        m_maxEntries = max;
        emit maxEntriesChanged();
        scheduleReload();
    }
}
