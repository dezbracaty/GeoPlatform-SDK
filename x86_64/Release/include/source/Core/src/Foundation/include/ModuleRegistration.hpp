#pragma once

#include <algorithm>
#include <mutex>
#include <string>
#include <vector>

namespace GPlatform {

using ModuleRegistration = void (*)();

struct ModuleRegistrationRecord {
    std::string key;
    ModuleRegistration callback{nullptr};
};

// One instance belongs to one module. Translation units add their callbacks
// during static initialization; the module's public entry executes them once.
class ModuleRegistrationList {
public:
    void add(const char* key, ModuleRegistration registration) {
        if (!registration) {
            return;
        }

        bool executeImmediately = false;
        {
            std::lock_guard<std::mutex> lock(m_mutex);
            if (m_executed) {
                executeImmediately = true;
            } else {
                m_registrations.push_back(
                    ModuleRegistrationRecord{key ? key : "", registration});
            }
        }
        if (executeImmediately) {
            registration();
        }
    }

    void execute() {
        std::vector<ModuleRegistrationRecord> registrations;
        {
            std::lock_guard<std::mutex> lock(m_mutex);
            if (m_executed) {
                return;
            }
            m_executed = true;
            registrations.swap(m_registrations);
        }

        std::sort(
            registrations.begin(), registrations.end(),
            [](const auto& left, const auto& right) {
                return left.key < right.key;
            });
        for (const auto& registration : registrations) {
            registration.callback();
        }
    }

private:
    std::mutex m_mutex;
    std::vector<ModuleRegistrationRecord> m_registrations;
    bool m_executed{false};
};

class ModuleRegistrationEntry {
public:
    ModuleRegistrationEntry(ModuleRegistrationList& module,
                            const char* key,
                            ModuleRegistration registration) {
        module.add(key, registration);
    }
};

} // namespace GPlatform

#define GPLATFORM_DETAIL_JOIN_IMPL(Left, Right) Left##Right
#define GPLATFORM_DETAIL_JOIN(Left, Right) GPLATFORM_DETAIL_JOIN_IMPL(Left, Right)
#define GPLATFORM_DETAIL_STRINGIFY_IMPL(Value) #Value
#define GPLATFORM_DETAIL_STRINGIFY(Value) GPLATFORM_DETAIL_STRINGIFY_IMPL(Value)

#define GPLATFORM_ADD_MODULE_REGISTRATION(ModuleAccessor, ...)                    \
    namespace {                                                                    \
    const GPlatform::ModuleRegistrationEntry GPLATFORM_DETAIL_JOIN(               \
        gplatformModuleRegistration_, __LINE__){                                  \
        ModuleAccessor(),                                                         \
        __FILE__ ":" GPLATFORM_DETAIL_STRINGIFY(__LINE__),                        \
        +[]() { __VA_ARGS__; }};                                                   \
    }
