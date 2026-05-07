import Foundation

/// A chord at the abstract level: a root pitch class plus a quality.
/// Voicing/register is decided at playback time via `midiNotes(octave:)`.
public struct Chord: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var root: Note
    public var quality: Quality

    public init(id: UUID = UUID(), root: Note, quality: Quality) {
        self.id = id
        self.root = root
        self.quality = quality
    }

    /// MIDI note numbers for this chord, voiced from the root upward.
    /// `octave` is the root's octave (4 → middle-C-area chords).
    public func midiNotes(octave: Int = 4) -> [UInt8] {
        let rootMidi = Int(root.midi(octave: octave))
        return quality.intervals.map { offset in
            let raw = rootMidi + offset
            precondition((0...127).contains(raw), "Chord voicing out of MIDI range")
            return UInt8(raw)
        }
    }

    /// Human-readable label, e.g. "Cmaj7", "Am", "G7".
    public var displayName: String {
        root.displayName + quality.symbol
    }
}
