#pragma once

#include "BaseID.hpp"
#include <Geometry.hpp>
#include <QMap>
#include <QVariant>
#include <QVector>
#include <QString>
#include <vector>

namespace GPlatform::Parametric {

struct CommandEnvelope {
    QString traceId;
    QString commandId;
    QString modelId;
    qint64 expectedVersion{-1};
    QString executionMode{"sync"};
    bool dryRun{false};
    QString commandType;
    QVariantMap payload;
};

struct QueryEnvelope {
    QString queryType;
    QString modelId;
    QVariantMap payload;
};

struct CommandDiagnostics {
    QString severity{"info"};
    QString code;
    QString message;
};

struct CommandResult {
    bool success{false};
    QString status{"error"};
    QString modelId;
    qint64 prevVersion{-1};
    qint64 newVersion{-1};
    QString errorCode;
    QString message;
    QVariantMap delta;
    QVector<CommandDiagnostics> diagnostics;
    QString createdDbId;
};

struct ParametricModelState {
    QString modelId;
    QString name;
    qint64 currentVersion{0};
    QMap<QString, double> evaluatedParametersMm;
    QVariantMap rawParameters;
    QString featureGraphHash;
    QString brepHash;
    QString meshManifestHash;
    QString latestDbInstanceId;
};

struct FeatureBuildOutput {
    std::vector<GeomTriangle> triangles;
    QString buildStrategy;
    bool usesOccKernel{false};
    QString deferredReason;
};

struct TessellationOutput {
    std::vector<GeomTriangle> triangles;
    QString meshHash;
    QString strategy;
};

} // namespace GPlatform::Parametric
