import XCTest
import Flutter

@testable import auth0_flutter

// MARK: - Extensions

extension XCTestCase {
    var timeout: TimeInterval {
        return 2
    }
}

// MARK: - Custom Assertions

func assertRequiredArgumentsError(
    _ result: Any?,
    message: String = "The handler did not produce a \(HandlerError.requiredArgumentsMissing.code) error",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    if let result = result as? FlutterError,
       result.code == HandlerError.requiredArgumentsMissing.code,
       result.message == HandlerError.requiredArgumentsMissing.message,
       result.details == nil {
        return
    }
    XCTFail(message, file: file, line: line)
}
