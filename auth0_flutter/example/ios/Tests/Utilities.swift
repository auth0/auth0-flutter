import XCTest
import Flutter
import Auth0
import JWTDecode

@testable import auth0_flutter

// MARK: - Operators

public func ==(lhs: [String: Any], rhs: [String: Any]) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func ==(lhs: [String: Any]?, rhs: [String: Any]?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
        // If both are nil return true
        // == can't be used here as it would be recursive
        return !(lhs != nil || rhs != nil)
    }
    return lhs == rhs
}

// MARK: - Extensions

extension XCTestCase {
    var timeout: TimeInterval {
        return 2
    }

    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: timeout)
    }

    func arguments() -> [String: Any] {
        return [:]
    }

    func arguments<V>(withKey key: String, value: V) -> [String: Any] {
        var dictionary = arguments()
        dictionary[key] = value
        return dictionary
    }

    func arguments<K: RawRepresentable, V>(withKey key: K, value: V) -> [String: Any] where K.RawValue == String {
        return arguments(withKey: key.rawValue, value: value)
    }

    func arguments(without key: String) -> [String: Any] {
        var dictionary = arguments()
        dictionary.removeValue(forKey: key)
        return dictionary
    }

    func arguments<K: RawRepresentable>(without key: K) -> [String: Any] where K.RawValue == String {
        return arguments(without: key.rawValue)
    }
}

// MARK: - Custom Assertions

func assert<K: RawRepresentable>(result: Any?,
                                 has keys: [K],
                                 file: StaticString = #filePath,
                                 line: UInt = #line) where K.RawValue == String {
    let stringKeys = keys.map(\.rawValue)
    if let result = result as? [String: Any], result.allSatisfy({ stringKeys.contains($0.key) }) {
        return
    }
    XCTFail("The handler did not produce a dictionary containing \(keys)", file: file, line: line)
}

func assert(result: Any?, has databaseUser: DatabaseUser, file: StaticString = #filePath, line: UInt = #line) {
    if let result = result as? [String: Any],
       result[DatabaseUserProperty.email] as? String == databaseUser.email,
       result[DatabaseUserProperty.emailVerified] as? Bool == databaseUser.verified,
       result[DatabaseUserProperty.username] as? String == databaseUser.username {
        return
    }
    XCTFail("The handler did not produce matching database users", file: file, line: line)
}

func assert(result: Any?, isError error: Auth0Error, file: StaticString = #filePath, line: UInt = #line) {
    if let result = result as? FlutterError,
       result.message == String(describing: error) {
        return
    }
    XCTFail("The handler did not produce the error '\(error)'", file: file, line: line)
}

func assert(result: Any?, isError handlerError: HandlerError, file: StaticString = #filePath, line: UInt = #line) {
    if let result = result as? FlutterError,
       result.code == handlerError.code,
       result.message == handlerError.message,
       result.details == nil {
        return
    }
    XCTFail("The handler did not produce the error \(handlerError.code)", file: file, line: line)
}

func assert(flutterError: FlutterError,
            is webAuthError: WebAuthError,
            with code: String,
            file: StaticString = #filePath,
            line: UInt = #line) {
    if flutterError.code == code, flutterError.message == String(describing: webAuthError) {
        return
    }
    XCTFail("The handler did not produce the error '\(webAuthError)'", file: file, line: line)
}

func assert(flutterError: FlutterError,
            is authenticationError: AuthenticationError,
            file: StaticString = #filePath,
            line: UInt = #line) {
    if let details = flutterError.details as? [String: Any],
       flutterError.code == authenticationError.code,
       details.filter({ $0.key != AuthAPIErrorFlag.key }) == authenticationError.details,
       let flags = details[AuthAPIErrorFlag.key] as? [String: Bool],
       flags[AuthAPIErrorFlag.isMultifactorRequired] == authenticationError.isMultifactorRequired,
       flags[AuthAPIErrorFlag.isMultifactorEnrollRequired] == authenticationError.isMultifactorEnrollRequired,
       flags[AuthAPIErrorFlag.isMultifactorCodeInvalid] == authenticationError.isMultifactorCodeInvalid,
       flags[AuthAPIErrorFlag.isMultifactorTokenInvalid] == authenticationError.isMultifactorTokenInvalid,
       flags[AuthAPIErrorFlag.isPasswordNotStrongEnough] == authenticationError.isPasswordNotStrongEnough,
       flags[AuthAPIErrorFlag.isPasswordAlreadyUsed] == authenticationError.isPasswordAlreadyUsed,
       flags[AuthAPIErrorFlag.isRuleError] == authenticationError.isRuleError,
       flags[AuthAPIErrorFlag.isInvalidCredentials] == authenticationError.isInvalidCredentials,
       flags[AuthAPIErrorFlag.isRefreshTokenDeleted] == authenticationError.isRefreshTokenDeleted,
       flags[AuthAPIErrorFlag.isAccessDenied] == authenticationError.isAccessDenied,
       flags[AuthAPIErrorFlag.isTooManyAttempts] == authenticationError.isTooManyAttempts,
       flags[AuthAPIErrorFlag.isVerificationRequired] == authenticationError.isVerificationRequired,
       flags[AuthAPIErrorFlag.isPasswordLeaked] == authenticationError.isPasswordLeaked,
       flags[AuthAPIErrorFlag.isLoginRequired] == authenticationError.isLoginRequired,
       flags[AuthAPIErrorFlag.isNetworkError] == authenticationError.isNetworkError {
        return
    }
    XCTFail("The handler did not produce the error '\(authenticationError)'", file: file, line: line)
}
