import Foundation
#if canImport(Speech)
import Speech
import AVFoundation
#endif

/// Thin wrapper around `SFSpeechRecognizer` so the mic button has something to
/// talk to. Leaves the real transcription wiring (entitlements, Info.plist
/// usage strings, routing transcripts to Claude) for a follow-up pass — but
/// the plumbing is here so it's a small delta, not a rewrite.
final class VoiceController {
    static let shared = VoiceController()

    private init() {}

    func setListening(_ on: Bool) {
        #if canImport(Speech)
        if on {
            requestAuthorization { granted in
                guard granted else {
                    NSLog("Speech recognition not authorized")
                    return
                }
                // TODO: wire AVAudioEngine -> SFSpeechRecognizer here and
                //       forward final transcripts to the configured Claude
                //       endpoint (or inject them as MCP tool calls).
                NSLog("Voice listening armed (stub)")
            }
        } else {
            NSLog("Voice listening stopped (stub)")
        }
        #else
        NSLog("Speech framework unavailable on this platform")
        #endif
    }

    #if canImport(Speech)
    private func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async { completion(status == .authorized) }
        }
    }
    #endif
}
