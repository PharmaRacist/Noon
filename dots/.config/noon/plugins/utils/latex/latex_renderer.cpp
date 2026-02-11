#include "latex_renderer.hpp"
#include <QImage>
#include <QPainter>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QDir>
#include <QFile>

// MicroTeX Headers
#include <latex.h>
#include <render.h>
#include <platform/qt/graphic_qt.h>

LatexRenderer::LatexRenderer(QObject *parent)
    : QObject(parent), m_fontSize(25.0f), m_padding(10) {

    static bool isInit = false;
    if (!isInit) {
        // Initialize with bundled resources
        tex::LaTeX::init(MICROTEX_RES_DIR);
        isInit = true;
    }

    m_cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/noon/latex";
    QDir().mkpath(m_cacheDir);
}

QString LatexRenderer::render(const QString &expression, const QString &colorHex) {
    if (expression.isEmpty()) return "";

    // Create unique cache key
    QByteArray raw = expression.toUtf8() + colorHex.toUtf8() + QByteArray::number(m_fontSize);
    QString hash = QString(QCryptographicHash::hash(raw, QCryptographicHash::Md5).toHex());
    QString filePath = m_cacheDir + "/" + hash + ".png";

    if (QFile::exists(filePath)) {
        return "file://" + filePath;
    }

    // Parse color (#RRGGBB to 0xAARRGGBB)
    uint32_t color = colorHex.mid(1).toUInt(nullptr, 16) | 0xFF000000;

    // Parse LaTeX
    auto res = tex::LaTeX::parse(
        expression.toStdWString(),
        1920,
        m_fontSize,
        m_fontSize / 3.f,
        color
    );

    if (!res) return "";

    // Render to QImage
    QImage img(
        static_cast<int>(res->getWidth()) + (m_padding * 2),
        static_cast<int>(res->getHeight()) + (m_padding * 2),
        QImage::Format_ARGB32
    );
    img.fill(Qt::transparent);

    {
        QPainter painter(&img);
        painter.setRenderHint(QPainter::Antialiasing);

        // Graphics2D_qt is in tex:: namespace
        tex::Graphics2D_qt g2(&painter);
        res->draw(g2, m_padding, m_padding);
    }

    img.save(filePath);
    delete res;

    return "file://" + filePath;
}
