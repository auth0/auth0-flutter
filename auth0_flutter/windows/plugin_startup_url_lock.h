// Reader-Writer Lock for PLUGIN_STARTUP_URL synchronization.
// Multiple readers (polling threads) can access simultaneously; writers get exclusive access.
// Uses std::shared_mutex (C++17) for efficient reader-writer synchronization.

#pragma once

#include <windows.h>
#include <string>
#include <shared_mutex>

namespace auth0_flutter
{

    class PluginUrlReaderWriterLock
    {
    private:
        mutable std::shared_mutex rwMutex;  // Thread-safe reader-writer lock

    public:
        PluginUrlReaderWriterLock() = default;
        ~PluginUrlReaderWriterLock() = default;

        // Not copyable or movable
        PluginUrlReaderWriterLock(const PluginUrlReaderWriterLock&) = delete;
        PluginUrlReaderWriterLock& operator=(const PluginUrlReaderWriterLock&) = delete;

        bool AcquireRead() { return true; }  // Lock guards handle actual locking
        void ReleaseRead() {}                 // Lock guards handle release via RAII

        bool AcquireWrite() { return true; }  // Lock guards handle actual locking
        void ReleaseWrite() {}                // Lock guards handle release via RAII

        bool IsValid() const { return true; }

        // Provide direct access to get locks
        std::shared_mutex& GetMutex() const { return rwMutex; }
    };

    // RAII wrapper: acquires read lock in constructor, releases in destructor
    class ReadLockGuard
    {
    private:
        std::shared_lock<std::shared_mutex> guard;

    public:
        // Acquire read lock on construction
        explicit ReadLockGuard(PluginUrlReaderWriterLock& lock)
            : guard(lock.GetMutex())
        {
        }

        // Lock is automatically released when guard is destroyed
        ~ReadLockGuard() = default;

        // Not copyable or movable
        ReadLockGuard(const ReadLockGuard&) = delete;
        ReadLockGuard& operator=(const ReadLockGuard&) = delete;

        // Return true if lock guard is valid
        bool IsValid() const { return true; }
    };

    // RAII wrapper: acquires write lock in constructor, releases in destructor
    class WriteLockGuard
    {
    private:
        std::unique_lock<std::shared_mutex> guard;

    public:
        // Acquire write lock on construction
        explicit WriteLockGuard(PluginUrlReaderWriterLock& lock)
            : guard(lock.GetMutex())
        {
        }

        // Lock is automatically released when guard is destroyed
        ~WriteLockGuard() = default;

        // Not copyable or movable
        WriteLockGuard(const WriteLockGuard&) = delete;
        WriteLockGuard& operator=(const WriteLockGuard&) = delete;

        // Return true if lock guard is valid
        bool IsValid() const { return true; }
    };

    // Get static RWLock instance. Uses std::shared_mutex for thread-safe
    // reader-writer synchronization within a single process.
    inline PluginUrlReaderWriterLock& GetPluginUrlRwLock()
    {
        // Static instance with lazy initialization (thread-safe in C++11)
        static PluginUrlReaderWriterLock lock;
        return lock;
    }

} // namespace auth0_flutter
