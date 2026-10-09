#ifndef BASEDBOBJECT_HPP
#define BASEDBOBJECT_HPP

#include <QObject>
/**
 * @brief all devired class from BaseDBObject should add Q_INVOKABLE to their public construct function!!!!!!!
 * otherwise, it will not be created by QMetaObject::newInstance()
 */
class BaseDBObject : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE BaseDBObject(QObject* parent = nullptr) : QObject(parent) {};
    virtual ~BaseDBObject() = default;

protected:
    virtual QObject* deepClone() const;
    virtual void deepCopy(const QObject* obj);
};

#endif