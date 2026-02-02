#include "highlighter.hpp"

JsonHighlighter::JsonHighlighter(QObject *parent)
    : QSyntaxHighlighter(parent)
{
    setupRules();
}

void JsonHighlighter::setTextDocument(QQuickTextDocument* doc) {
    if (m_textDocument == doc) return;
    m_textDocument = doc;
    if (m_textDocument) {
        setDocument(m_textDocument->textDocument());
    }
    emit textDocumentChanged();
}

void JsonHighlighter::highlightBlock(const QString &text) {
    for (const auto &rule : highlightRules) {
        QRegularExpressionMatchIterator it = rule.pattern.globalMatch(text);
        while (it.hasNext()) {
            QRegularExpressionMatch match = it.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
}

void JsonHighlighter::setupRules() {
    highlightRules.clear();
    auto add = [this](const QString &p, const QColor &c) {
        if (!c.isValid()) return;
        Rule r;
        r.pattern = QRegularExpression(p);
        r.format.setForeground(c);
        highlightRules.push_back(r);
    };

    add(R"raw(\b(true|false|null)\b)raw", m_boolColor);
    add(R"raw(-?\d+(\.\d+)?([eE][+-]?\d+)?)raw", m_numberColor);
    add(R"raw(".+?"\s*:)raw", m_keyColor);
    add(R"raw(:\s*".*?")raw", m_stringColor);

    rehighlight();
}

// Color setters (simplified for brevity)
void JsonHighlighter::setKeyColor(const QColor &c) { if(m_keyColor != c) { m_keyColor = c; setupRules(); emit colorsChanged(); } }
void JsonHighlighter::setStringColor(const QColor &c) { if(m_stringColor != c) { m_stringColor = c; setupRules(); emit colorsChanged(); } }
void JsonHighlighter::setNumberColor(const QColor &c) { if(m_numberColor != c) { m_numberColor = c; setupRules(); emit colorsChanged(); } }
void JsonHighlighter::setBoolColor(const QColor &c) { if(m_boolColor != c) { m_boolColor = c; setupRules(); emit colorsChanged(); } }
