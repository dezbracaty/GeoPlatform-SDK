#pragma once

#include <QString>

namespace GPlatform::Parametric::CommandNames {

inline const QString& graphCreate() {
    static const QString kValue = QStringLiteral("parametric.graph.create");
    return kValue;
}

inline const QString& graphUpdateParameter() {
    static const QString kValue = QStringLiteral("parametric.graph.update_parameter");
    return kValue;
}

inline const QString& graphUndo() {
    static const QString kValue = QStringLiteral("parametric.graph.undo");
    return kValue;
}

inline const QString& graphRedo() {
    static const QString kValue = QStringLiteral("parametric.graph.redo");
    return kValue;
}

inline const QString& graphHistory() {
    static const QString kValue = QStringLiteral("parametric.graph.history");
    return kValue;
}

inline const QString& graphPreview() {
    static const QString kValue = QStringLiteral("parametric.graph.preview");
    return kValue;
}

inline const QString& irValidate() {
    static const QString kValue = QStringLiteral("parametric.ir.validate");
    return kValue;
}

inline const QString& capabilityList() {
    static const QString kValue = QStringLiteral("parametric.capability.list");
    return kValue;
}

inline const QString& capabilityDescribe() {
    static const QString kValue = QStringLiteral("parametric.capability.describe");
    return kValue;
}

inline QString canonicalActionType(const QString& actionType) {
    return actionType.trimmed();
}

inline QString canonicalQueryType(const QString& queryType) {
    return queryType.trimmed();
}

inline bool isParametricActionType(const QString& actionType) {
    const QString canonical = canonicalActionType(actionType);
    return canonical == graphCreate() ||
           canonical == graphUpdateParameter() ||
           canonical == graphUndo() ||
           canonical == graphRedo() ||
           canonical == graphHistory() ||
           canonical == graphPreview() ||
           canonical == irValidate();
}

} // namespace GPlatform::Parametric::CommandNames
