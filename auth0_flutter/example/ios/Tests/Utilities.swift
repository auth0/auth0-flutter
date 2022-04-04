import XCTest
import Flutter
import Auth0
import JWTDecode

@testable import auth0_flutter

// MARK: - Extensions

extension XCTestCase {
    var timeout: TimeInterval {
        return 2
    }
}

// MARK: - Custom Assertions

func assertHas(handlerError: HandlerError,
               in result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? FlutterError,
       result.code == handlerError.code,
       result.message == handlerError.message,
       result.details == nil {
        return
    }
    XCTFail("The handler did not produce a \(handlerError.code) error", file: file, line: line)
}

func assertHas(credentials: Credentials,
               in result: Any?,
               file: StaticString = #filePath,
               line: UInt = #line) {
    if let result = result as? [String: Any],
       result["accessToken"] as? String == credentials.accessToken,
       result["idToken"] as? String == credentials.idToken,
       result["refreshToken"] as? String == credentials.refreshToken,
       result["expiresAt"] as? TimeInterval == credentials.expiresIn.timeIntervalSince1970,
       result["scopes"] as? [String] == credentials.scope?.split(separator: " ").map(String.init),
       let jwt = try? decode(jwt: credentials.idToken),
       let userProfile = result["userProfile"] as? [String: Any],
       NSDictionary(dictionary: userProfile).isEqual(to: jwt.body) {
        return
    }
    XCTFail("The handler did not produce matching credentials", file: file, line: line)
}
