#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class WatermarkImpl : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(QString, text)
    Q_PROPERTY_AUTO(QPoint, gap)
    Q_PROPERTY_AUTO(QPoint, offset);
    Q_PROPERTY_AUTO(QColor, textColor);
    Q_PROPERTY_AUTO(int, rotate);
    Q_PROPERTY_AUTO(int, textSize);
    QML_NAMED_ELEMENT(WatermarkImpl)
public:
    explicit WatermarkImpl(QQuickItem *parent = nullptr);

    void paint(QPainter *painter) override;
};
