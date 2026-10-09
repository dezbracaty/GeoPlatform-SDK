#pragma once

#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class RoundRectangle : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(QColor, color)
    Q_PROPERTY_AUTO(QList<int>, radius)
    Q_PROPERTY_AUTO(qreal, borderWidth)
    Q_PROPERTY_AUTO(QColor, borderColor)
    Q_PROPERTY_AUTO(Qt::PenStyle, borderStyle)
    Q_PROPERTY_AUTO(QList<qreal>, dashPattern)
    QML_NAMED_ELEMENT(RoundRectangle)
private:
    QPainterPath createRoundBorderPath() const;
public:
    explicit RoundRectangle(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;
};
