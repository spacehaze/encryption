import Foundation

public struct RGBA: Hashable, Sendable {
    public var r: Double
    public var g: Double
    public var b: Double
    public var a: Double

    public init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }

    public static let black = RGBA(r: 0, g: 0, b: 0)
    public static let white = RGBA(r: 1, g: 1, b: 1)
}

public extension RGBA {
    /// Parse `#RGB`, `#RRGGBB`, or `#RRGGBBAA` (with or without the `#`).
    /// Returns `nil` for any other shape.
    init?(hex input: String) {
        var s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard let value = UInt64(s, radix: 16) else { return nil }
        switch s.count {
        case 3:
            self.init(
                r: Double((value >> 8) & 0xF) / 15.0,
                g: Double((value >> 4) & 0xF) / 15.0,
                b: Double(value & 0xF) / 15.0
            )
        case 6:
            self.init(
                r: Double((value >> 16) & 0xFF) / 255.0,
                g: Double((value >> 8) & 0xFF) / 255.0,
                b: Double(value & 0xFF) / 255.0
            )
        case 8:
            self.init(
                r: Double((value >> 24) & 0xFF) / 255.0,
                g: Double((value >> 16) & 0xFF) / 255.0,
                b: Double((value >> 8) & 0xFF) / 255.0,
                a: Double(value & 0xFF) / 255.0
            )
        default:
            return nil
        }
    }
}
