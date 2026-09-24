#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QItemSelectionModel>
#include "stdafx.h"

class TreeDataGridModel;

class TreeNode : public QObject {
    Q_OBJECT
    Q_PROPERTY_READONLY_AUTO(QVariantMap, rowData);
    Q_PROPERTY_READONLY_AUTO(int, depth);
    Q_PROPERTY_READONLY_AUTO(bool, expanded);
    Q_PROPERTY_READONLY_AUTO_P(TreeNode *, nodeParent);
    Q_PROPERTY_READONLY_AUTO(QList<QSharedPointer<TreeNode>>, nodeChildren)

public:
    explicit TreeNode(QObject *parent = nullptr);
    Q_INVOKABLE bool hasChildren();
    void appendChildren(QSharedPointer<TreeNode>);
    void removeChildren(TreeNode *);
    bool visible();
};


class TreeDataGridModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY_AUTO(QList<QVariant>, sourceData)
    Q_PROPERTY_READONLY_AUTO(QList<QSharedPointer<TreeNode>>, displayData)
    QML_ELEMENT
public:
    explicit TreeDataGridModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    int count() const;
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariant get(int index);
    Q_INVOKABLE void collapse(int rowIndex);
    Q_INVOKABLE void expand(int rowIndex);
    Q_INVOKABLE void selectRange(QItemSelectionModel *selectionModel, int startRow, int endRow);

private:
    void insertRole(const QString &name);
    void handleSourceData();
    QList<QVariant> reverseList(const QList<QVariant> &originalList);
    void __removeRows(int rowIndex, int count);
    void __insertRows(int rowIndex, QList<QSharedPointer<TreeNode>> data);
Q_SIGNALS:
    void countChanged();

private:
    void emitItemsChanged(int index, int count, const QVector<int> &roles);
    void updateValues(const QVariant &val);
    QList<QString> m_roles;
    QSharedPointer<TreeNode> m_treeRoot;
};
