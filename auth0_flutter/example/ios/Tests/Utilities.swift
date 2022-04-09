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

    func arguments<T>(key: String, value: T) -> [String: Any] {
        var dictionary = arguments()
        dictionary[key] = value
        return dictionary
    }

    func arguments(without key: String) -> [String: Any] {
        var dictionary = arguments()
        dictionary.removeValue(forKey: key)
        return dictionary
    }
}

// MARK: - Custom Assertions

func assertHas(handlerError: HandlerError,
               _ result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? FlutterError,
       result.code == handlerError.code,
       result.message == handlerError.message,
       result.details == nil {
        return
    }
    XCTFail("The handler did not produce the error \(handlerError.code)", file: file, line: line)
}

func assertHas(webAuthError: WebAuthError,
               code: String,
               _ result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? FlutterError,
       result.code == code,
       result.message == String(describing: webAuthError) {
        return
    }
    XCTFail("The handler did not produce the error '\(webAuthError)'", file: file, line: line)
}

func assertHas(authenticationError: AuthenticationError,
               _ result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? FlutterError,
       let details = result.details as? [String: Any],
       result.code == authenticationError.code,
       details == authenticationError.info {
        return
    }
    XCTFail("The handler did not produce the error '\(authenticationError)'", file: file, line: line)
}

func assertHas(credentials: Credentials,
               _ result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? [String: Any],
       result["accessToken"] as? String == credentials.accessToken,
       result["idToken"] as? String == credentials.idToken,
       result["refreshToken"] as? String == credentials.refreshToken,
       result["expiresAt"] as? String == credentials.expiresIn.asISO8601String,
       result["scopes"] as? [String] == credentials.scope?.split(separator: " ").map(String.init),
       let jwt = try? decode(jwt: credentials.idToken),
       let userProfile = result["userProfile"] as? [String: Any],
       userProfile == jwt.body {
        return
    }
    XCTFail("The handler did not produce matching credentials", file: file, line: line)
}

func assertHas(databaseUser: DatabaseUser,
               _ result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? [String: Any],
       result["email"] as? String == databaseUser.email,
       result["username"] as? String == databaseUser.username,
       result["verified"] as? Bool == databaseUser.verified {
        return
    }
    XCTFail("The handler did not produce matching database users", file: file, line: line)
}

func assertHas(userInfo: UserInfo,
               _ result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? [String: Any],
       result["sub"] as? String == userInfo.sub,
       result["name"] as? String == userInfo.name,
       result["given_name"] as? String == userInfo.givenName,
       result["family_name"] as? String == userInfo.familyName,
       result["middle_name"] as? String ==  userInfo.middleName,
       result["nickname"] as? String ==  userInfo.nickname,
       result["preferred_username"] as? String == userInfo.preferredUsername,
       result["profile"] as? String == userInfo.profile?.absoluteString,
       result["picture"] as? String == userInfo.picture?.absoluteString,
       result["website"] as? String == userInfo.website?.absoluteString,
       result["email"] as? String == userInfo.email,
       result["email_verified"] as? Bool == userInfo.emailVerified,
       result["gender"] as? String == userInfo.gender,
       result["birthdate"] as? String == userInfo.birthdate,
       result["zoneinfo"] as? String == userInfo.zoneinfo?.identifier,
       result["locale"] as? String == userInfo.locale?.identifier,
       result["phone_number"] as? String == userInfo.phoneNumber,
       result["phone_number_verified"] as? Bool == userInfo.phoneNumberVerified,
       result["address"] as? [String: String] == userInfo.address,
       result["updated_at"] as? String == userInfo.updatedAt?.asISO8601String,
       result["custom_claims"] as? [String: Any] == userInfo.customClaims {
        return
    }
    XCTFail("The handler did not produce matching user profiles", file: file, line: line)
}
