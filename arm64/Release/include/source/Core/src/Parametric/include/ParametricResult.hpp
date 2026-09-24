#pragma once

#include "ParametricModelTypes.hpp"

namespace GPlatform::Parametric {

inline CommandResult makeSuccessResult(const QString& modelId,
                                       qint64 prevVersion,
                                       qint64 newVersion,
                                       const QString& message = QString()) {
    CommandResult result;
    result.success = true;
    result.status = "ok";
    result.modelId = modelId;
    result.prevVersion = prevVersion;
    result.newVersion = newVersion;
    result.message = message;
    return result;
}

inline CommandResult makeErrorResult(const QString& code,
                                     const QString& message,
                                     const QString& modelId = QString()) {
    CommandResult result;
    result.success = false;
    result.status = "error";
    result.modelId = modelId;
    result.errorCode = code;
    result.message = message;
    return result;
}

inline void appendDiagnostic(CommandResult& result,
                             const QString& severity,
                             const QString& code,
                             const QString& message) {
    result.diagnostics.push_back(CommandDiagnostics{severity, code, message});
}

} // namespace GPlatform::Parametric
