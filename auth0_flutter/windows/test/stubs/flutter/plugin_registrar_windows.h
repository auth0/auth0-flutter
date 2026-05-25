#pragma once
// Minimal stub of flutter/plugin_registrar_windows.h for standalone test builds.
// Provides flutter::TaskRunner with the same interface as the real Flutter
// embedding so that plugin handler code compiles without the Flutter SDK.

#include <functional>

namespace flutter {

class TaskRunner {
 public:
  virtual ~TaskRunner() = default;
  virtual void PostTask(std::function<void()> task) = 0;
};

}  // namespace flutter
