import Foundation

public struct Point2D: Hashable, Sendable {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) { self.x = x; self.y = y }
}

public struct Size2D: Hashable, Sendable {
    public var width: Double
    public var height: Double
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

/// Coordinate space that points and sizes in a ``DrawCommand`` are expressed
/// in. The default (`normalized`) lets callers draw without knowing the
/// current canvas pixel dimensions.
public enum CoordSpace: String, Sendable {
    case normalized // 0...1 of canvas bounds
    case absolute   // pixels
}
