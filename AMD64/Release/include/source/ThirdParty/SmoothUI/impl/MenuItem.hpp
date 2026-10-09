#ifndef TMENUITEM_H
#define TMENUITEM_H
#include "BaseDBObject.hpp"
#include "stdafx.h"
#include <QtCore/qtmetamacros.h>
#include <QtCore/qvariant.h>
#include <QtQml/qqml.h>
#include <QtQml/qqmllist.h>
class TMenuItem : public BaseDBObject
{
    Q_OBJECT
    Q_PROPERTY_AUTO(QString, text);
    Q_PROPERTY_AUTO(QString, iconSource);
    Q_PROPERTY_AUTO(QString, displayMode);  // 显示模式：IconOnly, TextBesideIcon, TextOnly
    Q_PROPERTY_AUTO(QString, actionCode);
    Q_PROPERTY_AUTO(bool, enabled);
    Q_PROPERTY_AUTO(bool, checked);
    Q_PROPERTY_AUTO(bool, separator);
    Q_PROPERTY_AUTO(bool, isMenu);
    Q_PROPERTY_AUTO(QVariant, otherData);
    Q_PROPERTY(QQmlListProperty<TMenuItem> items READ getItemList NOTIFY itemsChanged);

    QML_NAMED_ELEMENT(TMenuItem)

private:
    QString m_data;
    QList<TMenuItem*> m_items;

public:
#if QT_VERSION > QT_VERSION_CHECK(6, 0, 0)
    static auto itemsCount(QQmlListProperty<TMenuItem>*) -> qsizetype;
    static auto itemsAt(QQmlListProperty<TMenuItem>*, qsizetype) -> TMenuItem*;
#else
    static auto itemsCount(QQmlListProperty<TMenuItem>*) -> int;
    static auto itemsAt(QQmlListProperty<TMenuItem>*, int) -> TMenuItem*;
#endif
    ~TMenuItem();
    Q_INVOKABLE TMenuItem(QObject* parent = nullptr);
    Q_INVOKABLE void onTriggered();
    Q_INVOKABLE virtual QObject* deepClone() const override;

protected:
    TMenuItem(const QString& text, const QString& iconSource, bool separator = false, bool isMenu = false);

public:
    class Create
    {
    public:
        static auto SimpleItem(const QString& text, bool separator = false, bool isMenu = false) -> TMenuItem*;
        static auto IconSourceItem(const QString& text, const QString& iconSource, bool separator = false, bool isMenu = false) -> TMenuItem*;
    };

public:
    auto getItemList() -> QQmlListProperty<TMenuItem>;
    auto getItems() -> QList<TMenuItem*>;
    auto add(TMenuItem*) -> void;
    auto addAt(int, TMenuItem*) -> void;
    auto removeItems() -> void;
    auto removeItem(const QString&) -> void;

    Q_INVOKABLE TMenuItem* getSubItemByText(const QString& text);

Q_SIGNALS:
    void itemsChanged();
};
Q_DECLARE_METATYPE(TMenuItem);
#endif