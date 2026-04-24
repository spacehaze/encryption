import XCTest
@testable import WhiteboardCore

final class RGBATests: XCTestCase {
    func testSixDigitHex() {
        let color = RGBA(hex: "#FF8040")
        XCTAssertEqual(color?.r, 1.0, accuracy: 1e-9)
        XCTAssertEqual(color?.g, 128.0 / 255.0, accuracy: 1e-9)
        XCTAssertEqual(color?.b, 64.0 / 255.0, accuracy: 1e-9)
        XCTAssertEqual(color?.a, 1.0)
    }

    func testEightDigitHexIncludesAlpha() {
        let color = RGBA(hex: "#00112233")
        XCTAssertEqual(color?.r, 0x00 / 255.0, accuracy: 1e-9)
        XCTAssertEqual(color?.g, 0x11 / 255.0, accuracy: 1e-9)
        XCTAssertEqual(color?.b, 0x22 / 255.0, accuracy: 1e-9)
        XCTAssertEqual(color?.a, 0x33 / 255.0, accuracy: 1e-9)
    }

    func testThreeDigitHexExpands() {
        let color = RGBA(hex: "#F0A")
        XCTAssertEqual(color?.r, 1.0)
        XCTAssertEqual(color?.g, 0.0)
        XCTAssertEqual(color?.b, 10.0 / 15.0, accuracy: 1e-9)
    }

    func testAcceptsLeadingHashOptional() {
        XCTAssertEqual(RGBA(hex: "#ffffff"), RGBA(hex: "ffffff"))
    }

    func testRejectsMalformedStrings() {
        XCTAssertNil(RGBA(hex: ""))
        XCTAssertNil(RGBA(hex: "#12"))
        XCTAssertNil(RGBA(hex: "#12345"))
        XCTAssertNil(RGBA(hex: "nothex!"))
    }
}
