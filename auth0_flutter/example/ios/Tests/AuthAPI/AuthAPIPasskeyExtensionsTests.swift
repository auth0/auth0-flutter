#if PASSKEYS_PLATFORM
import XCTest

@testable import auth0_flutter

class AuthAPIPasskeyExtensionsTests: XCTestCase {

    // MARK: - base64URLEncodedString

    func testEncodesUsingURLSafeAlphabetWithoutPadding() {
        // 0xFB 0xFF produces "+/" in standard base64, which must be mapped to
        // the URL-safe "-_" and have its padding stripped.
        let data = Data([0xFB, 0xFF])
        XCTAssertEqual(data.base64URLEncodedString(), "-_8")
    }

    func testEncodesEmptyDataAsEmptyString() {
        XCTAssertEqual(Data().base64URLEncodedString(), "")
    }

    // MARK: - fromBase64URLEncoded

    func testDecodesURLSafeAlphabet() {
        XCTAssertEqual(Data.fromBase64URLEncoded("-_8"), Data([0xFB, 0xFF]))
    }

    func testDecodesInputRequiringTwoPaddingChars() {
        // 1 byte encodes to 2 significant chars and needs "==" padding restored.
        let data = Data([0x66])
        XCTAssertEqual(Data.fromBase64URLEncoded(data.base64URLEncodedString()), data)
    }

    func testDecodesInputRequiringOnePaddingChar() {
        // 2 bytes encode to 3 significant chars and need "=" padding restored.
        let data = Data([0x66, 0x6F])
        XCTAssertEqual(Data.fromBase64URLEncoded(data.base64URLEncodedString()), data)
    }

    func testDecodesInputRequiringNoPadding() {
        // 3 bytes encode to 4 chars with no padding required.
        let data = Data([0x66, 0x6F, 0x6F])
        XCTAssertEqual(Data.fromBase64URLEncoded(data.base64URLEncodedString()), data)
    }

    func testReturnsNilForInvalidBase64() {
        XCTAssertNil(Data.fromBase64URLEncoded("not base64!!"))
    }

    // MARK: - Round trip

    func testRoundTripsArbitraryData() {
        let data = Data((0..<256).map { UInt8($0) })
        let encoded = data.base64URLEncodedString()
        XCTAssertFalse(encoded.contains("+"))
        XCTAssertFalse(encoded.contains("/"))
        XCTAssertFalse(encoded.contains("="))
        XCTAssertEqual(Data.fromBase64URLEncoded(encoded), data)
    }
}
#endif
