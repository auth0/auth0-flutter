#include "time_util.h"
#include <iomanip>
#include <sstream>

std::string ToIso8601(
    const std::chrono::system_clock::time_point& tp) {
  std::time_t t = std::chrono::system_clock::to_time_t(tp);
  std::tm utc{};
  gmtime_s(&utc, &t);

  std::ostringstream oss;
  oss << std::put_time(&utc, "%Y-%m-%dT%H:%M:%SZ");
  return oss.str();
}

static std::string ToIso8601(
    const std::chrono::system_clock::time_point& tp) {
  std::time_t t = std::chrono::system_clock::to_time_t(tp);

  std::tm utc_tm{};
#if defined(_WIN32)
  gmtime_s(&utc_tm, &t);
#else
  gmtime_r(&t, &utc_tm);
#endif

  std::ostringstream oss;
  oss << std::put_time(&utc_tm, "%Y-%m-%dT%H:%M:%SZ");
  return oss.str();
}