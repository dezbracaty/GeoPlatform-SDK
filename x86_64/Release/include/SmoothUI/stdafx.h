/*!
\headerfile stdafx.h
\inmodule SmoothUI.impl
\brief Common macros and utilities for the SmoothUI implementation.

Provides core utility macros used throughout the SmoothUI codebase:
- \c SINGLETON: Thread-safe singleton pattern implementation
- \c Q_PROPERTY_AUTO: Auto-generates Q_PROPERTY with MEMBER and NOTIFY
- \c Q_PROPERTY_AUTO_P: Pointer variant of Q_PROPERTY_AUTO
- \c Q_PROPERTY_READONLY_AUTO: Read-only auto property
- \c Q_PROPERTY_READONLY_AUTO_P: Read-only pointer auto property
*/
#pragma once

template <typename T>
class Singleton
{
public:
    static T *getInstance();
};

template <typename T>
T *Singleton<T>::getInstance() {
    static T *instance = new T();
    return instance;
}

#define SINGLETON(Class)                                                                           \
private:                                                                                           \
    friend class Singleton<Class>;                                                                 \
                                                                                                   \
public:                                                                                            \
    static Class *getInstance() {                                                                  \
        return Singleton<Class>::getInstance();                                                    \
    }

//! \brief Defines a Q_PROPERTY with a pointer-typed MEMBER, a setter, and a NOTIFY signal.
#define Q_PROPERTY_AUTO_P(TYPE, M)                                                                 \
    Q_PROPERTY(TYPE M MEMBER m_##M NOTIFY M##Changed)                                              \
public:                                                                                            \
    Q_SIGNAL void M##Changed();                                                                    \
    void M(TYPE in_##M) {                                                                          \
        if (in_##M == m_##M)                                                                       \
            return;                                                                                \
        m_##M = in_##M;                                                                            \
        Q_EMIT M##Changed();                                                                       \
    }                                                                                              \
    TYPE M() const {                                                                               \
        return m_##M;                                                                              \
    }                                                                                              \
                                                                                                   \
private:                                                                                           \
    TYPE m_##M = nullptr;

//! \brief Defines a read-only Q_PROPERTY with a pointer-typed getter and a NOTIFY signal.
#define Q_PROPERTY_READONLY_AUTO_P(TYPE, M)                                                        \
    Q_PROPERTY(TYPE M READ M NOTIFY M##Changed FINAL)                                              \
public:                                                                                            \
    Q_SIGNAL void M##Changed();                                                                    \
    void M(TYPE in_##M) {                                                                          \
        if (in_##M == m_##M)                                                                       \
            return;                                                                                \
        m_##M = in_##M;                                                                            \
        Q_EMIT M##Changed();                                                                       \
    }                                                                                              \
    TYPE M() const {                                                                               \
        return m_##M;                                                                              \
    }                                                                                              \
                                                                                                   \
private:                                                                                           \
    TYPE m_##M = nullptr;

//! \brief Defines a Q_PROPERTY with a MEMBER, a setter, and a NOTIFY signal.
#define Q_PROPERTY_AUTO(TYPE, M)                                                                   \
    Q_PROPERTY(TYPE M MEMBER m_##M NOTIFY M##Changed)                                              \
public:                                                                                            \
    Q_SIGNAL void M##Changed();                                                                    \
    void M(const TYPE &in_##M) {                                                                   \
        if (in_##M == m_##M)                                                                       \
            return;                                                                                \
        m_##M = in_##M;                                                                            \
        Q_EMIT M##Changed();                                                                       \
    }                                                                                              \
    TYPE M() const {                                                                               \
        return m_##M;                                                                              \
    }                                                                                              \
                                                                                                   \
private:                                                                                           \
    TYPE m_##M;

//! \brief Defines a read-only Q_PROPERTY with a getter and a NOTIFY signal.
#define Q_PROPERTY_READONLY_AUTO(TYPE, M)                                                          \
    Q_PROPERTY(TYPE M READ M NOTIFY M##Changed FINAL)                                              \
public:                                                                                            \
    Q_SIGNAL void M##Changed();                                                                    \
    void M(const TYPE &in_##M) {                                                                   \
        if (in_##M == m_##M)                                                                       \
            return;                                                                                \
        m_##M = in_##M;                                                                            \
        Q_EMIT M##Changed();                                                                       \
    }                                                                                              \
    TYPE M() const {                                                                               \
        return m_##M;                                                                              \
    }                                                                                              \
                                                                                                   \
private:                                                                                           \
    TYPE m_##M;
