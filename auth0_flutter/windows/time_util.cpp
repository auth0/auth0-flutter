#include "time_util.h"

#include <iomanip>
#include <sstream>
#include <ctime>

std::optional<std::chrono::system_clock::time_point>
ParseIso8601(const std::string &iso)
{
  if (iso.empty())
  {
    return std::nullopt;
  }

  std::tm tm{};
  std::istringstream ss(iso);
  ss >> std::get_time(&tm, "%Y-%m-%dT%H:%M:%SZ");

  if (ss.fail())
  {
    return std::nullopt;
  }

#if defined(_WIN32)
  std::time_t t = _mkgmtime(&tm); // Windows UTC
#else
  std::time_t t = timegm(&tm); // POSIX UTC
#endif

  return std::chrono::system_clock::from_time_t(t);
}

std::string
ToIso8601(const std::chrono::system_clock::time_point &tp)
{
  std::time_t t = std::chrono::system_clock::to_time_t(tp);
  std::tm tm{};

#if defined(_WIN32)
  gmtime_s(&tm, &t);
#else
  gmtime_r(&t, &tm);
#endif

  std::ostringstream ss;
  ss << std::put_time(&tm, "%Y-%m-%dT%H:%M:%SZ");
  return ss.str();
}
