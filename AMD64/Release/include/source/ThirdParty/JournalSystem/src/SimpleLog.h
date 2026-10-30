#pragma once

#include <QDebug>
#include <QDir>
#include <QStandardPaths>
#include <QTextStream>
#include <QFile>
#include <QDateTime>
#include <QMutex>

// 简单的日志类，用于JournalSystem - 遵循项目"禁用Qt调试输出"的原则
// 但保持JournalSystem作为独立第三方库的特性
class SimpleLog {
public:
    enum Level {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3
    };

    static SimpleLog& instance() {
        static SimpleLog inst;
        return inst;
    }

    void log(Level level, const QString& message) {
        QMutexLocker locker(&m_mutex);

        if (!m_file.isOpen() && !initLogFile()) {
            return; // 无法初始化日志文件，静默失败
        }

        QString levelStr;
        switch (level) {
            case DEBUG: levelStr = "DEBUG"; break;
            case INFO:  levelStr = "INFO";  break;
            case WARN:  levelStr = "WARN";  break;
            case ERROR: levelStr = "ERROR"; break;
        }

        QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
        QString logLine = QString("[%1] [%2] %3\n").arg(timestamp, levelStr, message);

        m_stream << logLine;
        m_stream.flush(); // 确保立即写入文件
    }

private:
    SimpleLog() {
        initLogFile();
    }

    bool initLogFile() {
        if (m_file.isOpen()) {
            return true;
        }

        // 使用应用数据目录，与主程序日志保持一致
        QString logDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/logs";
        QDir().mkpath(logDir);

        QString logPath = logDir + "/journal_system.log";
        m_file.setFileName(logPath);

        if (m_file.open(QIODevice::WriteOnly | QIODevice::Append)) {
            m_stream.setDevice(&m_file);
            return true;
        }

        return false;
    }

    QFile m_file;
    QTextStream m_stream;
    QMutex m_mutex;
};

// 便利宏，简化使用
#define JOURNAL_LOG_DEBUG(msg) SimpleLog::instance().log(SimpleLog::DEBUG, QString(msg))
#define JOURNAL_LOG_INFO(msg) SimpleLog::instance().log(SimpleLog::INFO, QString(msg))
#define JOURNAL_LOG_WARN(msg) SimpleLog::instance().log(SimpleLog::WARN, QString(msg))
#define JOURNAL_LOG_ERROR(msg) SimpleLog::instance().log(SimpleLog::ERROR, QString(msg))