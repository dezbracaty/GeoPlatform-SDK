#pragma once

#include <string>
#include <cstdint>

namespace trans {

    /**
     * @brief 数据库实例 ID
     */
    class DBInstanceID {
    public:
        DBInstanceID() : m_value(0) {
        }
        explicit DBInstanceID(std::int64_t value) : m_value(value) {
        }

        std::int64_t getValue() const {
            return m_value;
        }
        bool isValid() const {
            return m_value != 0;
        }

        static DBInstanceID generate() {
            static std::int64_t counter = 1;
            return DBInstanceID(counter++);
        }

        bool operator==(const DBInstanceID& other) const {
            return m_value == other.m_value;
        }

    private:
        std::int64_t m_value;
    };

    /**
     * @brief 类型 ID
     */
    class TypeID {
    public:
        TypeID() : m_value(0) {
        }
        explicit TypeID(uint32_t value) : m_value(value) {
        }

        uint32_t getValue() const {
            return m_value;
        }
        bool isValid() const {
            return m_value != 0;
        }

        bool operator==(const TypeID& other) const {
            return m_value == other.m_value;
        }

    private:
        uint32_t m_value;
    };

} // namespace trans
