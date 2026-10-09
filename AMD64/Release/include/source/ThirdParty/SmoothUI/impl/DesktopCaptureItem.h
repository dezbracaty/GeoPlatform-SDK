#pragma once

#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class DesktopCaptureItem : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_READONLY_AUTO(QImage, desktop)
    Q_PROPERTY_READONLY_AUTO(QImage, target)
    Q_PROPERTY_READONLY_AUTO(QPoint, position)
    Q_PROPERTY_READONLY_AUTO(QColor, color)
    QML_NAMED_ELEMENT(DesktopCaptureItem)
protected:
    void hoverMoveEvent(QHoverEvent *event) override;
    void hoverEnterEvent(QHoverEvent *event) override;

private:
    void updateTarget(QPointF point);

public:
    explicit DesktopCaptureItem(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;
    Q_INVOKABLE void capture();
};
