#pragma once

#include <QVariantMap>
#include <QString>

namespace GPlatform::Parametric {

class CommandPayloadNormalizer {
public:
    QVariantMap extractUpdatePatch(const QVariantMap& payload, QString& error) const;

private:
    void stripExecutionFields(QVariantMap& parameters) const;
};

} // namespace GPlatform::Parametric
