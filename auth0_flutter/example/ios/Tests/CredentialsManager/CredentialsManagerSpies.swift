import Foundation
import Auth0

// MARK: - Auth0.swift Spies

struct SpyCredentialsStorageError: Error {}

class SpyCredentialsStorage: CredentialsStorage {
    var setEntryReturnValue = true
    var deleteEntryReturnValue = true

    var calledGetEntry = false
    var calledSetEntry = false
    var calledDeleteEntry = false

    // Backing store keyed by entry name so the credentials blob and the pinned
    // `session_expiry` value (which the manager stores under separate keys) can
    // coexist. A single-slot spy would let the second write clobber the first.
    private var storage: [String: Data] = [:]

    /// Convenience for tests that set/read the credentials blob without caring
    /// about the key, preserving the previous single-value spy API. Setting
    /// `nil` clears all entries (used to simulate "no credentials stored").
    var getEntryReturnValue: Data? {
        get { self.storage["_default"] ?? self.storage.values.first }
        set {
            if let newValue = newValue {
                self.storage["_default"] = newValue
            } else {
                self.storage.removeAll()
            }
        }
    }

    func getEntry(forKey key: String) throws -> Data {
        self.calledGetEntry = true
        // Fall back to the `_default` slot for tests that seed a value via
        // `getEntryReturnValue` without going through `setEntry`.
        guard let value = self.storage[key] ?? self.storage["_default"] else {
            throw SpyCredentialsStorageError()
        }
        return value
    }

    func setEntry(_ data: Data, forKey key: String) throws {
        self.calledSetEntry = true
        self.storage[key] = data
        if !self.setEntryReturnValue { throw SpyCredentialsStorageError() }
    }

    func deleteEntry(forKey key: String) throws {
        self.calledDeleteEntry = true
        self.storage.removeValue(forKey: key)
        if !self.deleteEntryReturnValue { throw SpyCredentialsStorageError() }
    }
}
