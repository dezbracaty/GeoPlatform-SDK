#pragma once

#include <QtCore/qstring.h>
#include <QtCore/qfile.h>
#include <QMutex>
#include <memory>
#include <string>
#include <unordered_map>
#include <chrono>
#include <spdlog/spdlog.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/sinks/rotating_file_sink.h>

// 日志级别枚举
enum class LogLevel : int {
    Trace = 0,
    Debug = 1,
    Info = 2,
    Warning = 3,
    Error = 4,
    Critical = 5,
    Off = 6
};

class Log {
public:
    // 保持原有接口
    static void setup(char* argv[], const QString& app, int level = 4);

    // 新增功能：单例模式获取实例
    static Log& instance();

    // 新增功能：关闭日志系统
    static void shutdown();

    // 新增功能：设置日志级别
    static void setLevel(LogLevel level);
    static void setLevel(const std::string& levelStr);
    static LogLevel getLevel();

    // 新增功能：强制刷新日志
    static void flush();

    // 新增功能：启用/禁用控制台输出
    static void enableConsoleOutput(bool enable);
    static void enableFileOutput(bool enable);

    // 新增功能：性能敏感的日志 - 频率控制
    template <typename... Args>
    static void logEveryN(int n, spdlog::level::level_enum level,
                          const std::string& fmt, Args&&... args) {
        static std::unordered_map<std::string, int> counters;
        static QMutex counterMutex;

        QMutexLocker locker(&counterMutex);
        if (++counters[fmt] % n == 1) {
            spdlog::log(level, fmt, std::forward<Args>(args)...);
        }
    }

    // 新增功能：性能敏感的日志 - 时间节流
    template <typename... Args>
    static void logThrottled(int milliseconds, spdlog::level::level_enum level,
                             const std::string& fmt, Args&&... args) {
        using TimePoint = std::chrono::steady_clock::time_point;
        static std::unordered_map<std::string, TimePoint> timestamps;
        static QMutex timestampMutex;

        auto now = std::chrono::steady_clock::now();

        QMutexLocker locker(&timestampMutex);
        auto& last = timestamps[fmt];

        if (std::chrono::duration_cast<std::chrono::milliseconds>(now - last).count() >= milliseconds) {
            last = now;
            spdlog::log(level, fmt, std::forward<Args>(args)...);
        }
    }

    // 新增功能：获取统计信息
    struct Statistics {
        uint64_t totalLogs = 0;
        uint64_t traceLogs = 0;
        uint64_t debugLogs = 0;
        uint64_t infoLogs = 0;
        uint64_t warnLogs = 0;
        uint64_t errorLogs = 0;
        uint64_t criticalLogs = 0;
    };
    static Statistics getStatistics();
    // 保留原有的静态成员（向后兼容）
    static QString g_app;
    static QString g_file_path;
    static bool g_logError;
    static std::unique_ptr<QFile> g_logFile;
    static std::unique_ptr<QTextStream> g_logStream;
    static int g_logLevel;
    static std::map<QtMsgType, int> g_logLevelMap;
    static QMutex g_logMutex;

    // 新增的spdlog相关成员
    static bool g_initialized;
    static std::shared_ptr<spdlog::logger> g_logger;
    static std::shared_ptr<spdlog::sinks::stdout_color_sink_mt> g_consoleSink;
    static std::shared_ptr<spdlog::sinks::rotating_file_sink_mt> g_fileSink;
    static Statistics g_stats;
    static QMutex g_statsMutex;
    // Qt消息处理器（增强版）
    static void messageHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg);

private:
    // 原有的私有方法
    static QString readBisoValueFromReg(const QString& key);

public:
    // 系统信息方法改为public（从Logger迁移）
    static QString getSystemManufacturer();
    static QString prettyProductInfoWrapper();
    static QString getDeviceId();
    static QString getCpuArchitecture();
    static int getProcessId();

