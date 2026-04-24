import XCTest
@testable import WhiteboardCore

final class CommandRouterTests: XCTestCase {
    private func makeRouter() -> (CommandRouter, DrawingModel) {
        let model = DrawingModel(dispatcher: .immediate)
        return (CommandRouter(model: model), model)
    }

    private func request(method: String, path: String, body: String = "") -> HTTPRequest {
        HTTPRequest(method: method, path: path, headers: [:], body: Data(body.utf8))
    }

    private func decode(_ data: Data) -> [String: Any]? {
        (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    func testHealthCheck() {
        let (router, _) = makeRouter()
        let response = router.handle(request(method: "GET", path: "/health"))
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(decode(response.body)?["ok"] as? Bool, true)
    }

    func testUnknownRouteIs404() {
        let (router, _) = makeRouter()
        let response = router.handle(request(method: "GET", path: "/nope"))
        XCTAssertEqual(response.status, 404)
    }

    func testSingleCommandApplied() {
        let (router, model) = makeRouter()
        let response = router.handle(request(
            method: "POST",
            path: "/command",
            body: #"{"type":"line","x":0,"y":0,"x2":1,"y2":1}"#
        ))
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(model.commands.count, 1)
        XCTAssertEqual(decode(response.body)?["applied"] as? Int, 1)
    }

    func testBatchAppliedInOrder() {
        let (router, model) = makeRouter()
        let response = router.handle(request(
            method: "POST",
            path: "/commands",
            body: """
                [
                  {"type":"line","x":0,"y":0,"x2":1,"y2":1},
                  {"type":"line","x":0,"y":0,"x2":0.5,"y2":0.5},
                  {"type":"undo"}
                ]
            """
        ))
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(decode(response.body)?["applied"] as? Int, 3)
        XCTAssertEqual(model.commands.count, 1)
    }

    func testMalformedJSONIs400() {
        let (router, _) = makeRouter()
        let response = router.handle(request(
            method: "POST",
            path: "/command",
            body: "not json"
        ))
        XCTAssertEqual(response.status, 400)
    }

    func testMissingFieldIs400() {
        let (router, model) = makeRouter()
        let response = router.handle(request(
            method: "POST",
            path: "/command",
            body: #"{"type":"line","x":0,"y":0,"x2":1}"#
        ))
        XCTAssertEqual(response.status, 400)
        XCTAssertTrue(model.commands.isEmpty)
    }
}
