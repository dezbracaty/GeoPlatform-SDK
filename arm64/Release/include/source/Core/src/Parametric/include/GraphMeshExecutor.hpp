#pragma once

#include "ParametricModelTypes.hpp"
#include <QStringList>

namespace GPlatform::Parametric {

struct GraphExecutionResult {
    bool success{false};
    std::vector<GeomTriangle> triangles;
    QString graphHash;
    QVector<CommandDiagnostics> diagnostics;
    QString errorCode;
    QString message;
};

class GraphMeshExecutor {
public:
    static QStringList supportedOperators();

    GraphExecutionResult execute(const QVariantMap& graph,
                                 const QVariantMap& parameters,
                                 const QVariantList& constraints) const;
};

} // namespace GPlatform::Parametric