private:
    // 新增的私有方法
    static void configureFromEnvironment();
    static std::string getLogDirectory(const char* argv0);
    static bool createLogDirectory(const std::string& path);
    static spdlog::level::level_enum toSpdlogLevel(LogLevel level);
    static LogLevel fromSpdlogLevel(spdlog::level::level_enum level);
};

// 日志宏定义（从Logger迁移）
// 修复：在日志系统未初始化时安全地忽略日志调用
#define LOG_TRACE(...)    do { if (Log::g_initialized && spdlog::default_logger()) { SPDLOG_TRACE(__VA_ARGS__); } } while(0)
#define LOG_DEBUG(...)    do { if (Log::g_initialized && spdlog::default_logger()) { SPDLOG_DEBUG(__VA_ARGS__); } } while(0)
#define LOG_INFO(...)     do { if (Log::g_initialized && spdlog::default_logger()) { SPDLOG_INFO(__VA_ARGS__); } } while(0)
#define LOG_WARN(...)     do { if (Log::g_initialized && spdlog::default_logger()) { SPDLOG_WARN(__VA_ARGS__); } } while(0)
#define LOG_ERROR(...)    do { if (Log::g_initialized && spdlog::default_logger()) { SPDLOG_ERROR(__VA_ARGS__); } } while(0)
#define LOG_CRITICAL(...) do { if (Log::g_initialized && spdlog::default_logger()) { SPDLOG_CRITICAL(__VA_ARGS__); } } while(0)

// 频率控制的日志宏
#define LOG_DEBUG_EVERY_N(n, ...) Log::logEveryN(n, spdlog::level::debug, __VA_ARGS__)
#define LOG_INFO_EVERY_N(n, ...)  Log::logEveryN(n, spdlog::level::info, __VA_ARGS__)
#define LOG_WARN_EVERY_N(n, ...)  Log::logEveryN(n, spdlog::level::warn, __VA_ARGS__)
#define LOG_ERROR_EVERY_N(n, ...) Log::logEveryN(n, spdlog::level::err, __VA_ARGS__)

// 时间节流的日志宏
#define LOG_DEBUG_THROTTLED(ms, ...) Log::logThrottled(ms, spdlog::level::debug, __VA_ARGS__)
#define LOG_INFO_THROTTLED(ms, ...)  Log::logThrottled(ms, spdlog::level::info, __VA_ARGS__)
#define LOG_WARN_THROTTLED(ms, ...)  Log::logThrottled(ms, spdlog::level::warn, __VA_ARGS__)
#define LOG_ERROR_THROTTLED(ms, ...) Log::logThrottled(ms, spdlog::level::err, __VA_ARGS__)

// 安全日志宏（用于析构函数）
#define LOG_SAFE(...)              \
    do {                           \
        try {                      \
            LOG_INFO(__VA_ARGS__); \
        } catch (...) {            \
        }                          \
    } while (0)

// 渲染相关的日志宏（用于VTK渲染）
#ifdef GP_LOG_RENDER
#define LOG_RENDER(...) LOG_DEBUG(__VA_ARGS__)
#else
#define LOG_RENDER(...) \
    do {                \
    } while (0)
#endif

// 性能相关的日志宏
#ifdef GP_LOG_PERF
#define LOG_PERF(...) LOG_DEBUG(__VA_ARGS__)
#else
#define LOG_PERF(...) \
    do {              \
    } while (0)
#endif

// 性能测量类
class ScopedTimer {
public:
    explicit ScopedTimer(const std::string& name)
        : m_name(name), m_start(std::chrono::high_resolution_clock::now()) {
    }

    ~ScopedTimer() {
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - m_start).count();
        LOG_DEBUG("{} took {} ms", m_name, duration);
    }

private:
    std::string m_name;
    std::chrono::time_point<std::chrono::high_resolution_clock> m_start;
};

#define SCOPED_TIMER(name) ScopedTimer timer##__LINE__(name)
