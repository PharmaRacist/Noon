#pragma once

#include <QObject>
#include <QString>
#include <QQmlEngine>

class LatexRenderer : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(float fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(int padding READ padding WRITE setPadding NOTIFY paddingChanged)

public:
    explicit LatexRenderer(QObject *parent = nullptr);

    Q_INVOKABLE QString render(const QString &expression, const QString &colorHex);

    float fontSize() const { return m_fontSize; }
    void setFontSize(float size) {
        if (m_fontSize != size) {
            m_fontSize = size;
            emit fontSizeChanged();
        }
    }

    int padding() const { return m_padding; }
    void setPadding(int padding) {
        if (m_padding != padding) {
            m_padding = padding;
            emit paddingChanged();
        }
    }

signals:
    void fontSizeChanged();
    void paddingChanged();

private:
    float m_fontSize;
    int m_padding;
    QString m_cacheDir;
};
