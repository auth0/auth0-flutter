#pragma once
// Minimal stub of flutter/method_channel.h for standalone test builds.
// Provides flutter::MethodResult<T> with the same abstract interface as the
// real Flutter embedding so that plugin handler code compiles and is
// testable without the Flutter SDK being present.

#include <functional>
#include <memory>
#include <string>

namespace flutter {

template <typename T>
class MethodResult {
 public:
  virtual ~MethodResult() = default;

  // Matches the real Flutter SDK: Success(const T&) and no-arg Success().
  void Success(const T& result) {
    SuccessInternal(&result);
  }

  void Success() {
    SuccessInternal(nullptr);
  }

  void Error(const std::string& error_code,
             const std::string& error_message = "",
             const T* error_details = nullptr) {
    ErrorInternal(error_code, error_message, error_details);
  }

  void NotImplemented() {
    NotImplementedInternal();
  }

 protected:
  virtual void SuccessInternal(const T* result) = 0;
  virtual void ErrorInternal(const std::string& error_code,
                             const std::string& error_message,
                             const T* error_details) = 0;
  virtual void NotImplementedInternal() = 0;
};

}  // namespace flutter
