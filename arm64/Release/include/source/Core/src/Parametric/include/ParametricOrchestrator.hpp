#pragma once

#include "CommandPayloadNormalizer.hpp"
#include "GraphMeshExecutor.hpp"
#include "ParametricModelRepository.hpp"
#include "ParametricModelTypes.hpp"
#include "TessellationService.hpp"
#include "VersionCommitCoordinator.hpp"

#include <memory>

namespace GPlatform::Parametric {

class ParametricOrchestrator {
public:
    explicit ParametricOrchestrator(ParametricModelRepository& repository);

    CommandResult executeCommand(const CommandEnvelope& command);
    CommandResult executeQuery(const QueryEnvelope& query);

private:
    CommandResult runPreExecutionGates(const CommandEnvelope& command,
                                       const QString& canonicalCommandType) const;
    CommandResult handleGraphCreate(const CommandEnvelope& command,
                                    const QVariantMap& rawPayload,
                                    bool recordHistory);
    CommandResult handleModelCreate(const CommandEnvelope& command,
                                    const QVariantMap* payloadOverride = nullptr,
                                    bool recordHistory = true);
    CommandResult handleModelUpdateParameter(const CommandEnvelope& command);
    CommandResult handleModelUndo(const CommandEnvelope& command);
    CommandResult handleModelRedo(const CommandEnvelope& command);
    CommandResult handleGraphPreview(const CommandEnvelope& command);
    CommandResult handleIrValidate(const CommandEnvelope& command) const;
    CommandResult handleModelHistoryQuery(const QueryEnvelope& query);
    CommandResult handleDescribeCapabilityQuery(const QueryEnvelope& query) const;

    void attachHistorySnapshotDelta(CommandResult& result) const;
    bool checkExpectedVersion(const CommandEnvelope& command, CommandResult& outError) const;

private:
    ParametricModelRepository& m_repository;
    GraphMeshExecutor m_graphExecutor;
    CommandPayloadNormalizer m_payloadNormalizer;
    TessellationService m_tessellationService;
    VersionCommitCoordinator m_versionCommitCoordinator;
};

} // namespace GPlatform::Parametric
