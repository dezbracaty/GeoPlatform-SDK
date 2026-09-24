#pragma once

#include <QQuickItem>

class WindowOpacityFixer : public QQuickItem {
    Q_OBJECT
    QML_NAMED_ELEMENT(WindowOpacityFixer)

public:
    explicit WindowOpacityFixer(QQuickItem *parent = nullptr);
protected:
    void componentComplete() override;
};
