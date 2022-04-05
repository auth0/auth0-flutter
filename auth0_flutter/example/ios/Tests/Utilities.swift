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

    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: timeout)
    }
}

extension Date {
    var asISO8601String: String {
        return ISO8601DateFormatter().string(from: self)
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
       NSDictionary(dictionary: userProfile).isEqual(to: jwt.body) {
        return
    }
    XCTFail("The handler did not produce matching credentials", file: file, line: line)
}
