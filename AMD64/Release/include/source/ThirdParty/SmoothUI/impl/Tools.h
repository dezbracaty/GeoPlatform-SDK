#pragma once

#include <QObject>
#include <QtQml>
#include <QColor>
#include "stdafx.h"

class Tools : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(Tools)
    QML_SINGLETON
private:
    explicit Tools(QObject *parent = nullptr);
    int windowBuildNumber();

public:
    SINGLETON(Tools)
    static Tools *create(QQmlEngine *, QJSEngine *) {
        return getInstance();
    }
    Q_INVOKABLE QColor withOpacity(const QColor &, qreal alpha);
    Q_INVOKABLE bool isWindows11OrGreater();
    Q_INVOKABLE bool isUrl(const QString &);
    Q_INVOKABLE void clipText(const QString &text);
    Q_INVOKABLE void deleteLater(QObject *p);
    Q_INVOKABLE QString readFile(const QString &fileName);
    Q_INVOKABLE bool writeFile(const QString &fileName, const QString &content);
    Q_INVOKABLE void setOverrideCursor(Qt::CursorShape shape);
    Q_INVOKABLE void restoreOverrideCursor();
    Q_INVOKABLE QImage captureDesktop();
    Q_INVOKABLE int cursorScreenIndex();
};
