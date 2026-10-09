#pragma once

#include <QObject>
#include <QtQml>
#include <QColor>
#include "stdafx.h"

class Resource : public QObject {
    Q_OBJECT
    Q_PROPERTY_AUTO(QUrl, windowIcon);
    Q_PROPERTY_READONLY_AUTO(bool, systemDark)
    QML_NAMED_ELEMENT(R)
    QML_SINGLETON
private:
    explicit Resource(QObject *parent = nullptr);

public:
    SINGLETON(Resource)
    static Resource *create(QQmlEngine *, QJSEngine *) {
        return getInstance();
    }
    void init(QObject *obj);
    bool eventFilter(QObject *obj, QEvent *event) override;
    bool getSystemDark();
    Q_INVOKABLE QString resolvedUrl(const QString &path);

private:
    QQmlEngine *m_engine = nullptr;
    QString m_baseUrl;
};
