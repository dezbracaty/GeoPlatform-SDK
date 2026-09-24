#pragma once

#include <QObject>
#include <QtQml>
#include <QColor>
#include <QtQml/qqmlprivate.h>
#include "stdafx.h"

#if QT_VERSION < QT_VERSION_CHECK(6, 5, 0)
#  include <QtQuickControls2/private/qquickstyle_p.h>
class QQuickAttachedPropertyPropagator : public QQuickAttachedObject {
protected:
    void initialize() {
        QQuickAttachedObject::init();
    }
};

#else
#  include <QtQuickControls2/QQuickAttachedPropertyPropagator>
#endif

class GlobalConfig {
public:
    GlobalConfig() {};
    int radius = 4;
    int highlightMoveDuration = 167;
    QVariant primaryColor = "Colors.blue";
    QColor textColor = QColor(255, 255, 255, 255);
    int minimumHeight = 400;
    QString iconFamily = "";
    bool dark = false;
};

class SmoothUI : public QQuickAttachedPropertyPropagator {
    Q_OBJECT
    Q_PROPERTY_AUTO(int, radius)
    Q_PROPERTY_AUTO(int, highlightMoveDuration)
    Q_PROPERTY_AUTO(QVariant, theme)
    Q_PROPERTY_AUTO(QColor, textColor)
    Q_PROPERTY_AUTO(QString, iconFamily)
    Q_PROPERTY_AUTO(int, minimumHeight)
    Q_PROPERTY(bool dark READ dark WRITE setDark RESET resetDark NOTIFY darkChanged FINAL)
    Q_PROPERTY(QVariant primaryColor READ primaryColor WRITE setPrimaryColor RESET resetPrimaryColor
                   NOTIFY primaryColorChanged FINAL)
    QML_NAMED_ELEMENT(SmoothUI)
    QML_UNCREATABLE("")
protected:
    void attachedParentChange(QQuickAttachedPropertyPropagator *newParent,
                              QQuickAttachedPropertyPropagator *oldParent) override;

public:
    enum DarkMode { Light = 0x0000, Dark = 0x0001, System = 0x0002 };
    Q_DECLARE_FLAGS(DarkModes, DarkMode)
    Q_FLAG(DarkModes)
    explicit SmoothUI(QObject *parent = nullptr);

    Q_SIGNAL void darkChanged();
    void setDark(const bool &val);
    bool dark() const;
    void resetDark();
    void inheritDark(const bool &val);
    void propagateDark();

    Q_SIGNAL void primaryColorChanged();
    void setPrimaryColor(const QVariant &val);
    QVariant primaryColor() const;
    void resetPrimaryColor();
    void inheritPrimaryColor(const QVariant &val);
    void propagatePrimaryColor();

    static SmoothUI *qmlAttachedProperties(QObject *object);
    static GlobalConfig *config;

private:
    bool m_dark;
    bool m_explicitDark = false;
    QVariant m_primaryColor;
    bool m_explicitPrimaryColor = false;
};

QML_DECLARE_TYPEINFO(SmoothUI, QML_HAS_ATTACHED_PROPERTIES)
