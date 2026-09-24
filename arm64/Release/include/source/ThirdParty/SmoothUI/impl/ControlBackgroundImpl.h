#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class ControlBackgroundImpl : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(int, radius)
    Q_PROPERTY_AUTO(QColor, defaultColor)
    Q_PROPERTY_AUTO(QColor, secondaryColor)
    Q_PROPERTY_AUTO(QColor, endColor)
    Q_PROPERTY_AUTO(int, borderWidth)
    QML_ELEMENT
public:
    ControlBackgroundImpl();
    void paint(QPainter *painter) override;
};
