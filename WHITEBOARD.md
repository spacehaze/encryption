# Whiteboard

A native macOS whiteboard app controlled by Claude, so the model can sketch
diagrams in real time while you talk to it.

Two pieces:

- [`whiteboard-macos/`](./whiteboard-macos) — the SwiftUI app (menu bar
  launcher, fullscreen canvas, local HTTP command server on
  `127.0.0.1:7017`).
- [`whiteboard-mcp/`](./whiteboard-mcp) — a Node MCP server that exposes
  draw tools to Claude and forwards them to the app.

Quick start:

```sh
# 1. Build and run the app
cd whiteboard-macos && make run

# 2. Build the MCP bridge
cd ../whiteboard-mcp && npm install && npm run build

# 3. Register the bridge with Claude Desktop or Claude Code
#    (see whiteboard-mcp/README.md for the exact config)
```

Status: first pass — rendering + HTTP command API + MCP bridge all work
end-to-end. Voice input is scaffolded (mic button, Speech entitlements) but
the live transcription loop is still a TODO in
`whiteboard-macos/Sources/Whiteboard/VoiceController.swift`.
