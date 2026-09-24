#ifndef JOURNALSERVER_H
#define JOURNALSERVER_H

#include <QByteArray>
#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>

class Server final : public QObject {
    Q_OBJECT

public:
    explicit Server(QObject* parent = nullptr, quint16 port = 0);
    void sendFrame(const QByteArray& payload);
    bool drainWrites(int timeoutMs = 1000);
    bool isListening() const { return m_server->isListening(); }

signals:
    void frameReceived(const QByteArray& payload);

private slots:
    void acceptConnection();
    void readFrames();
    void connectionClosed();

private:
    static constexpr qint64 MaximumFrameSize = 128 * 1024 * 1024;
    QTcpServer* m_server{nullptr};
    QTcpSocket* m_socket{nullptr};
    QByteArray m_buffer;
    qint64 m_pendingLength{-1};
};

#endif // JOURNALSERVER_H
