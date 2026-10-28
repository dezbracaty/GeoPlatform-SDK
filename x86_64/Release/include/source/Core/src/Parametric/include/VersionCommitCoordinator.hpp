#pragma once

#include "ModelPositionUtil.hpp"
#include "ParametricModelRepository.hpp"
#include "ParametricModelTypes.hpp"

namespace GPlatform::Parametric {

class VersionCommitCoordinator {
public:
    explicit VersionCommitCoordinator(ParametricModelRepository& repository);

    struct CommitContext {
        QString requestedModelId;
        QString displayName;
        QString featureType;
        QVariantMap rawParameters;
        QMap<QString, double> evaluatedParametersMm;
        QString featureGraphHash;
        QString brepHash;
        QString meshHash;
        std::vector<GeomTriangle> triangles;
    };

    CommandResult commitCreatedModel(const CommitContext& context) const;

private:
    std::vector<ModelPositionUtil::ExistingObject> collectExistingMeshObjects() const;

private:
    ParametricModelRepository& m_repository;
};

} // namespace GPlatform::Parametric
