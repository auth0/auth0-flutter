import Auth0

// MARK: - Auth0.swift Spies

class SpyCredentialsStorage: CredentialsStorage {
    var getEntryReturnValue: Data?
    var setEntryReturnValue = true
    var deleteEntryReturnValue = true

    var calledGetEntry = false
    var calledSetEntry = false
    var calledDeleteEntry = false

    func getEntry(forKey key: String) -> Data? {
        self.calledGetEntry = true
        return self.getEntryReturnValue
    }

    func setEntry(_ data: Data, forKey key: String) -> Bool {
        self.calledSetEntry = true
        return self.setEntryReturnValue
    }

    func deleteEntry(forKey key: String) -> Bool {
        self.calledDeleteEntry = true
        return self.deleteEntryReturnValue
    }
}
