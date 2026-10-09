#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class InputBackgroundImpl : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(bool, targetActiveFocus)
    Q_PROPERTY_AUTO(int, radius)
    Q_PROPERTY_AUTO(int, offsetY)
    Q_PROPERTY_AUTO(QColor, endColor)
    Q_PROPERTY_AUTO(QColor, defaultColor)
    Q_PROPERTY_AUTO(int, borderWidth)
    Q_PROPERTY_AUTO(int, gradientHeight)
    QML_ELEMENT
public:
    InputBackgroundImpl();
    void paint(QPainter *painter) override;
};
