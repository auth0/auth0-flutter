#pragma once
// Minimal stub of flutter/encodable_value.h for standalone test builds.
// Provides EncodableValue, EncodableList, and EncodableMap with the same
// public API as the real Flutter header so that plugin code compiles and
// runs without the Flutter SDK being present.

#include <cstdint>
#include <map>
#include <string>
#include <variant>
#include <vector>

namespace flutter {

// Forward-declare so that EncodableList / EncodableMap can reference it
// before the full class definition is complete.
class EncodableValue;

using EncodableList = std::vector<EncodableValue>;
using EncodableMap  = std::map<EncodableValue, EncodableValue>;

// std::vector and std::map only need a complete element type when member
// functions are instantiated, not at the point the alias is declared.
// std::variant needs sizeof() of each alternative; sizeof(std::vector<T>)
// and sizeof(std::map<K,V>) are constant regardless of T/K/V, so the
// recursive definition is well-formed with all major C++17 compilers.
class EncodableValue
    : public std::variant<
          std::monostate,        // null
          bool,
          int32_t,
          int64_t,
          double,
          std::string,
          std::vector<uint8_t>,  // binary
          std::vector<int32_t>,
          std::vector<int64_t>,
          std::vector<double>,
          EncodableList,
          EncodableMap> {
  using Base = std::variant<
      std::monostate,
      bool,
      int32_t,
      int64_t,
      double,
      std::string,
      std::vector<uint8_t>,
      std::vector<int32_t>,
      std::vector<int64_t>,
      std::vector<double>,
      EncodableList,
      EncodableMap>;

 public:
  using Base::variant;
  using Base::operator=;

  bool IsNull() const { return std::holds_alternative<std::monostate>(*this); }

  // Required so EncodableValue can be used as a std::map key.
  // Ordering: first by variant index, then by value within the same type.
  bool operator<(const EncodableValue& other) const {
    if (index() != other.index()) return index() < other.index();
    return std::visit(
        [&other](const auto& lhs) -> bool {
          using T = std::decay_t<decltype(lhs)>;
          return lhs < std::get<T>(other);
        },
        static_cast<const Base&>(*this));
  }

  bool operator==(const EncodableValue& other) const {
    return static_cast<const Base&>(*this) == static_cast<const Base&>(other);
  }

  bool operator!=(const EncodableValue& other) const {
    return !(*this == other);
  }
};

}  // namespace flutter
