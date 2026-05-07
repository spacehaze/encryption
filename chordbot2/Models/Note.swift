import Foundation

/// A pitch class (the twelve notes of an octave), independent of register.
public enum Note: Int, CaseIterable, Sendable, Hashable, Codable {
    case c = 0, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b

    public var displayName: String {
        switch self {
        case .c: "C"
        case .cSharp: "C♯"
        case .d: "D"
        case .dSharp: "D♯"
        case .e: "E"
        case .f: "F"
        case .fSharp: "F♯"
        case .g: "G"
        case .gSharp: "G♯"
        case .a: "A"
        case .aSharp: "A♯"
        case .b: "B"
        }
    }

    /// MIDI note number for this pitch class in the given octave.
    /// Octave 4 puts middle C at MIDI 60.
    public func midi(octave: Int) -> UInt8 {
        let raw = (octave + 1) * 12 + rawValue
        precondition((0...127).contains(raw), "MIDI note out of range: \(raw)")
        return UInt8(raw)
    }
}
