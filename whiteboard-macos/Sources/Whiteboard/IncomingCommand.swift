import Foundation

/// JSON DTO matching the shape accepted by `POST /command`.
///
/// The MCP bridge populates only the fields relevant to the chosen `type`;
/// ``resolved()`` turns this loose shape into a strongly-typed ``ResolvedCommand``.
struct IncomingCommand: Decodable {
    enum CommandType: String, Decodable {
        case clear, undo, background
        case stroke, path, line, rect, ellipse, circle, text
    }

    let type: CommandType
    let coords: String?
    let color: String?
    let backgroundColor: String?
    let strokeWidth: Double?
    let filled: Bool?

    // Shapes
    let points: [[Double]]?
    let x: Double?
    let y: Double?
    let x2: Double?
    let y2: Double?
    let w: Double?
    let h: Double?
    let radius: Double?

    // Text
    let text: String?
    let fontSize: Double?
}

enum ResolvedCommand {
    case clear
    case undo
    case background(RGBA)
    case draw(DrawCommand)
}

enum CommandDecodeError: Error, CustomStringConvertible {
    case missing(String)
    case tooFewPoints

    var description: String {
        switch self {
        case .missing(let field): return "missing field: \(field)"
        case .tooFewPoints: return "stroke/path requires at least 2 points"
        }
    }
}

extension IncomingCommand {
    func resolved() throws -> ResolvedCommand {
        switch type {
        case .clear: return .clear
        case .undo:  return .undo
        case .background:
            guard let hex = backgroundColor ?? color else { throw CommandDecodeError.missing("backgroundColor") }
            return .background(RGBA(hex: hex) ?? .white)

        case .stroke, .path:
            guard let raw = points, raw.count >= 2 else { throw CommandDecodeError.tooFewPoints }
            let pts = raw.compactMap { $0.count >= 2 ? Point2D(x: $0[0], y: $0[1]) : nil }
            return .draw(.stroke(
                id: UUID(),
                points: pts,
                color: resolvedColor(),
                width: strokeWidth ?? 3,
                coords: resolvedCoords()
            ))

        case .line:
            return .draw(.line(
                id: UUID(),
                from: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                to: Point2D(x: try require(x2, "x2"), y: try require(y2, "y2")),
                color: resolvedColor(),
                width: strokeWidth ?? 3,
                coords: resolvedCoords()
            ))

        case .rect:
            return .draw(.rect(
                id: UUID(),
                origin: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                size: Point2D(x: try require(w, "w"), y: try require(h, "h")),
                color: resolvedColor(),
                width: strokeWidth ?? 3,
                filled: filled ?? false,
                coords: resolvedCoords()
            ))

        case .ellipse:
            return .draw(.ellipse(
                id: UUID(),
                origin: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                size: Point2D(x: try require(w, "w"), y: try require(h, "h")),
                color: resolvedColor(),
                width: strokeWidth ?? 3,
                filled: filled ?? false,
                coords: resolvedCoords()
            ))

        case .circle:
            let cx = try require(x, "x")
            let cy = try require(y, "y")
            let r = try require(radius, "radius")
            return .draw(.ellipse(
                id: UUID(),
                origin: Point2D(x: cx - r, y: cy - r),
                size: Point2D(x: r * 2, y: r * 2),
                color: resolvedColor(),
                width: strokeWidth ?? 3,
                filled: filled ?? false,
                coords: resolvedCoords()
            ))

        case .text:
            return .draw(.text(
                id: UUID(),
                at: Point2D(x: try require(x, "x"), y: try require(y, "y")),
                text: try require(text, "text"),
                color: resolvedColor(),
                fontSize: fontSize ?? 32,
                coords: resolvedCoords()
            ))
        }
    }

    private func require<T>(_ value: T?, _ field: String) throws -> T {
        guard let value else { throw CommandDecodeError.missing(field) }
        return value
    }

    private func resolvedColor() -> RGBA {
        if let hex = color, let rgba = RGBA(hex: hex) { return rgba }
        return .black
    }

    private func resolvedCoords() -> CoordSpace {
        switch coords?.lowercased() {
        case "absolute", "px", "pixels": return .absolute
        default: return .normalized
        }
    }
}

extension RGBA {
    /// Parse `#RGB`, `#RRGGBB`, or `#RRGGBBAA`.
    init?(hex input: String) {
        var s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard let value = UInt64(s, radix: 16) else { return nil }
        switch s.count {
        case 3:
            let r = Double((value >> 8) & 0xF) / 15.0
            let g = Double((value >> 4) & 0xF) / 15.0
            let b = Double(value & 0xF) / 15.0
            self.init(r: r, g: g, b: b, a: 1)
        case 6:
            let r = Double((value >> 16) & 0xFF) / 255.0
            let g = Double((value >> 8) & 0xFF) / 255.0
            let b = Double(value & 0xFF) / 255.0
            self.init(r: r, g: g, b: b, a: 1)
        case 8:
            let r = Double((value >> 24) & 0xFF) / 255.0
            let g = Double((value >> 16) & 0xFF) / 255.0
            let b = Double((value >> 8) & 0xFF) / 255.0
            let a = Double(value & 0xFF) / 255.0
            self.init(r: r, g: g, b: b, a: a)
        default:
            return nil
        }
    }
}
