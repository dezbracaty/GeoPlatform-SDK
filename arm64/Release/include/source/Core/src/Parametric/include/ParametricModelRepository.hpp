#pragma once

#include "ParametricModelTypes.hpp"
#include <QMap>
#include <QReadWriteLock>
#include <optional>

namespace GPlatform::Parametric {

class ParametricModelRepository {
public:
    struct CommitInput {
        QString requestedModelId;
        QString modelName;
        QVariantMap rawParameters;
        QMap<QString, double> evaluatedParametersMm;
        QString featureGraphHash;
        QString brepHash;
        QString meshManifestHash;
        QString dbInstanceId;
    };

    ParametricModelRepository() = default;

    std::optional<ParametricModelState> getModel(const QString& modelId) const;
    bool hasModel(const QString& modelId) const;
    std::optional<QString> getModelIdByDbInstanceId(const QString& dbInstanceId) const;

    // Commit the next immutable version snapshot for a model.
    ParametricModelState commitVersion(const CommitInput& input, qint64* outPrevVersion = nullptr);

    struct HistorySnapshot {
        QString modelId;
        int cursor{0};         // Number of applied commands in the command log.
        int totalCommands{0};  // Total command count in the command log.
        bool canUndo{false};
        bool canRedo{false};
        QVariantMap effectiveRawParameters;
        QVector<QString> appliedCommandTypes;
        QVector<QString> pendingCommandTypes;
    };

    void ensureHistorySeeded(const QString& modelId, const QVariantMap& rawParameters);
    bool appendCreateCommand(const QString& modelId,
                             const CommandEnvelope& command,
                             const QVariantMap& effectiveRawParameters);
    bool appendUpdateCommand(const QString& modelId,
                             const CommandEnvelope& command,
                             const QVariantMap& updatePatch);
    std::optional<HistorySnapshot> getHistorySnapshot(const QString& modelId) const;
    std::optional<QVariantMap> resolveEffectivePayload(const QString& modelId, int cursor) const;
    bool setHistoryCursor(const QString& modelId, int cursor);

private:
    QString allocateModelIdLocked();

    struct HistoryEntry {
        QString commandId;
        QString traceId;
        QString commandType;
        QVariantMap payload;
    };

    struct ModelHistoryState {
        QVector<HistoryEntry> entries;
        int cursor{0};
    };

    static QVariantMap normalizeCreatePayload(const QVariantMap& payload);
    static QVariantMap normalizeUpdatePatch(const QVariantMap& patch);
    static std::optional<QVariantMap> replayPayload(const ModelHistoryState& history, int cursor);
    static void appendHistoryEntry(ModelHistoryState& history, const HistoryEntry& entry);

private:
    mutable QReadWriteLock m_lock;
    QMap<QString, ParametricModelState> m_models;
    QMap<QString, ModelHistoryState> m_histories;
    QMap<QString, QString> m_modelIdByDbInstanceId;
};

} // namespace GPlatform::Parametric
