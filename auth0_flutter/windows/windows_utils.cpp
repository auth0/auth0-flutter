/**
 * @file windows_utils.cpp
 * @brief Implementation of Windows-specific utilities
 */

#include "windows_utils.h"
#include <windows.h>

namespace auth0_flutter
{

    std::string WideToUtf8(const std::wstring &wstr)
    {
        if (wstr.empty())
            return {};
        int size_needed = ::WideCharToMultiByte(CP_UTF8, 0, wstr.data(),
                                                (int)wstr.size(), nullptr, 0, nullptr, nullptr);
        if (size_needed <= 0)
            return {};
        std::string str(size_needed, 0);
        ::WideCharToMultiByte(CP_UTF8, 0, wstr.data(), (int)wstr.size(), &str[0], size_needed, nullptr, nullptr);
        return str;
    }

    void BringFlutterWindowToFront()
    {
        HWND hwnd = GetActiveWindow();

        if (!hwnd)
        {
            hwnd = GetForegroundWindow();
        }

        if (!hwnd)
            return;

        // Restore if minimized
        if (IsIconic(hwnd))
        {
            ShowWindow(hwnd, SW_RESTORE);
        }

        // Required trick to bypass foreground lock
        DWORD currentThread = GetCurrentThreadId();
        DWORD foregroundThread = GetWindowThreadProcessId(GetForegroundWindow(), NULL);

        AttachThreadInput(foregroundThread, currentThread, TRUE);

        SetForegroundWindow(hwnd);
        SetFocus(hwnd);
        SetActiveWindow(hwnd);

        AttachThreadInput(foregroundThread, currentThread, FALSE);
    }

    void DebugPrint(const std::string &msg)
    {
        OutputDebugStringA((msg + "\n").c_str());
    }

} // namespace auth0_flutter
