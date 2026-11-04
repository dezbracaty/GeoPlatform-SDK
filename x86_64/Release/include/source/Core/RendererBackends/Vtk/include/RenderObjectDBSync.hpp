#pragma once

#include "IDBSync.hpp"

#include <atomic>
#include <cstdint>
#include <memory>

class vtkProp;

// Base class for DBSync implementations whose renderer-facing root is a generic vtkProp rather than
// specifically a vtkActor. The root may be a vtkAssembly that owns several renderable children.
// Renderer membership, global visibility and graphics-resource lifetime are centralized here.
class RenderObjectDBSync : public IDBSync,
                           public std::enable_shared_from_this<RenderObjectDBSync> {
public:
    void initialize(
        const DBInstanceID& id,
        vtkSmartPointer<vtkRenderer> renderer,
        std::shared_ptr<RenderThread> renderThread) override final;

    void cleanup(const DBInstanceID& id) override final;
    void setVisible(bool visible) override final;

    vtkSmartPointer<vtkObject> getPrimaryVTKObject() const override final;
    vtkSmartPointer<vtkProp> getVTKProp() const override final;
    bool ownsProp(vtkSmartPointer<vtkProp> prop) const override final;

    // Custom render objects must explicitly opt in and implement their own context semantics.
    bool needsRenderingContext() const override { return false; }

protected:
    virtual void createRenderObjects() = 0;
    virtual vtkSmartPointer<vtkProp> rootProp() const = 0;
    virtual bool ownsChildProp(vtkProp* prop) const { return false; }
    virtual void releaseRenderObjects() = 0;
    virtual void onRenderObjectsCreated() {}

    // Synchronize ActorDB::Transform to the renderer-facing root vtkProp3D. A composite root such
    // as vtkAssembly propagates this one transform to every child actor.
    void syncTransformFromDB();

    std::uint64_t generation() const { return m_generation.load(std::memory_order_acquire); }
    bool isGenerationActive(std::uint64_t token) const {
        return m_active.load(std::memory_order_acquire) &&
               m_generation.load(std::memory_order_acquire) == token;
    }
    bool isActive() const { return m_active.load(std::memory_order_acquire); }

private:
    std::atomic_bool m_active{false};
    std::atomic_uint64_t m_generation{0};
};
