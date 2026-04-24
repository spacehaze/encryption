import XCTest
@testable import WhiteboardCore

final class IncomingCommandTests: XCTestCase {
    private let fixedID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
    private func provider() -> () -> UUID { { [self] in fixedID } }

    private func decode(_ json: String) throws -> IncomingCommand {
        try JSONDecoder().decode(IncomingCommand.self, from: Data(json.utf8))
    }

    func testClearDecodes() throws {
        let resolved = try decode("""
            {"type": "clear"}
        """).resolved()
        XCTAssertEqual(resolved, .clear)
    }

    func testUndoDecodes() throws {
        let resolved = try decode("""
            {"type": "undo"}
        """).resolved()
        XCTAssertEqual(resolved, .undo)
    }

    func testBackgroundPrefersBackgroundColorOverColor() throws {
        let resolved = try decode("""
            {"type": "background", "color": "#000000", "backgroundColor": "#FFFFFF"}
        """).resolved()
        XCTAssertEqual(resolved, .background(.white))
    }

    func testBackgroundFallsBackToColor() throws {
        let resolved = try decode("""
            {"type": "background", "color": "#FFFFFF"}
        """).resolved()
        XCTAssertEqual(resolved, .background(.white))
    }

    func testBackgroundMissingColorThrows() {
        XCTAssertThrowsError(
            try decode("""
                {"type": "background"}
            """).resolved()
        ) { error in
            XCTAssertEqual(error as? CommandDecodeError, .missingField("backgroundColor"))
        }
    }

    func testLineResolvesWithDefaults() throws {
        let resolved = try decode("""
            {"type": "line", "x": 0, "y": 0, "x2": 1, "y2": 1}
        """).resolved(idProvider: provider())

        guard case .draw(let command) = resolved,
              case .line(let from, let to, let color, let width) = command.kind else {
            return XCTFail("expected line draw")
        }
        XCTAssertEqual(command.id, fixedID)
        XCTAssertEqual(command.coords, .normalized)
        XCTAssertEqual(from, Point2D(x: 0, y: 0))
        XCTAssertEqual(to, Point2D(x: 1, y: 1))
        XCTAssertEqual(color, .black)
        XCTAssertEqual(width, 3)
    }

    func testLineMissingFieldThrows() {
        XCTAssertThrowsError(
            try decode("""
                {"type": "line", "x": 0, "y": 0, "x2": 1}
            """).resolved()
        ) { error in
            XCTAssertEqual(error as? CommandDecodeError, .missingField("y2"))
        }
    }

    func testRectHonoursFilledAndCustomStroke() throws {
        let resolved = try decode("""
            {"type": "rect", "x": 0.1, "y": 0.2, "w": 0.3, "h": 0.4,
             "filled": true, "color": "#FF0000", "strokeWidth": 5,
             "coords": "absolute"}
        """).resolved(idProvider: provider())

        guard case .draw(let command) = resolved,
              case .rect(let origin, let size, let color, let width, let filled) = command.kind else {
            return XCTFail("expected rect draw")
        }
        XCTAssertEqual(command.coords, .absolute)
        XCTAssertEqual(origin, Point2D(x: 0.1, y: 0.2))
        XCTAssertEqual(size, Size2D(width: 0.3, height: 0.4))
        XCTAssertEqual(color, RGBA(r: 1, g: 0, b: 0))
        XCTAssertEqual(width, 5)
        XCTAssertTrue(filled)
    }

    func testCircleExpandsToEllipseBounds() throws {
        let resolved = try decode("""
            {"type": "circle", "x": 0.5, "y": 0.5, "radius": 0.1}
        """).resolved(idProvider: provider())

        guard case .draw(let command) = resolved,
              case .ellipse(let origin, let size, _, _, _) = command.kind else {
            return XCTFail("expected ellipse draw")
        }
        XCTAssertEqual(origin, Point2D(x: 0.4, y: 0.4))
        XCTAssertEqual(size, Size2D(width: 0.2, height: 0.2))
    }

    func testStrokeRequiresAtLeastTwoPoints() {
        XCTAssertThrowsError(
            try decode("""
                {"type": "stroke", "points": [[0, 0]]}
            """).resolved()
        ) { error in
            XCTAssertEqual(error as? CommandDecodeError, .tooFewPoints)
        }
    }

    func testStrokeDropsMalformedPoints() throws {
        let resolved = try decode("""
            {"type": "stroke", "points": [[0, 0], [0.1], [1, 1]]}
        """).resolved(idProvider: provider())

        guard case .draw(let command) = resolved,
              case .stroke(let points, _, _) = command.kind else {
            return XCTFail("expected stroke draw")
        }
        XCTAssertEqual(points, [Point2D(x: 0, y: 0), Point2D(x: 1, y: 1)])
    }

    func testTextRequiresBodyAndPosition() {
        XCTAssertThrowsError(
            try decode("""
                {"type": "text", "x": 0, "y": 0}
            """).resolved()
        ) { error in
            XCTAssertEqual(error as? CommandDecodeError, .missingField("text"))
        }
    }

    func testCoordsAliases() throws {
        for alias in ["absolute", "px", "pixels", "PIXELS"] {
            let resolved = try decode("""
                {"type": "line", "x": 0, "y": 0, "x2": 1, "y2": 1, "coords": "\(alias)"}
            """).resolved()
            guard case .draw(let command) = resolved else { return XCTFail("expected draw") }
            XCTAssertEqual(command.coords, .absolute, "alias \(alias) should map to absolute")
        }
    }
}
