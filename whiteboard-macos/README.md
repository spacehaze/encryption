# Whiteboard (macOS)

A native macOS whiteboard app you can launch from the menu bar. It opens a
white canvas (optionally fullscreen) and exposes a tiny local HTTP API so
Claude — via the `whiteboard-mcp` bridge — can draw on it while you talk.

## What's here so far

- Menu bar item "Whiteboard" with Show / Fullscreen / Clear / Quit.
- SwiftUI `Canvas` renderer for strokes, lines, rects, ellipses, circles,
  freehand paths, and text.
- Loopback HTTP command server on `127.0.0.1:7017` (`POST /command`,
  `POST /commands`, `GET /health`).
- Voice button wired to `SFSpeechRecognizer` (entitlements + Info.plist
  strings in place; real streaming transcription is stubbed — see
  `VoiceController.swift`).

## Build

Requires macOS 13+ and Xcode 15+ (or the matching Swift 5.9 toolchain).

```sh
cd whiteboard-macos
make           # builds build/Whiteboard.app (Debug)
make release   # Release build
make run       # build + open the .app
```

## Command protocol

`POST http://127.0.0.1:7017/command` with a JSON body:

```json
{ "type": "line", "x": 0.1, "y": 0.1, "x2": 0.9, "y2": 0.9,
  "color": "#FF2244", "strokeWidth": 4 }
```

Coordinates default to the **normalized** space (`0..1` of the canvas). Pass
`"coords": "absolute"` to use pixels. See
`Sources/Whiteboard/IncomingCommand.swift` for the full schema.

## Wiring Claude

See [`../whiteboard-mcp/README.md`](../whiteboard-mcp/README.md) for the MCP
server that turns Claude tool calls into commands against this app.
