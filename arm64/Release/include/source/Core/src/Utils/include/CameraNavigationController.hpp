#pragma once

#include <SystemTypes.hpp>
#include <QPointF>
#include <QString>
#include <memory>
#include <optional>

class CameraDB;

enum class CameraPresetView {
    Front,
    Back,
    Right,
    Left,
    Bottom,
    Top,
    Isometric
};

struct CameraViewPose {
    Vector3 position;
    Vector3 target;
    Vector3 up;
    Vector3 orbitCenter;
    float horizontalAngle = 0.0f;
    float verticalAngle = 0.0f;
    float radius = 0.0f;
    bool orbitMode = false;
};

/** Immutable camera state captured when an orbit gesture begins. */
struct CameraOrbitGesture {
    QPointF pointerStart;
    Vector2 logicalViewportSize;
    Vector3 center;
    float horizontalAngle = 0.0f;
    float verticalAngle = 0.0f;
    float radius = 0.0f;

    bool isValid() const noexcept {
        return logicalViewportSize.x > 0.0f &&
               logicalViewportSize.y > 0.0f && radius > 0.0f;
    }
};

/**
 * Shared application-level camera navigation operations.
 *
 * Input handlers translate gestures into these operations, action handlers
 * translate action codes into them, and CameraBridge only exposes their
 * calculated state to QML.
 */
class CameraNavigationController {
public:
    static std::shared_ptr<CameraDB> currentCamera();

    static std::optional<CameraPresetView> presetFromAction(const QString& actionCode);
    static std::optional<CameraPresetView> presetFromOrientation(const QString& viewName);
    static std::optional<CameraViewPose> calculatePresetPose(
        CameraPresetView preset,
        std::shared_ptr<CameraDB> camera = {});

    static bool fitScene(std::shared_ptr<CameraDB> camera = {});
    static bool resetDefault(std::shared_ptr<CameraDB> camera = {});
    static bool setPreset(CameraPresetView preset,
                          std::shared_ptr<CameraDB> camera = {});
    static bool toggleProjection(std::shared_ptr<CameraDB> camera = {});

    static bool updateOrbit(const Vector3& center,
                            float horizontalAngle,
                            float verticalAngle,
                            float radius,
                            std::shared_ptr<CameraDB> camera = {});
    static bool orbitTurntable(float horizontalDelta,
                               float verticalDelta,
                               std::shared_ptr<CameraDB> camera = {});
    static std::optional<CameraOrbitGesture> beginOrbitGesture(
        const QPointF& pointerStart,
        const Vector2& logicalViewportSize,
        std::shared_ptr<CameraDB> camera = {});
    static bool orbitFromScreenDrag(
        const CameraOrbitGesture& gesture,
        const QPointF& currentPointer,
        float sensitivity = 1.0f,
        std::shared_ptr<CameraDB> camera = {});
    static bool pan(const Vector3& delta, std::shared_ptr<CameraDB> camera = {});
    static bool zoom(float scaleFactor, std::shared_ptr<CameraDB> camera = {});
    static bool zoomFromScroll(float scrollUnits,
                               float sensitivity = 1.0f,
                               std::shared_ptr<CameraDB> camera = {});
    static bool syncOrbitFromPosition(std::shared_ptr<CameraDB> camera = {});

private:
    CameraNavigationController() = delete;
};
