import Foundation

/// Plays a `Progression` as a loop: triggers chord N, schedules a timer for
/// `secondsPerChord` later, advances index, repeats. `DispatchSourceTimer` on
/// `.main` is good enough for chord-rate scheduling; switch to a
/// render-thread scheduler later if drums are added.
@MainActor
final class Sequencer {
    private let engine: AudioEngine
    private var timer: DispatchSourceTimer?
    private var progression: Progression?
    private var currentIndex: Int = 0

    private(set) var isPlaying: Bool = false

    /// Fires on the main actor whenever the playing chord changes. Index of
    /// `nil` means playback stopped; otherwise it's the index into the
    /// currently-loaded progression.
    var onChordChange: ((Int?) -> Void)?

    init(engine: AudioEngine) {
        self.engine = engine
    }

    func start(_ progression: Progression) throws {
        guard !progression.chords.isEmpty else { return }
        stop()

        try engine.start()

        self.progression = progression
        self.currentIndex = 0
        self.isPlaying = true

        playCurrentChord()
        scheduleAdvance()
    }

    func stop() {
        timer?.cancel()
        timer = nil
        if let progression, progression.chords.indices.contains(currentIndex) {
            engine.stopChord(progression.chords[currentIndex].midiNotes())
        }
        progression = nil
        currentIndex = 0
        if isPlaying {
            isPlaying = false
            onChordChange?(nil)
        }
    }

    private func playCurrentChord() {
        guard let progression else { return }
        let chord = progression.chords[currentIndex]
        engine.playChord(chord.midiNotes())
        onChordChange?(currentIndex)
    }

    private func scheduleAdvance() {
        guard let progression else { return }
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + progression.secondsPerChord)
        timer.setEventHandler { [weak self] in
            // The timer's queue is .main so we're already on the main thread;
            // assumeIsolated bridges into MainActor without an extra hop.
            MainActor.assumeIsolated { self?.advance() }
        }
        timer.resume()
        self.timer = timer
    }

    private func advance() {
        guard let progression, isPlaying else { return }
        let previousChord = progression.chords[currentIndex]
        engine.stopChord(previousChord.midiNotes())
        currentIndex = (currentIndex + 1) % progression.chords.count
        playCurrentChord()
        scheduleAdvance()
    }
}
