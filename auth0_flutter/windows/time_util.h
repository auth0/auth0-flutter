#pragma once
#include <string>
#include <chrono>

std::string ToIso8601(
    const std::chrono::system_clock::time_point& tp);
