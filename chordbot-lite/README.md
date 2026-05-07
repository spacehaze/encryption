# Chordbot-Lite

A SwiftUI recreation of [Chordbot](https://chordbot.com), built as a personal
learning project. Native iOS, no source-code access — observed behavior only.

## What it does (MVP)

- Build a chord progression by tapping `+` and picking root + quality.
- Tap a chord to edit it; delete from the editor.
- Adjust BPM with the slider.
- Hit play — a piano comp loops the progression with the current chord
  highlighted.
- Quit and reopen — your progression and BPM persist.

Deliberately deferred: drums, bass, multiple sections, styles, song export,
song library, MIDI import.

## Project layout

```
chordbot-lite/
├── App/             # @main entry, AppState injection
├── Audio/           # AVAudioEngine + sampler + sequencer
│   └── Resources/   # SoundFont (gitignored, fetched on first build)
├── Models/          # Chord, Note, Quality, Progression — pure value types
├── State/           # @Observable AppState, UserDefaults persistence
├── Views/           # SwiftUI screens (ContentView, TransportBar, …)
├── Tests/           # XCTest, runnable via `swift test`
├── Scripts/
│   └── fetch-soundfont.sh
├── Package.swift    # SPM manifest for headless music-theory tests
└── project.yml      # XcodeGen spec for the iOS app
```

## First build

You need: macOS, Xcode 15+, ~50 MB free disk for the SoundFont.

```sh
# 1. Fetch the SoundFont (one-time, ~30 MB).
cd chordbot-lite
./Scripts/fetch-soundfont.sh

# 2a. Generate the Xcode project (recommended).
brew install xcodegen        # if you don't have it
xcodegen generate
open ChordbotLite.xcodeproj

# 2b. Or set it up manually — see "Manual Xcode setup" below.

# 3. Run the unit tests for the music-theory module.
swift test
```

In Xcode: pick a simulator (any iOS 17+) or your iPhone, hit ⌘R. The first
launch creates `Progression.demo` (C → Am → F → G).

## Manual Xcode setup

If you'd rather not install XcodeGen:

1. **File → New → Project → iOS → App**, product name `ChordbotLite`,
   interface SwiftUI, language Swift, minimum iOS 17.0.
2. Delete the auto-generated `ContentView.swift` and `*App.swift` files.
3. Drag the four folders **`App`, `Audio`, `Models`, `State`, `Views`** from
   this repo into the Xcode project navigator. In the dialog, choose *Create
   groups* and add to the `ChordbotLite` target.
4. Drag **`Audio/Resources/GeneralUser-GS.sf2`** in too — verify it's listed
   under *Build Phases → Copy Bundle Resources*.
5. Build & run.

## Tech stack

- SwiftUI (iOS 17+, `@Observable` macro)
- AVFoundation (`AVAudioEngine`, `AVAudioUnitSampler`)
- GeneralUser GS SoundFont (SCC license, ~30 MB, fetched on first build)
- Zero external Swift dependencies

## Risks / gotchas

- **Audio session category** is set to `.playback` so the app stays audible
  with the silent switch on. Don't change it without verifying on device.
- **SoundFont licensing** — only ship redistributable fonts. GeneralUser GS is
  fine; a commercial sample library is not.
- **Timing jitter** — `DispatchSourceTimer` is OK for chord-rate scheduling.
  If drums get added, switch to `AVAudioEngine`'s render-thread scheduling
  for sample-accurate timing.
- **Mid-playback edits** restart the loop from chord 0 (intentional, simple).
  A future version could splice changes in without restarting.

## Legal

Personal learning project. Not for distribution. "Chordbot" is a trademark of
its respective owner.
