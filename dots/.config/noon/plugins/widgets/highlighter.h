#ifndef HIGHLIGHTER_H
#define HIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QQuickTextDocument>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QtQml/qqmlregistration.h>

class JsonHighlighter : public QSyntaxHighlighter {
    Q_OBJECT
    QML_NAMED_ELEMENT(JsonHighlighter)

    Q_PROPERTY(QQuickTextDocument* textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QColor keyColor READ keyColor WRITE setKeyColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor stringColor READ stringColor WRITE setStringColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor numberColor READ numberColor WRITE setNumberColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor boolColor READ boolColor WRITE setBoolColor NOTIFY colorsChanged)

public:
    explicit JsonHighlighter(QObject *parent = nullptr);

    QQuickTextDocument* textDocument() const { return m_textDocument; }
    void setTextDocument(QQuickTextDocument* doc);

    void setKeyColor(const QColor &c);
    void setStringColor(const QColor &c);
    void setNumberColor(const QColor &c);
    void setBoolColor(const QColor &c);

    QColor keyColor() const { return m_keyColor; }
    QColor stringColor() const { return m_stringColor; }
    QColor numberColor() const { return m_numberColor; }
    QColor boolColor() const { return m_boolColor; }

protected:
    void highlightBlock(const QString &text) override;

private:
    struct Rule {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    std::vector<Rule> highlightRules;
    QQuickTextDocument* m_textDocument = nullptr;
    QColor m_keyColor, m_stringColor, m_numberColor, m_boolColor;
    void setupRules();

signals:
    void textDocumentChanged();
    void colorsChanged();
};

#endif
