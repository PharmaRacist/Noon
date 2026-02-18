#pragma once
#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QtQml/qqmlregistration.h>

class QrCode : public QQuickPaintedItem {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    explicit QrCode(QQuickItem *parent = nullptr);

    QString text() const { return m_text; }
    void setText(const QString &t);

    void paint(QPainter *painter) override;

signals:
    void textChanged();

private:
    QString m_text;
    QImage m_img;
};
