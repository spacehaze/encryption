# Whiteboard (macOS)

Native macOS whiteboard app, launched from the menu bar. Opens a white canvas
(optionally fullscreen) and exposes a tiny local HTTP API so Claude — via
the `whiteboard-mcp` bridge — can draw on it while you talk.

## Layout

```
Sources/
  WhiteboardCore/   pure, testable logic (Geometry, RGBA, DrawCommand,
                    DrawingModel, IncomingCommand, HTTP parse, CommandRouter)
  Whiteboard/       AppKit/SwiftUI shell + Network.framework listener
Tests/
  WhiteboardCoreTests/  XCTest suite over WhiteboardCore
```

The split keeps everything testable without AppKit. `Whiteboard` contains
only what actually needs `NSApplication`, `SwiftUI`, or `NWListener`.

## Build

Requires macOS 13+ and a Swift 5.9 toolchain.

```sh
cd whiteboard-macos
make           # builds build/Whiteboard.app (Debug)
make release   # Release build
make run       # build + open the .app
```

## Test

```sh
swift test
```

## Command protocol

`POST http://127.0.0.1:7017/command` with a JSON body:

```json
{ "type": "line", "x": 0.1, "y": 0.1, "x2": 0.9, "y2": 0.9,
  "color": "#FF2244", "strokeWidth": 4 }
```

Coordinates default to the **normalized** space (`0..1` of the canvas). Pass
`"coords": "absolute"` to use pixels. See
`Sources/WhiteboardCore/IncomingCommand.swift` for the full schema.

## Wiring Claude

See [`../whiteboard-mcp/README.md`](../whiteboard-mcp/README.md) for the MCP
server that turns Claude tool calls into commands against this app.
