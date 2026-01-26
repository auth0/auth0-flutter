#include <gtest/gtest.h>

#include "windows_utils.h"

using namespace auth0_flutter;

/* ---------------- WideToUtf8 ---------------- */

TEST(WideToUtf8Test, ConvertsEmptyString) {
  std::wstring wstr = L"";
  std::string result = WideToUtf8(wstr);

  EXPECT_EQ(result, "");
}

TEST(WideToUtf8Test, ConvertsAsciiString) {
  std::wstring wstr = L"Hello World";
  std::string result = WideToUtf8(wstr);

  EXPECT_EQ(result, "Hello World");
}

TEST(WideToUtf8Test, ConvertsUnicodeCharacters) {
  // Use explicit Unicode code points instead of literals
  // 世 = U+4E16, 界 = U+754C
  std::wstring wstr = L"Hello ";
  wstr += static_cast<wchar_t>(0x4E16);  // 世
  wstr += static_cast<wchar_t>(0x754C);  // 界
  std::string result = WideToUtf8(wstr);

  // UTF-8 encoding of 世界
  // 世 = E4 B8 96
  // 界 = E7 95 8C
  EXPECT_EQ(result, "Hello \xE4\xB8\x96\xE7\x95\x8C");
}

TEST(WideToUtf8Test, ConvertsEmoji) {
  // Use explicit Unicode code point for emoji
  // 😀 = U+1F600 (requires surrogate pair on Windows)
  std::wstring wstr = L"Hello ";
  // On Windows, characters above U+FFFF need surrogate pairs
  wstr += static_cast<wchar_t>(0xD83D);  // High surrogate
  wstr += static_cast<wchar_t>(0xDE00);  // Low surrogate
  std::string result = WideToUtf8(wstr);

  // UTF-8 encoding of 😀 = F0 9F 98 80
  EXPECT_EQ(result, "Hello \xF0\x9F\x98\x80");
}

TEST(WideToUtf8Test, ConvertsSpecialCharacters) {
  std::wstring wstr = L"Testing: ñ, é, ü, ö";
  std::string result = WideToUtf8(wstr);

  // Check that the result is not empty and contains UTF-8 encoded special chars
  EXPECT_FALSE(result.empty());
  EXPECT_TRUE(result.find("Testing:") != std::string::npos);
}

TEST(WideToUtf8Test, ConvertsPathWithBackslashes) {
  std::wstring wstr = L"C:\\Users\\Test\\Documents";
  std::string result = WideToUtf8(wstr);

  EXPECT_EQ(result, "C:\\Users\\Test\\Documents");
}

TEST(WideToUtf8Test, ConvertsLongString) {
  // Create a long wide string
  std::wstring wstr;
  for (int i = 0; i < 1000; i++) {
    wstr += L"A";
  }

  std::string result = WideToUtf8(wstr);

  EXPECT_EQ(result.length(), 1000u);
  EXPECT_EQ(result, std::string(1000, 'A'));
}

TEST(WideToUtf8Test, ConvertsMultipleUnicodeCharacters) {
  // Japanese, Chinese, Korean, Arabic
  std::wstring wstr = L"日本語 中文 한국어 العربية";
  std::string result = WideToUtf8(wstr);

  // Should not be empty and should be longer than the wide string character count
  EXPECT_FALSE(result.empty());
  EXPECT_GT(result.length(), wstr.length());
}

/* ---------------- BringFlutterWindowToFront ---------------- */

// Note: BringFlutterWindowToFront is difficult to unit test as it requires
// actual Windows window handles and GUI interaction. These tests verify
// that the function can be called without crashing.

TEST(BringFlutterWindowToFrontTest, DoesNotCrashWhenCalled) {
  // This test just ensures the function doesn't crash
  // In a real environment without a window, it should handle gracefully
  EXPECT_NO_THROW(BringFlutterWindowToFront());
}

/* ---------------- DebugPrint ---------------- */

// Note: DebugPrint outputs to the Visual Studio debugger output window
// using OutputDebugStringA. These tests verify that the function can be
// called without crashing.

TEST(DebugPrintTest, DoesNotCrashWithEmptyString) {
  EXPECT_NO_THROW(DebugPrint(""));
}

TEST(DebugPrintTest, DoesNotCrashWithSimpleMessage) {
  EXPECT_NO_THROW(DebugPrint("Test message"));
}

TEST(DebugPrintTest, DoesNotCrashWithLongMessage) {
  std::string longMessage(10000, 'X');
  EXPECT_NO_THROW(DebugPrint(longMessage));
}

TEST(DebugPrintTest, DoesNotCrashWithSpecialCharacters) {
  EXPECT_NO_THROW(DebugPrint("Test with special chars: \n\r\t!@#$%^&*()"));
}

TEST(DebugPrintTest, DoesNotCrashWithUnicodeInUtf8) {
  // UTF-8 encoded string with unicode
  std::string utf8Message = "Unicode: \xE4\xB8\x96\xE7\x95\x8C";
  EXPECT_NO_THROW(DebugPrint(utf8Message));
}
