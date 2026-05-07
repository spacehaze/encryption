# Chordbot-Lite

A SwiftUI recreation of [Chordbot](https://chordbot.com), built as a personal
learning project. Native iOS, no source-code access — observed behavior only.

## Status

Scaffolded. Plan approved. Step 1 (music theory + tests) not yet started.

## MVP scope

1. Add/remove chords to a linear progression (e.g., C → Am → F → G).
2. Tap a chord to choose root + quality (maj, min, 7, m7, maj7, dim, sus4).
3. Play back the progression at a chosen tempo with a piano voicing.
4. Loop playback + transport controls (play/stop, BPM slider).

Deliberately deferred: drums, bass, multiple sections, styles, song export,
song library, MIDI import.

## Architecture

```
chordbot-lite/
├── App/         # @main entry, AppState injection
├── Models/      # Chord, Progression, MusicTheory (pure value types)
├── Audio/       # AVAudioEngine + AVAudioUnitSampler + Sequencer
│   └── Resources/   # SoundFont (gitignored, fetched on build)
├── Views/       # SwiftUI screens
├── State/       # @Observable AppState
└── Tests/       # XCTest for music theory + sequencer logic
```

## Build order

1. **Music theory module** — `Chord.midiNotes(...)` with unit tests.
2. **Audio engine** — load SoundFont, play one chord on a hardcoded button.
3. **Sequencer** — loop a hardcoded progression at fixed BPM.
4. **State + UI** — wire AppState, build chord row + transport.
5. **Editor sheet** — add/edit/delete chords from UI.
6. **Polish** — persist last progression, visual playhead.

## Tech stack

- SwiftUI (iOS 17+, `@Observable` macro)
- AVFoundation (`AVAudioEngine`, `AVAudioUnitSampler`)
- GeneralUser GS SoundFont (CC-licensed, ~30 MB, fetched on first build)
- No external dependencies for v1

## Risks to watch

- **Audio session category** must be `.playback` or device goes silent in silent mode.
- **SoundFont licensing** — only ship redistributable fonts (GeneralUser GS is fine).
- **Timing jitter** — `DispatchSourceTimer` is OK for MVP; switch to
  `AVAudioEngine` render-thread scheduling if drums are added later.

## Legal

Personal learning project. Not for distribution. Chordbot is a trademark of its
respective owner.
