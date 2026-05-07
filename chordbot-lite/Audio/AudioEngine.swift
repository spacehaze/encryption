import AVFoundation
import Foundation

/// Wraps `AVAudioEngine` + `AVAudioUnitSampler` into the smallest API the
/// sequencer needs: start the engine, play/stop a chord by MIDI numbers.
@MainActor
final class AudioEngine {
    enum EngineError: Error {
        case soundFontMissing(name: String)
    }

    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()
    private var soundFontLoaded = false

    init() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
    }

    /// Idempotent. Configures the audio session, loads the SoundFont once,
    /// then starts the engine if it isn't already running.
    func start() throws {
        try AudioSessionConfig.activatePlayback()

        if !soundFontLoaded {
            try loadDefaultSoundFont()
            soundFontLoaded = true
        }

        if !engine.isRunning {
            try engine.start()
        }
    }

    func stop() {
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func playChord(_ midiNotes: [UInt8], velocity: UInt8 = 90) {
        for note in midiNotes {
            sampler.startNote(note, withVelocity: velocity, onChannel: 0)
        }
    }

    func stopChord(_ midiNotes: [UInt8]) {
        for note in midiNotes {
            sampler.stopNote(note, onChannel: 0)
        }
    }

    private func loadDefaultSoundFont() throws {
        let name = "GeneralUser-GS"
        guard let url = Bundle.main.url(forResource: name, withExtension: "sf2") else {
            throw EngineError.soundFontMissing(name: name)
        }
        try sampler.loadSoundBankInstrument(
            at: url,
            program: 0,                                        // Acoustic Grand Piano
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
    }
}
