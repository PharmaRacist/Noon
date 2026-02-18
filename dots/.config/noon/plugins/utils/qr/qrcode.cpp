#include "qrcode.hpp"
#include <QPainter>
#include "QrCodeGenerator.h"

QrCode::QrCode(QQuickItem *parent) : QQuickPaintedItem(parent) {}

void QrCode::setText(const QString &t) {
    if (m_text != t) {
        m_text = t;
        QrCodeGenerator gen;
        m_img = gen.generateQr(m_text);
        update();
        emit textChanged();
    }
}

void QrCode::paint(QPainter *painter) {
    if (m_img.isNull()) return;
    painter->setRenderHint(QPainter::Antialiasing, false);
    painter->setRenderHint(QPainter::SmoothPixmapTransform, false);
    painter->drawImage(boundingRect(), m_img);
}
