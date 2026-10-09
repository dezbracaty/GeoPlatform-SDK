#pragma once

#include <QObject>
#include <QtQml>

class ParallaxViewType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum SourceOffsetKind { Absolute = 0x0000, Relative = 0x0001};
    Q_DECLARE_FLAGS(SourceOffsetKinds, SourceOffsetKind)
    Q_FLAG(SourceOffsetKinds)
};

class TabViewType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum TabWidthBehavior { Equal = 0x0000, SizeToContent = 0x0001, Compact = 0x0002 };
    Q_DECLARE_FLAGS(TabWidthBehaviors, TabWidthBehavior)
    Q_FLAG(TabWidthBehaviors)

    enum CloseButtonVisibility { Never = 0x0000, Always = 0x0001, OnHover = 0x0002 };
    Q_DECLARE_FLAGS(CloseButtonVisibilitys, CloseButtonVisibility)
    Q_FLAG(CloseButtonVisibilitys)
};

class TimelineType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum Mode { Left = 0x0000, Right = 0x0001, Alternate = 0x0002 };
    Q_DECLARE_FLAGS(Modes, Mode)
    Q_FLAG(Modes)
};

class WindowType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum LaunchMode { Standard = 0x0000, SingleTask = 0x0001, SingleInstance = 0x0002 };
    Q_DECLARE_FLAGS(LaunchModes, LaunchMode)
    Q_FLAG(LaunchModes)
};

class WindowEffectType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum EffectMode { Normal = 0x0000, Mica = 0x0001, Acrylic = 0x0002, MicaAlt = 0x0004 };
    Q_DECLARE_FLAGS(EffectModes, EffectMode)
    Q_FLAG(EffectModes)
};


class NavigationViewType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum DisplayMode {
        Open = 0x0000,
        Compact = 0x0001,
        Minimal = 0x0002,
        Auto = 0x0004,
        Top = 0x0008
    };
    Q_DECLARE_FLAGS(DisplayModes, DisplayMode)
    Q_FLAG(DisplayModes)
};

class TimePickerType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum HourFormat {
        H = 0x0000,
        HH = 0x0001,
    };
    Q_DECLARE_FLAGS(HourFormates, HourFormat)
    Q_FLAG(HourFormat)
};

class DatePickerType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum DatePickerField {
        Day = 0x0000,
        Month = 0x0001,
        Year = 0x0002,
    };
    Q_DECLARE_FLAGS(DatePickerFields, DatePickerField)
    Q_FLAG(DatePickerField)
};

class NumberBoxType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum PlacementMode { Inline = 0x0000, Compact = 0x0001 };
    Q_DECLARE_FLAGS(PlacementModes, PlacementMode)
    Q_FLAG(PlacementMode)
};

class InfoBarType : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    enum Severity { Info = 0x0000, Warning = 0x0001, Error = 0x0002, Success = 0x0004 };
    Q_DECLARE_FLAGS(Severitys, Severity)
    Q_FLAG(Severity)
};
