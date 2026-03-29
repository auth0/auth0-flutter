// Reader-Writer Lock for PLUGIN_STARTUP_URL synchronization across EXE/DLL boundary.
// Multiple readers (polling threads) can access simultaneously; writers get exclusive access.

#pragma once

#include <windows.h>
#include <string>

namespace auth0_flutter
{

    constexpr const wchar_t *kPluginUrlRwLockPrefix = L"Local\\auth0flutter_startup_url_rwlock_";

    class PluginUrlReaderWriterLock
    {
    private:
        HANDLE hWriteMutex;    // Write lock (exclusive access)
        HANDLE hReaderEvent;   // Signal for reader completion

    public:
        PluginUrlReaderWriterLock()
            : hWriteMutex(nullptr), hReaderEvent(nullptr)
        {
            // Build full names for named kernel objects
            std::wstring writeMutexName = std::wstring(kPluginUrlRwLockPrefix) + L"write_mutex";
            std::wstring readerEventName = std::wstring(kPluginUrlRwLockPrefix) + L"reader_event";
            // Create or open named write mutex (non-signaled initially)
            hWriteMutex = CreateMutexW(nullptr, FALSE, writeMutexName.c_str());
            // Create or open named reader event (signaled initially, manual reset)
            hReaderEvent = CreateEventW(nullptr, TRUE, TRUE, readerEventName.c_str());
        }

        ~PluginUrlReaderWriterLock()
        {
            // Close write mutex handle if valid
            if (hWriteMutex)
                CloseHandle(hWriteMutex);
            // Close reader event handle if valid
            if (hReaderEvent)
                CloseHandle(hReaderEvent);
        }

        bool AcquireRead()
        {
            // Return false if handles not initialized
            if (!hWriteMutex || !hReaderEvent)
                return false;

            // Try to acquire write mutex with zero timeout (non-blocking check)
            DWORD waitResult = WaitForSingleObject(hWriteMutex, 0);
            if (waitResult == WAIT_OBJECT_0)
            {
                // Write lock available; release it immediately so readers can proceed
                ReleaseMutex(hWriteMutex);
                return true;
            }
            else if (waitResult == WAIT_TIMEOUT)
            {
                // Write lock held; wait indefinitely for it to be released
                waitResult = WaitForSingleObject(hWriteMutex, INFINITE);
                if (waitResult == WAIT_OBJECT_0)
                {
                    // Write lock released; release it again for next reader
                    ReleaseMutex(hWriteMutex);
                    return true;
                }
            }

            // Failed to acquire read lock
            return false;
        }

        void ReleaseRead()
        {
            // Signal reader completion via event (other readers may still hold lock)
            if (hReaderEvent)
                SetEvent(hReaderEvent);
        }

        bool AcquireWrite()
        {
            // Return false if write mutex not initialized
            if (!hWriteMutex)
                return false;

            // Acquire write mutex with infinite timeout (blocking until exclusive access)
            DWORD waitResult = WaitForSingleObject(hWriteMutex, INFINITE);
            // Return true if mutex acquired successfully
            return waitResult == WAIT_OBJECT_0;
        }

        void ReleaseWrite()
        {
            // Release write mutex so other writers or readers can acquire it
            if (hWriteMutex)
                ReleaseMutex(hWriteMutex);
        }

        bool IsValid() const
        {
            // Return true only if both handles successfully created/opened
            return hWriteMutex != nullptr && hReaderEvent != nullptr;
        }
    };

    // RAII wrapper: acquires read lock in constructor, releases in destructor
    class ReadLockGuard
    {
    private:
        PluginUrlReaderWriterLock &lock;
        bool acquired;

    public:
        // Acquire read lock on construction
        ReadLockGuard(PluginUrlReaderWriterLock &l) : lock(l), acquired(l.AcquireRead()) {}
        // Release read lock on destruction if it was acquired
        ~ReadLockGuard() { if (acquired) lock.ReleaseRead(); }
        // Return true if read lock was successfully acquired
        bool IsValid() const { return acquired; }
    };

    // RAII wrapper: acquires write lock in constructor, releases in destructor
    class WriteLockGuard
    {
    private:
        PluginUrlReaderWriterLock &lock;
        bool acquired;

    public:
        // Acquire write lock on construction
        WriteLockGuard(PluginUrlReaderWriterLock &l) : lock(l), acquired(l.AcquireWrite()) {}
        // Release write lock on destruction if it was acquired
        ~WriteLockGuard() { if (acquired) lock.ReleaseWrite(); }
        // Return true if write lock was successfully acquired
        bool IsValid() const { return acquired; }
    };

    // Get static RWLock instance. Each module (EXE/DLL) gets its own instance, but they coordinate
    // via named kernel objects, providing effective synchronization across EXE/DLL boundary.
    inline PluginUrlReaderWriterLock& GetPluginUrlRwLock()
    {
        // Static instance with lazy initialization (thread-safe in C++11)
        static PluginUrlReaderWriterLock lock;
        return lock;
    }

} // namespace auth0_flutter
