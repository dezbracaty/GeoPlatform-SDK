#pragma once

#include <QObject>
#include <QTextDocument>
#include <QSyntaxHighlighter>
#include <QQuickTextDocument>

class SyntaxHighlighterImpl : public QSyntaxHighlighter {

    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument *textDocument READ textDocument WRITE setTextDocument NOTIFY
                   textDocumentChanged)
    QML_NAMED_ELEMENT(SyntaxHighlighterImpl)
public:
    SyntaxHighlighterImpl(QObject *parent = nullptr);
    Q_INVOKABLE void setFormat(int start, int count, const QVariant &format);
    Q_SIGNAL void textDocumentChanged();
    Q_SIGNAL void highlightBlockChanged(const QVariant &text);

protected:
    QQuickTextDocument *m_textDocument;
    QQuickTextDocument *textDocument() const;
    void setTextDocument(QQuickTextDocument *textDocument);
    virtual void highlightBlock(const QString &text);
};
