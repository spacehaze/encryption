import Foundation

/// Loose JSON shape that the MCP bridge POSTs to the app.
///
/// We keep this separate from ``DrawCommand`` so the wire format can stay
/// forgiving (everything optional, strings for colors/coords) while the
/// internal model stays strict. ``resolved()`` converts one shape to the
/// other.
public struct IncomingCommand: Decodable, Equatable {
    public enum CommandType: String, Decodable {
        case clear, undo, background
        case stroke, path, line, rect, ellipse, circle, text
    }

    public var type: CommandType
    public var coords: String?
    public var color: String?
    public var backgroundColor: String?
    public var strokeWidth: Double?
    public var filled: Bool?

    public var points: [[Double]]?
    public var x: Double?
    public var y: Double?
    public var x2: Double?
    public var y2: Double?
    public var w: Double?
    public var h: Double?
    public var radius: Double?

    public var text: String?
    public var fontSize: Double?
}

public enum ResolvedCommand: Equatable {
    case clear
    case undo
    case background(RGBA)
    case draw(DrawCommand)
}

public enum CommandDecodeError: Error, Equatable, CustomStringConvertible {
    case missingField(String)
    case tooFewPoints

    public var description: String {
        switch self {
        case .missingField(let field): return "missing field: \(field)"
        case .tooFewPoints: return "stroke/path requires at least 2 points"
        }
    }
}

public extension IncomingCommand {
    /// Convert the loose wire shape into a typed ``ResolvedCommand``.
    ///
    /// `idProvider` is injectable so tests can produce stable UUIDs.
    func resolved(idProvider: () -> UUID = UUID.init) throws -> ResolvedCommand {
        switch type {
        case .clear: return .clear
        case .undo:  return .undo

        case .background:
            let raw = try require(backgroundColor ?? color, "backgroundColor")
            return .background(RGBA(hex: raw) ?? .white)

        case .stroke, .path:
            guard let raw = points, raw.count >= 2 else {
                throw CommandDecodeError.tooFewPoints
            }
            let pts = raw.compactMap { $0.count >= 2 ? Point2D(x: $0[0], y: $0[1]) : nil }
            guard pts.count >= 2 else { throw CommandDecodeError.tooFewPoints }
            return .draw(DrawCommand(
                id: idProvider(),
                coords: resolvedCoords,
                kind: .stroke(points: pts, color: resolvedColor, width: strokeWidth ?? 3)
            ))

        case .line:
            return .draw(DrawCommand(
                id: idProvider(),
                coords: resolvedCoords,
                kind: .line(
                    from: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                    to: Point2D(x: try require(x2, "x2"), y: try require(y2, "y2")),
                    color: resolvedColor,
                    width: strokeWidth ?? 3
                )
            ))

        case .rect:
            return .draw(DrawCommand(
                id: idProvider(),
                coords: resolvedCoords,
                kind: .rect(
                    origin: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                    size: Size2D(width: try require(w, "w"), height: try require(h, "h")),
                    color: resolvedColor,
                    width: strokeWidth ?? 3,
                    filled: filled ?? false
                )
            ))

        case .ellipse:
            return .draw(DrawCommand(
                id: idProvider(),
                coords: resolvedCoords,
                kind: .ellipse(
                    origin: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                    size: Size2D(width: try require(w, "w"), height: try require(h, "h")),
                    color: resolvedColor,
                    width: strokeWidth ?? 3,
                    filled: filled ?? false
                )
            ))

        case .circle:
            let cx = try require(x, "x")
            let cy = try require(y, "y")
            let r = try require(radius, "radius")
            return .draw(DrawCommand(
                id: idProvider(),
                coords: resolvedCoords,
                kind: .ellipse(
                    origin: Point2D(x: cx - r, y: cy - r),
                    size: Size2D(width: r * 2, height: r * 2),
                    color: resolvedColor,
                    width: strokeWidth ?? 3,
                    filled: filled ?? false
                )
            ))

        case .text:
            return .draw(DrawCommand(
                id: idProvider(),
                coords: resolvedCoords,
                kind: .text(
                    at: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                    text: try require(text, "text"),
                    color: resolvedColor,
                    fontSize: fontSize ?? 32
                )
            ))
        }
    }

    private var resolvedColor: RGBA {
        color.flatMap { RGBA(hex: $0) } ?? .black
    }

    private var resolvedCoords: CoordSpace {
        switch coords?.lowercased() {
        case "absolute", "px", "pixels": return .absolute
        default: return .normalized
        }
    }

    private func require<T>(_ value: T?, _ field: String) throws -> T {
        guard let value else { throw CommandDecodeError.missingField(field) }
        return value
    }
}
