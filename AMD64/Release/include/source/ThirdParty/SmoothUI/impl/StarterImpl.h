#pragma once

#include <QSharedMemory>
#include <QtQml/qqml.h>
#include <QObject>
#include <QTimer>
#include <QTranslator>
#include <QLocale>

class StarterImpl : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(StarterImpl)
public:
    explicit StarterImpl(QObject *parent = nullptr);

    Q_INVOKABLE void checkApplication(const QString &appId);
    Q_SIGNAL void handleDataChanged(const QString &args);
    Q_INVOKABLE void init(QLocale locale = QLocale::system());

protected:
    void timerEvent(QTimerEvent *event) override;

private:
    void writeData();
    void handleData();
    void lock();
    void unlock();

private:
    QSharedMemory m_sharedMemory;
    QTimer m_timer;
    QMap<QString, QVariant> m_data;
    QTranslator m_translator;
};
