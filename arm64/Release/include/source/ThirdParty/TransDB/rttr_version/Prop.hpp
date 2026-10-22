#pragma once
#include <cstdint>
#include <string>
#include <string_view>
#include <typeindex>

namespace trans {

class Prop {
public:
    Prop()
        : m_typeName()
        , m_propName()
        , m_hash(computeHash(m_typeName, m_propName)) {}

    // 构造函数：使用类型索引和属性名（运行时版本）
    Prop(std::type_index type, const char* propName)
        : Prop(std::string_view(type.name()),
               std::string_view(propName != nullptr ? propName : "")) {}

    Prop(std::type_index type, std::string_view propName)
        : Prop(std::string_view(type.name()), propName) {}

    // 构造函数：使用类型名和属性名
    Prop(const char* typeName, const char* propName)
        : Prop(std::string_view(typeName != nullptr ? typeName : ""),
               std::string_view(propName != nullptr ? propName : "")) {}

    Prop(std::string_view typeName, std::string_view propName)
        : m_typeName(typeName)
        , m_propName(propName)
        , m_hash(computeHash(m_typeName, m_propName)) {}

    // 比较操作符：比较类型名和属性名
    bool operator==(const Prop& other) const {
        return m_typeName == other.m_typeName &&
               m_propName == other.m_propName;
    }

    bool operator!=(const Prop& other) const {
        return !(*this == other);
    }

    // 获取属性名
    const char* name() const { return m_propName.c_str(); }
    std::string_view nameView() const { return m_propName; }

    // 获取类型名（用于调试）
    const char* typeName() const { return m_typeName.c_str(); }
    std::string_view typeNameView() const { return m_typeName; }

    // 获取哈希值
    std::uint64_t hash() const { return m_hash; }

    // 转换为 string_view
    operator std::string_view() const {
        return nameView();
    }

private:
    static std::uint64_t computeHash(std::string_view str1, std::string_view str2) {
        std::uint64_t hash = 14695981039346656037ULL;

        for (const char ch : str1) {
            hash ^= static_cast<std::uint64_t>(static_cast<unsigned char>(ch));
            hash *= 1099511628211ULL;
        }

        hash ^= static_cast<std::uint64_t>(':');
        hash *= 1099511628211ULL;

        for (const char ch : str2) {
            hash ^= static_cast<std::uint64_t>(static_cast<unsigned char>(ch));
            hash *= 1099511628211ULL;
        }

        return hash;
    }

    std::string m_typeName;  // 类型名（值语义）
    std::string m_propName;  // 属性名（值语义）
    std::uint64_t m_hash;    // 哈希值
};

// Prop 的哈希函数（用于 unordered_map）
struct PropHash {
    std::size_t operator()(const Prop& prop) const {
        return static_cast<std::size_t>(prop.hash());
    }
};

} // namespace trans
