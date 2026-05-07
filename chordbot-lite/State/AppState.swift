import Foundation
import Observation

/// Single source of truth for the UI: progression + transport state +
/// references to audio. Mutations save to disk and, if mid-playback, restart
/// the sequencer so changes take effect immediately.
@MainActor
@Observable
final class AppState {
    var progression: Progression
    /// Index of the chord currently sounding, or nil if stopped.
    var playingIndex: Int?

    @ObservationIgnored private let audio: AudioEngine
    @ObservationIgnored private let sequencer: Sequencer

    var isPlaying: Bool { playingIndex != nil }

    init() {
        self.progression = Persistence.load() ?? .demo
        let engine = AudioEngine()
        self.audio = engine
        self.sequencer = Sequencer(engine: engine)
        self.sequencer.onChordChange = { [weak self] index in
            self?.playingIndex = index
        }
    }

    func togglePlayback() {
        if isPlaying {
            sequencer.stop()
        } else {
            try? sequencer.start(progression)
        }
    }

    func add(_ chord: Chord) {
        progression.chords.append(chord)
        persistAndSyncPlayback()
    }

    func update(_ chord: Chord) {
        guard let i = progression.chords.firstIndex(where: { $0.id == chord.id }) else { return }
        progression.chords[i] = chord
        persistAndSyncPlayback()
    }

    func remove(id: UUID) {
        progression.chords.removeAll { $0.id == id }
        persistAndSyncPlayback()
    }

    func setBpm(_ bpm: Double) {
        progression.bpm = max(40, min(240, bpm))
        Persistence.save(progression)
        // BPM changes apply on the next chord boundary; restart for immediate
        // effect when already playing.
        if isPlaying { restartPlayback() }
    }

    private func persistAndSyncPlayback() {
        Persistence.save(progression)
        guard isPlaying else { return }
        if progression.chords.isEmpty {
            sequencer.stop()
        } else {
            restartPlayback()
        }
    }

    private func restartPlayback() {
        sequencer.stop()
        try? sequencer.start(progression)
    }
}
