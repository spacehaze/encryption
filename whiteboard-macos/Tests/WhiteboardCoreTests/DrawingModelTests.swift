import XCTest
@testable import WhiteboardCore

final class DrawingModelTests: XCTestCase {
    private func makeModel() -> DrawingModel {
        DrawingModel(dispatcher: .immediate)
    }

    private func draw(_ kind: DrawCommand.Kind = .line(
        from: Point2D(x: 0, y: 0),
        to: Point2D(x: 1, y: 1),
        color: .black,
        width: 2
    )) -> ResolvedCommand {
        .draw(DrawCommand(kind: kind))
    }

    func testAppliesDrawCommands() {
        let model = makeModel()
        model.apply(draw())
        XCTAssertEqual(model.commands.count, 1)
    }

    func testClearRemovesEverything() {
        let model = makeModel()
        model.apply(draw())
        model.apply(draw())
        model.apply(.clear)
        XCTAssertTrue(model.commands.isEmpty)
    }

    func testUndoRemovesLastCommand() {
        let model = makeModel()
        model.apply(draw())
        let keep = draw()
        model.apply(keep)
        model.apply(draw())
        model.apply(.undo)
        XCTAssertEqual(model.commands.count, 2)
        if case .draw(let last) = keep {
            XCTAssertEqual(model.commands.last?.id, last.id)
        }
    }

    func testUndoOnEmptyIsNoOp() {
        let model = makeModel()
        model.apply(.undo)
        XCTAssertTrue(model.commands.isEmpty)
    }

    func testBackgroundMutation() {
        let model = makeModel()
        XCTAssertEqual(model.background, .white)
        model.apply(.background(.black))
        XCTAssertEqual(model.background, .black)
    }

    func testBatchApplyPreservesOrder() {
        let model = makeModel()
        let commands: [ResolvedCommand] = [draw(), draw(), .undo, draw()]
        model.apply(commands)
        XCTAssertEqual(model.commands.count, 2)
    }
}
