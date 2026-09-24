#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class QRCodeImpl : public QQuickPaintedItem {
    Q_OBJECT

    Q_PROPERTY_AUTO(QString, text)
    Q_PROPERTY_AUTO(QColor, color)
    Q_PROPERTY_AUTO(QColor, backgroundColor)
    Q_PROPERTY_AUTO(int, size)
    QML_NAMED_ELEMENT(QRCodeImpl)
public:
    explicit QRCodeImpl(QQuickItem *parent = nullptr);

    void paint(QPainter *painter) override;
};
