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

func assert<K: RawRepresentable>(result: Any?, has keys: [K]) where K.RawValue == String {
    guard let result = result as? [String: Any] else {
        return XCTFail("The handler did not produce a dictionary")
    }

    XCTAssertEqual(result.keys.sorted(), keys.map(\.rawValue).sorted())
}

func assert(result: Any?, has databaseUser: DatabaseUser) {
    guard let result = result as? [String: Any] else {
        return XCTFail("The handler did not produce a dictionary")
    }

    XCTAssertEqual(result[DatabaseUserProperty.email] as? String, databaseUser.email)
    XCTAssertEqual(result[DatabaseUserProperty.emailVerified] as? Bool, databaseUser.verified)
    XCTAssertEqual(result[DatabaseUserProperty.username] as? String, databaseUser.username)
}

func assert(result: Any?, isError error: Auth0Error) {
    guard let result = result as? FlutterError else {
        return XCTFail("The handler did not produce a FlutterError")
    }

    XCTAssertEqual(result.message, String(describing: error))
}

func assert(result: Any?, isError handlerError: HandlerError) {
    guard let result = result as? FlutterError else {
        return XCTFail("The handler did not produce a FlutterError")
    }

    XCTAssertEqual(result.code, handlerError.code)
    XCTAssertEqual(result.message, handlerError.message)
    XCTAssertNil(result.details)
}

func assert(flutterError: FlutterError, is webAuthError: WebAuthError, with code: String) {
    XCTAssertEqual(flutterError.code, code)
    XCTAssertEqual(flutterError.message, String(describing: webAuthError))
}

func assert(flutterError: FlutterError, is authenticationError: AuthenticationError) {
    guard let details = flutterError.details as? [String: Any] else {
        return XCTFail("The FlutterError is missing the 'details' dictionary")
    }

    XCTAssertEqual(flutterError.code, authenticationError.code)
    XCTAssertEqual(flutterError.message, String(describing: authenticationError))

    let keysToFilter = AuthAPIErrorKey.allCases.map(\.rawValue)

    XCTAssertTrue(details.filter({ !keysToFilter.contains($0.key) }) == authenticationError.details)
    XCTAssertEqual(details[AuthAPIErrorKey.statusCode] as? Int, authenticationError.statusCode)

    guard let flags = details[AuthAPIErrorKey.errorFlags] as? [String: Bool] else {
        return XCTFail("'details' is missing the '\(AuthAPIErrorKey.errorFlags.rawValue)' dictionary")
    }

    XCTAssertEqual(flags[AuthAPIErrorFlag.isMultifactorRequired], authenticationError.isMultifactorRequired)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isMultifactorEnrollRequired], authenticationError.isMultifactorEnrollRequired)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isMultifactorCodeInvalid], authenticationError.isMultifactorCodeInvalid)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isMultifactorTokenInvalid], authenticationError.isMultifactorTokenInvalid)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isPasswordNotStrongEnough], authenticationError.isPasswordNotStrongEnough)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isPasswordAlreadyUsed], authenticationError.isPasswordAlreadyUsed)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isRuleError], authenticationError.isRuleError)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isInvalidCredentials], authenticationError.isInvalidCredentials)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isRefreshTokenDeleted], authenticationError.isRefreshTokenDeleted)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isAccessDenied], authenticationError.isAccessDenied)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isTooManyAttempts], authenticationError.isTooManyAttempts)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isVerificationRequired], authenticationError.isVerificationRequired)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isPasswordLeaked], authenticationError.isPasswordLeaked)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isLoginRequired], authenticationError.isLoginRequired)
    XCTAssertEqual(flags[AuthAPIErrorFlag.isNetworkError], authenticationError.isNetworkError)
}

func assert(flutterError: FlutterError, is credentialsManagerError: CredentialsManagerError, with code: String) {
    XCTAssertEqual(flutterError.code, code)
    XCTAssertEqual(flutterError.message, String(describing: credentialsManagerError))
}
