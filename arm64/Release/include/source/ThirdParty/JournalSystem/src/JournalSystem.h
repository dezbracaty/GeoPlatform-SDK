#ifndef JOURNALSYSTEM_H
#define JOURNALSYSTEM_H

#include "JournalEntry.h"
#include "JournalSystem_global.h"

#include <QByteArray>
#include <QElapsedTimer>
#include <QGuiApplication>
#include <QImage>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QList>
#include <QVariantMap>

#include <functional>

class QQuickWindow;
class QQuickItem;
class Server;

// Application-side Journal service. It records and dispatches input, invokes
// existing Actions, and exposes raw DB/screenshot data. Validation and replay
// scheduling intentionally live in the Python caller.
class JOURNALSYSTEM_EXPORT JournalSystem final : public QObject {
    Q_OBJECT

public:
    using ActionInvoker = std::function<bool(
        const QString&, const QVariantMap&, QString&)>;
    using DbStateProvider = std::function<bool(
        const QString&, QByteArray&, QString&)>;
    using ScreenshotProvider = std::function<QImage()>;
    using ReplayPreparationHandler = std::function<bool(const QString&, QString&)>;

    explicit JournalSystem(QGuiApplication* app);

    QString version() const;
    int init(quint16 port = 9999);
    void setActionInvoker(ActionInvoker invoker);
    void setDbStateProvider(QString serializationFormat,
                            DbStateProvider provider);
    void setScreenshotProvider(ScreenshotProvider provider);
    void setReplayPreparationHandler(ReplayPreparationHandler handler);
    void setStartupReplayId(const QString& replayId);

    void startRecording();
    QJsonArray stopRecording();
    bool executeEntry(const JournalEntry& entry, QString* error = nullptr);

protected:
    bool eventFilter(QObject* watched, QEvent* event) override;

private slots:
    void processRequest(const QByteArray& frame);

private:
    QQuickWindow* resolveWindow(const QJsonObject& descriptor) const;
    QQuickItem* resolveInputTarget(const QJsonObject& payload, QString* error) const;
    bool dispatchInput(const JournalEntry& entry, QString* error);
    bool dispatchAction(const JournalEntry& entry, QString* error);
    bool appendPhysicalInput(QObject* watched, QEvent* event);
    QJsonObject recordingStamp();
    QJsonArray recordedEntries() const;
    void sendResponse(const QJsonValue& requestId,
                      bool success,
                      const QJsonObject& result = {},
                      const QString& error = {});

    static constexpr auto Version = "2.0.0";
    QGuiApplication* m_app{nullptr};
    Server* m_server{nullptr};
    ActionInvoker m_actionInvoker;
    DbStateProvider m_dbStateProvider;
    ScreenshotProvider m_screenshotProvider;
    QString m_dbSerializationFormat;
    ReplayPreparationHandler m_replayPreparationHandler;
    QString m_startupReplayId;
    QString m_pendingReplayId;
    QString m_activeReplayId;
    QString m_failedReplayId;
    QString m_replayPreparationError;
    bool m_recording{false};
    QString m_recordingId;
    bool m_replayActive{false};
    bool m_sendingSyntheticInput{false};
    bool m_recordMouseMoves{true};
    qint64 m_sequence{0};
    QElapsedTimer m_recordingClock;
    QList<JournalEntry> m_entries;
    QString m_recordingsPath;
    QString m_playbacksPath;
};

#endif // JOURNALSYSTEM_H
