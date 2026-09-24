#pragma once

#include <QAbstractItemModel>
#include <QQuickTextDocument>
#include <QQmlEngine>

class LineNumberModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int lineCount READ lineCount WRITE setLineCount NOTIFY lineCountChanged)
    QML_NAMED_ELEMENT(LineNumberModel)
public:
    explicit LineNumberModel(QObject *parent = nullptr);
    int lineCount() const;
    void setLineCount(int lineCount);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Q_INVOKABLE int currentLineNumber(QQuickTextDocument *textDocument, int cursorPosition);
    Q_SIGNAL void lineCountChanged();

private:
    int m_lineCount = 0;
};
