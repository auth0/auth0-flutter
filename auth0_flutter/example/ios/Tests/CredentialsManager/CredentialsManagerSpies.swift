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

    private var storage: [String: Data] = [:]

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
