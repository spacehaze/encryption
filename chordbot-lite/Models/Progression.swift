import Foundation

/// An ordered sequence of chords with a tempo and a uniform duration per chord.
/// Sections, time-signature changes, and per-chord durations are deferred.
public struct Progression: Equatable, Hashable, Sendable {
    public var chords: [Chord]
    public var bpm: Double
    public var beatsPerChord: Int

    public init(chords: [Chord] = [], bpm: Double = 100, beatsPerChord: Int = 4) {
        precondition(bpm > 0, "BPM must be positive")
        precondition(beatsPerChord > 0, "beatsPerChord must be positive")
        self.chords = chords
        self.bpm = bpm
        self.beatsPerChord = beatsPerChord
    }

    /// Length of one chord in seconds at the current tempo.
    public var secondsPerChord: Double {
        Double(beatsPerChord) * 60.0 / bpm
    }

    /// Total length of one pass through the progression, in seconds.
    public var loopDuration: Double {
        Double(chords.count) * secondsPerChord
    }
}

public extension Progression {
    /// "C, Am, F, G" — useful starting point for the first end-to-end test.
    static let demo = Progression(
        chords: [
            Chord(root: .c, quality: .major),
            Chord(root: .a, quality: .minor),
            Chord(root: .f, quality: .major),
            Chord(root: .g, quality: .major),
        ],
        bpm: 100,
        beatsPerChord: 4
    )
}
