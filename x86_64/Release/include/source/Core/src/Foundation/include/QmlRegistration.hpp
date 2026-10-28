#pragma once

#include "ModuleRegistration.hpp"

#include <QtQml/qqml.h>

#define GPLATFORM_QML_SINGLETON_REGISTRATION(                                      \
    ModuleAccessor, Uri, Major, Minor, ClassName, QmlName)                         \
    GPLATFORM_ADD_MODULE_REGISTRATION(                                             \
        ModuleAccessor,                                                            \
        qmlRegisterSingletonType<ClassName>(                                       \
            Uri, Major, Minor, QmlName,                                             \
            [](QQmlEngine* engine, QJSEngine* scriptEngine) -> QObject* {          \
                Q_UNUSED(engine)                                                   \
                Q_UNUSED(scriptEngine)                                             \
                return ClassName::getInstance();                                   \
            }))

#define GPLATFORM_QML_SINGLETON_CUSTOM_REGISTRATION(                               \
    ModuleAccessor, Uri, Major, Minor, ClassName, QmlName, Creator)                \
    GPLATFORM_ADD_MODULE_REGISTRATION(                                             \
        ModuleAccessor,                                                            \
        qmlRegisterSingletonType<ClassName>(Uri, Major, Minor, QmlName, Creator))

#define GPLATFORM_QML_TYPE_REGISTRATION(                                           \
    ModuleAccessor, Uri, Major, Minor, ClassName, QmlName)                         \
    GPLATFORM_ADD_MODULE_REGISTRATION(                                             \
        ModuleAccessor,                                                            \
        qmlRegisterType<ClassName>(Uri, Major, Minor, QmlName))
