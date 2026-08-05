import Foundation
import Auth0

// MARK: - Auth0.swift Spies

struct SpyCredentialsStorageError: Error {}

class SpyCredentialsStorage: CredentialsStorage {
    var getEntryReturnValue: Data?
    var setEntryReturnValue = true
    var deleteEntryReturnValue = true

    var calledGetEntry = false
    var calledSetEntry = false
    var calledDeleteEntry = false

    func getEntry(forKey key: String) throws -> Data {
        self.calledGetEntry = true
        guard let value = self.getEntryReturnValue else { throw SpyCredentialsStorageError() }
        return value
    }

    func setEntry(_ data: Data, forKey key: String) throws {
        self.calledSetEntry = true
        self.getEntryReturnValue = data
        if !self.setEntryReturnValue { throw SpyCredentialsStorageError() }
    }

    func deleteEntry(forKey key: String) throws {
        self.calledDeleteEntry = true
        if !self.deleteEntryReturnValue { throw SpyCredentialsStorageError() }
    }
}
