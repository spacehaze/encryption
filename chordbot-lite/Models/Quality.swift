import Foundation

/// Chord quality — the interval pattern stacked on top of the root.
public enum Quality: String, CaseIterable, Sendable, Hashable {
    case major
    case minor
    case dominant7
    case minor7
    case major7
    case diminished
    case suspended4

    public var symbol: String {
        switch self {
        case .major: ""
        case .minor: "m"
        case .dominant7: "7"
        case .minor7: "m7"
        case .major7: "maj7"
        case .diminished: "dim"
        case .suspended4: "sus4"
        }
    }

    /// Semitone offsets from the root that make up this chord.
    /// Voicings are close-position, root in the bass.
    public var intervals: [Int] {
        switch self {
        case .major:      [0, 4, 7]
        case .minor:      [0, 3, 7]
        case .dominant7:  [0, 4, 7, 10]
        case .minor7:     [0, 3, 7, 10]
        case .major7:     [0, 4, 7, 11]
        case .diminished: [0, 3, 6]
        case .suspended4: [0, 5, 7]
        }
    }
}
