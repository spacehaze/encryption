import AVFoundation

/// `.playback` category so the app stays audible when the silent switch is on
/// and mixes politely with other audio. Pulled out of `AudioEngine` so it can
/// be skipped in unit tests / SwiftUI previews.
enum AudioSessionConfig {
    static func activatePlayback() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
    }
}
