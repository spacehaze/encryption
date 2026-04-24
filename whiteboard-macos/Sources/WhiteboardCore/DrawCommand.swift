import Foundation

/// A single drawing operation rendered by the whiteboard canvas.
///
/// The command carries an `id` (used as a SwiftUI identity and for logging)
/// and a `kind` describing the shape. Splitting `id` out of the payload
/// keeps the common fields uniform and makes callers tidier than an enum
/// with per-case associated values.
public struct DrawCommand: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let coords: CoordSpace
    public let kind: Kind

    public init(id: UUID = UUID(), coords: CoordSpace = .normalized, kind: Kind) {
        self.id = id
        self.coords = coords
        self.kind = kind
    }

    public enum Kind: Hashable, Sendable {
        case stroke(points: [Point2D], color: RGBA, width: Double)
        case line(from: Point2D, to: Point2D, color: RGBA, width: Double)
        case rect(origin: Point2D, size: Size2D, color: RGBA, width: Double, filled: Bool)
        case ellipse(origin: Point2D, size: Size2D, color: RGBA, width: Double, filled: Bool)
        case text(at: Point2D, text: String, color: RGBA, fontSize: Double)
    }
}
