#include <gtest/gtest.h>

#include "time_util.h"
#include <chrono>

/* ---------------- ParseIso8601 ---------------- */

TEST(ParseIso8601Test, ParsesValidIso8601String) {
  std::string iso = "2023-12-25T10:30:45Z";
  auto result = ParseIso8601(iso);

  ASSERT_TRUE(result.has_value());

  // Convert back to verify
  std::string roundtrip = ToIso8601(result.value());
  EXPECT_EQ(roundtrip, iso);
}

TEST(ParseIso8601Test, ParsesEpochTime) {
  std::string iso = "1970-01-01T00:00:00Z";
  auto result = ParseIso8601(iso);

  ASSERT_TRUE(result.has_value());

  std::time_t t = std::chrono::system_clock::to_time_t(result.value());
  EXPECT_EQ(t, 0);
}

TEST(ParseIso8601Test, ReturnsNulloptForEmptyString) {
  std::string iso = "";
  auto result = ParseIso8601(iso);

  EXPECT_FALSE(result.has_value());
}

TEST(ParseIso8601Test, ReturnsNulloptForInvalidFormat) {
  std::string iso = "invalid-date";
  auto result = ParseIso8601(iso);

  EXPECT_FALSE(result.has_value());
}

TEST(ParseIso8601Test, ReturnsNulloptForPartialDate) {
  std::string iso = "2023-12-25";
  auto result = ParseIso8601(iso);

  EXPECT_FALSE(result.has_value());
}

TEST(ParseIso8601Test, ParsesDifferentDatesCorrectly) {
  std::string iso1 = "2020-01-15T08:00:00Z";
  std::string iso2 = "2025-06-30T23:59:59Z";

  auto result1 = ParseIso8601(iso1);
  auto result2 = ParseIso8601(iso2);

  ASSERT_TRUE(result1.has_value());
  ASSERT_TRUE(result2.has_value());

  // Verify result2 is after result1
  EXPECT_TRUE(result2.value() > result1.value());
}

/* ---------------- ToIso8601 ---------------- */

TEST(ToIso8601Test, FormatsTimePointCorrectly) {
  // Create a known time point
  std::tm tm{};
  tm.tm_year = 2023 - 1900;  // years since 1900
  tm.tm_mon = 11;             // December (0-based)
  tm.tm_mday = 25;
  tm.tm_hour = 10;
  tm.tm_min = 30;
  tm.tm_sec = 45;

  #if defined(_WIN32)
    std::time_t t = _mkgmtime(&tm);
  #else
    std::time_t t = timegm(&tm);
  #endif

  auto tp = std::chrono::system_clock::from_time_t(t);
  std::string result = ToIso8601(tp);

  EXPECT_EQ(result, "2023-12-25T10:30:45Z");
}

TEST(ToIso8601Test, FormatsEpochCorrectly) {
  auto epoch = std::chrono::system_clock::from_time_t(0);
  std::string result = ToIso8601(epoch);

  EXPECT_EQ(result, "1970-01-01T00:00:00Z");
}

TEST(ToIso8601Test, HandlesLeapYear) {
  std::tm tm{};
  tm.tm_year = 2020 - 1900;  // Leap year
  tm.tm_mon = 1;              // February
  tm.tm_mday = 29;            // 29th (valid in leap year)
  tm.tm_hour = 12;
  tm.tm_min = 0;
  tm.tm_sec = 0;

  #if defined(_WIN32)
    std::time_t t = _mkgmtime(&tm);
  #else
    std::time_t t = timegm(&tm);
  #endif

  auto tp = std::chrono::system_clock::from_time_t(t);
  std::string result = ToIso8601(tp);

  EXPECT_EQ(result, "2020-02-29T12:00:00Z");
}

/* ---------------- Round-trip tests ---------------- */

TEST(TimeUtilRoundTripTest, ParseAndFormatAreInverses) {
  std::string original = "2024-07-15T14:30:00Z";

  auto parsed = ParseIso8601(original);
  ASSERT_TRUE(parsed.has_value());

  std::string formatted = ToIso8601(parsed.value());
  EXPECT_EQ(formatted, original);
}

TEST(TimeUtilRoundTripTest, FormatAndParseAreInverses) {
  auto now = std::chrono::system_clock::now();

  std::string formatted = ToIso8601(now);
  auto parsed = ParseIso8601(formatted);

  ASSERT_TRUE(parsed.has_value());

  // Time should match (within a second due to formatting precision)
  auto diff = std::chrono::duration_cast<std::chrono::seconds>(
      now - parsed.value()).count();

  EXPECT_LE(std::abs(diff), 1);
}
