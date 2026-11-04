#pragma once

#include <BaseID.hpp>
#include <IDocumentReadView.hpp>
#include <SystemTypes.hpp>

#include <QSize>

#include <span>

namespace GPlatform::Rendering {

class IFilamentDBSync {
public:
    virtual ~IFilamentDBSync() = default;

    virtual DBInstanceID objectId() const noexcept = 0;
    virtual TypeID dbType() const noexcept = 0;
    virtual void initialize() = 0;
    virtual void applyChanges(std::span<const DocumentChange> changes) = 0;
    virtual void synchronize(const QSize& viewportSize) = 0;
    virtual void shutdown() noexcept = 0;
};

} // namespace GPlatform::Rendering
