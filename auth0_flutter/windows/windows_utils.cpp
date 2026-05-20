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
        // GetActiveWindow() only returns windows on the calling thread's message
        // queue. Since this runs on a background pplx worker thread it always
        // returns NULL. Instead, enumerate all top-level windows that belong to
        // this process to find the Flutter window.
        struct FindData
        {
            DWORD pid;
            HWND hwnd;
        };
        FindData findData = {GetCurrentProcessId(), nullptr};

        EnumWindows(
            [](HWND candidate, LPARAM lp) -> BOOL
            {
                auto *data = reinterpret_cast<FindData *>(lp);
                DWORD windowPid = 0;
                GetWindowThreadProcessId(candidate, &windowPid);
                if (windowPid == data->pid &&
                    IsWindowVisible(candidate) &&
                    GetParent(candidate) == nullptr)
                {
                    data->hwnd = candidate;
                    return FALSE; // stop enumeration
                }
                return TRUE;
            },
            reinterpret_cast<LPARAM>(&findData));

        HWND hwnd = findData.hwnd;
        if (!hwnd)
            return;

        // Restore if minimized
        if (IsIconic(hwnd))
        {
            ShowWindow(hwnd, SW_RESTORE);
        }

        // Required trick to bypass foreground lock.
        // AttachThreadInput lets us steal focus from the current foreground owner.
        DWORD currentThread = GetCurrentThreadId();
        HWND fgWnd = GetForegroundWindow();
        DWORD foregroundThread = fgWnd
            ? GetWindowThreadProcessId(fgWnd, nullptr)
            : 0;

        // Only attach if there is a valid foreground thread different from ours.
        // GetForegroundWindow() returns NULL when the desktop is locked or a UAC
        // prompt is active — calling AttachThreadInput(0, …) is undefined.
        bool attached = false;
        if (foregroundThread != 0 && foregroundThread != currentThread)
        {
            attached = (AttachThreadInput(foregroundThread, currentThread, TRUE) != 0);
        }

        SetForegroundWindow(hwnd);
        SetFocus(hwnd);
        SetActiveWindow(hwnd);

        if (attached)
        {
            AttachThreadInput(foregroundThread, currentThread, FALSE);
        }
    }

} // namespace auth0_flutter
