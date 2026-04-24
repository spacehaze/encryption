import XCTest
@testable import WhiteboardCore

final class HTTPMessageTests: XCTestCase {
    func testParsesSimpleGet() {
        let raw = Data("GET /health HTTP/1.1\r\nHost: localhost\r\n\r\n".utf8)
        let request = HTTPRequest.parse(raw)
        XCTAssertEqual(request?.method, "GET")
        XCTAssertEqual(request?.path, "/health")
        XCTAssertEqual(request?.headers["host"], "localhost")
        XCTAssertEqual(request?.body.count, 0)
    }

    func testParsesPostWithBody() {
        let body = #"{"type":"clear"}"#
        let raw = Data(
            "POST /command HTTP/1.1\r\nContent-Length: \(body.utf8.count)\r\nContent-Type: application/json\r\n\r\n\(body)".utf8
        )
        let request = HTTPRequest.parse(raw)
        XCTAssertEqual(request?.method, "POST")
        XCTAssertEqual(request?.path, "/command")
        XCTAssertEqual(request?.body, Data(body.utf8))
    }

    func testReturnsNilWhenHeadersIncomplete() {
        XCTAssertNil(HTTPRequest.parse(Data("GET /".utf8)))
        XCTAssertNil(HTTPRequest.parse(Data("GET / HTTP/1.1\r\nHost: x\r\n".utf8)))
    }

    func testReturnsNilWhenBodyShort() {
        let incomplete = Data(
            "POST /command HTTP/1.1\r\nContent-Length: 20\r\n\r\nshort".utf8
        )
        XCTAssertNil(HTTPRequest.parse(incomplete))
    }

    func testHeaderLookupIsCaseInsensitive() {
        let raw = Data("GET / HTTP/1.1\r\nX-Thing: value\r\n\r\n".utf8)
        XCTAssertEqual(HTTPRequest.parse(raw)?.headers["x-thing"], "value")
    }

    func testJSONResponseSerializes() {
        let response = HTTPResponse.json(status: 200, body: ["ok": true])
        let serialized = String(data: response.serialize(), encoding: .utf8) ?? ""
        XCTAssertTrue(serialized.hasPrefix("HTTP/1.1 200 OK\r\n"))
        XCTAssertTrue(serialized.contains("Content-Type: application/json"))
        XCTAssertTrue(serialized.contains("\"ok\":true"))
    }
}
