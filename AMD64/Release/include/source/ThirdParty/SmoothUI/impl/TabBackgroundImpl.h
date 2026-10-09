#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class TabBackgroundImpl : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(QColor, color)
    Q_PROPERTY_AUTO(QColor, strokeColor)
    Q_PROPERTY_AUTO(int, radius)
    QML_ELEMENT
public:
    TabBackgroundImpl();
    void paint(QPainter *painter) override;
};
