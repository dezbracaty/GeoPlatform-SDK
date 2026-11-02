#ifndef TMENUGROUP_HPP
#define TMENUGROUP_HPP

#include <QObject>
#include <QQmlListProperty>
class TMenuItem;
class TMenuGroup : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<TMenuItem> items READ getItemList CONSTANT);

public:
    using SPtr = std::shared_ptr<TMenuGroup>;
    explicit TMenuGroup(QObject* parent = nullptr);
    // QQmlListProperty to access the list of items in this group
    auto getItemList() -> QQmlListProperty<TMenuItem>;
#if QT_VERSION > QT_VERSION_CHECK(6, 0, 0)
    static auto itemCount(QQmlListProperty<TMenuItem>*) -> qsizetype;
    static auto itemAt(QQmlListProperty<TMenuItem>*, qsizetype) -> TMenuItem*;
#else
    static auto itemCount(QQmlListProperty<TMenuItem>*) -> int;
    static auto itemAt(QQmlListProperty<TMenuItem>*, int) -> TMenuItem*;
#endif

    // public functions
    TMenuItem* getItemByText(const QString& text);
    TMenuGroup(const TMenuGroup& other) : QObject(nullptr), m_items(other.m_items) {}
    void addItem(TMenuItem* item);
    void merge(TMenuGroup::SPtr other);
    void deepCopy(TMenuItem* item);
    const QList<TMenuItem*>& items() const { return m_items; }
    ~TMenuGroup();

private:
    QList<TMenuItem*> m_items;
};

#endif // TMENUGROUP_HPP