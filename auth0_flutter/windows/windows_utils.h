/**
 * @file windows_utils.h
 * @brief Windows-specific utility functions
 */

#pragma once

#include <string>

namespace auth0_flutter
{

    /**
     * @brief Converts wide string (wchar_t) to UTF-8
     *
     * Safely converts Windows wide strings to UTF-8 encoded strings.
     */
    std::string WideToUtf8(const std::wstring &wstr);

    /**
     * @brief Brings the Flutter window to the foreground
     *
     * After the user completes authentication in the browser, this function
     * brings the Flutter app window back to focus.
     */
    void BringFlutterWindowToFront();

    /**
     * @brief Debug logging utility
     *
     * Prints debug messages to the Visual Studio Output window using
     * OutputDebugString.
     */
    void DebugPrint(const std::string &msg);

} // namespace auth0_flutter
