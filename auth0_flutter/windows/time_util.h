#pragma once

#include <string>
#include <optional>
#include <chrono>

std::optional<std::chrono::system_clock::time_point>
ParseIso8601(const std::string &iso);

std::string
ToIso8601(const std::chrono::system_clock::time_point &tp);
