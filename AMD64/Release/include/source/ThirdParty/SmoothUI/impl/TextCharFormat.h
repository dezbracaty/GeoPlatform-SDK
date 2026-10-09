#pragma once

#include <QObject>
#include <QQuickItem>
#include <QTextCharFormat>

class TextCharFormat : public QObject, public QTextCharFormat {
    Q_OBJECT
    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    Q_PROPERTY(QVariant foreground READ foreground WRITE setForeground NOTIFY foregroundChanged)
    QML_NAMED_ELEMENT(TextCharFormat)
public:
    TextCharFormat(QObject *parent = nullptr);
    Q_SIGNAL void fontChanged();
    Q_SIGNAL void foregroundChanged();

protected:
    void setFont(const QFont &font);
    QFont font() const;
    QVariant foreground() const;
    void setForeground(const QVariant &foreground);
};
