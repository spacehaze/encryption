import Foundation
import SwiftUI
import Combine

/// Observable store of drawing commands rendered by ``WhiteboardCanvas``.
///
/// Mutations are marshaled onto the main queue so the command server can
/// safely append from its network thread.
final class DrawingModel: ObservableObject {
    @Published private(set) var commands: [DrawCommand] = []
    @Published var background: RGBA = .white

    func append(_ command: DrawCommand) {
        dispatchOnMain { self.commands.append(command) }
    }

    func clear() {
        dispatchOnMain { self.commands.removeAll() }
    }

    func undo() {
        dispatchOnMain {
            if !self.commands.isEmpty { self.commands.removeLast() }
        }
    }

    func setBackground(_ color: RGBA) {
        dispatchOnMain { self.background = color }
    }

    private func dispatchOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }
}

/// A point in normalized canvas coordinates (0...1 in both axes) or absolute
/// pixels depending on the `coords` field of the incoming command.
struct Point2D: Hashable {
    var x: Double
    var y: Double
}

struct RGBA: Hashable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    static let black = RGBA(r: 0, g: 0, b: 0, a: 1)
    static let white = RGBA(r: 1, g: 1, b: 1, a: 1)

    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
}

enum CoordSpace: String {
    case normalized // 0...1 of the canvas bounds
    case absolute   // pixels
}

enum DrawCommand: Identifiable, Hashable {
    case stroke(id: UUID, points: [Point2D], color: RGBA, width: Double, coords: CoordSpace)
    case rect(id: UUID, origin: Point2D, size: Point2D, color: RGBA, width: Double, filled: Bool, coords: CoordSpace)
    case ellipse(id: UUID, origin: Point2D, size: Point2D, color: RGBA, width: Double, filled: Bool, coords: CoordSpace)
    case line(id: UUID, from: Point2D, to: Point2D, color: RGBA, width: Double, coords: CoordSpace)
    case text(id: UUID, at: Point2D, text: String, color: RGBA, fontSize: Double, coords: CoordSpace)

    var id: UUID {
        switch self {
        case .stroke(let id, _, _, _, _),
             .rect(let id, _, _, _, _, _, _),
             .ellipse(let id, _, _, _, _, _, _),
             .line(let id, _, _, _, _, _),
             .text(let id, _, _, _, _, _):
            return id
        }
    }
}
