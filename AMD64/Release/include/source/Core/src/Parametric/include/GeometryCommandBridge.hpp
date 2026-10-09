#pragma once

#include "ParametricModelTypes.hpp"

namespace GPlatform::Parametric {

class GeometryCommandBridge {
public:
    static GeometryCommandBridge& instance();

    CommandResult executeAction(const QString& actionCode, const QVariantMap& params);
    CommandResult executeQuery(const QString& queryType, const QVariantMap& params = QVariantMap());

private:
    GeometryCommandBridge() = default;
    CommandEnvelope toCommandEnvelope(const QString& actionCode, const QVariantMap& params) const;
    QueryEnvelope toQueryEnvelope(const QString& queryType, const QVariantMap& params) const;
};

} // namespace GPlatform::Parametric
