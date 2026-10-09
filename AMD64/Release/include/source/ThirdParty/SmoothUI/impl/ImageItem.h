#pragma once

#include <QQuickPaintedItem>
#include <QPainter>
#include "stdafx.h"

class ImageItem : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(QImage, source)
    QML_NAMED_ELEMENT(ImageItem)

public:
    explicit ImageItem(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;
};
