#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class TourBackgroundImpl : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(int, targetX)
    Q_PROPERTY_AUTO(int, targetY)
    Q_PROPERTY_AUTO(int, targetWidth)
    Q_PROPERTY_AUTO(int, targetHeight)
    Q_PROPERTY_AUTO(int, radius)
    Q_PROPERTY_AUTO(QColor, color)
    QML_ELEMENT
private:
    void drawRoundedRect(QPainter *painter, const QRect &rect, int radius);

public:
    TourBackgroundImpl();
    void paint(QPainter *painter) override;
};
