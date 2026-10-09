#pragma once

#include <QString>

namespace GPlatform::Parametric::ParametricErrors {

inline const QString kUnknownCommand = "E1000";
inline const QString kExpectedVersionMismatch = "E1100";
inline const QString kNestedTransactionNotAllowed = "E1200";
inline const QString kExpressionEvaluationFailed = "E2100";
inline const QString kValidationFailed = "E2200";
inline const QString kSchemaValidationFailed = "E2210";
inline const QString kSemanticValidationFailed = "E2220";
inline const QString kCapabilityValidationFailed = "E2230";
inline const QString kPolicyValidationFailed = "E2240";
inline const QString kFeatureBuildFailed = "E2300";
inline const QString kTessellationFailed = "E2400";
inline const QString kVersionCommitFailed = "E2500";

inline const QString kFilletDeferredWarning = "W3100";
inline const QString kOccDeferredWarning = "W3200";

} // namespace GPlatform::Parametric::ParametricErrors
