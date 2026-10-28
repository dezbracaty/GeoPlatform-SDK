#ifndef JOURNALENTRY_H
#define JOURNALENTRY_H

#include "JournalSystem_global.h"

#include <QEvent>
#include <QJsonObject>
#include <QString>

class QObject;

enum class JournalEntryKind {
    MouseInput,
    KeyInput,
    PointerInput,
    WheelInput,
    DragDropInput,
    CloseInput,
    Action
};

struct JOURNALSYSTEM_EXPORT JournalEntry {
    qint64 atMs{0};
    qint64 sequence{0};
    JournalEntryKind kind{JournalEntryKind::MouseInput};
    QJsonObject payload;
};

JOURNALSYSTEM_EXPORT QString journalEntryKindName(JournalEntryKind kind);

// Strict Journal v2 entry codec. Entries without kind/atMs/payload are invalid.
JOURNALSYSTEM_EXPORT bool parseJournalEntry(
    const QJsonObject& object,
    JournalEntry* entry,
    QString* error = nullptr);

JOURNALSYSTEM_EXPORT QJsonObject serializeJournalEntry(const JournalEntry& entry);

// Converts one physical Qt input event into the strict Journal v2 shape.
JOURNALSYSTEM_EXPORT bool recordJournalInput(
    QObject* target,
    QEvent* event,
    qint64 atMs,
    qint64 sequence,
    JournalEntry* entry,
    QString* error = nullptr);

#endif // JOURNALENTRY_H
