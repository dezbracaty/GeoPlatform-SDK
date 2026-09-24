#pragma once

#include <any>
#include <cstdint>
#include <functional>
#include <string>
#include <type_traits>
#include <typeindex>
#include <utility>
#include <vector>

#include <cereal/archives/portable_binary.hpp>
#include <cereal/types/string.hpp>
#include <cereal/types/vector.hpp>

namespace trans {

class TransDB;

using SerializedState = std::vector<std::uint8_t>;
inline constexpr char SerializedStateFormat[] =
    "transdb.cereal-portable-binary.v1";

namespace detail {

using PropertyEncoder =
    std::function<void(cereal::PortableBinaryOutputArchive&, const std::any&)>;
using PropertyDecoder =
    std::function<std::any(cereal::PortableBinaryInputArchive&)>;

void registerPropertyCodec(std::type_index type,
                           std::string stableTypeName,
                           PropertyEncoder encoder,
                           PropertyDecoder decoder);

} // namespace detail

/**
 * Registers one concrete C++ type that may be stored in a TransDB std::any.
 * The name is persisted and must remain stable across compiler versions.
 */
template <typename T>
void registerPropertyType(std::string stableTypeName)
{
    using Value = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_default_constructible_v<Value>,
                  "A registered TransDB property type must be default constructible");
    static_assert(std::is_copy_constructible_v<Value>,
                  "A registered TransDB property type must be copy constructible");

    detail::registerPropertyCodec(
        std::type_index(typeid(Value)),
        std::move(stableTypeName),
        [](cereal::PortableBinaryOutputArchive& archive, const std::any& value) {
            archive(std::any_cast<const Value&>(value));
        },
        [](cereal::PortableBinaryInputArchive& archive) -> std::any {
            Value value{};
            archive(value);
            return std::any(std::move(value));
        });
}

/** Serializes every property in TransDB's raw property store. */
SerializedState serializeState(const TransDB& db);

/**
 * Restores a state into an object with the same property schema. Validation is
 * completed before the object is changed; malformed or incompatible data
 * throws std::runtime_error.
 */
void deserializeState(TransDB& db, const SerializedState& state);

} // namespace trans
