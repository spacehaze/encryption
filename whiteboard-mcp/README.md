# whiteboard-mcp

MCP server that gives Claude tools to draw on the Whiteboard macOS app.
It speaks stdio to the client (Claude Desktop or Claude Code) and forwards
each tool call to the app's local HTTP server.

## Install

```sh
cd whiteboard-mcp
npm install
npm run build
```

The built entrypoint is `dist/index.js`.

## Register with Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "whiteboard": {
      "command": "node",
      "args": ["/absolute/path/to/whiteboard-mcp/dist/index.js"]
    }
  }
}
```

Restart Claude Desktop. Make sure the Whiteboard app is running first — the
MCP server POSTs to `http://127.0.0.1:7017`.

## Register with Claude Code

```sh
claude mcp add whiteboard -- node /absolute/path/to/whiteboard-mcp/dist/index.js
```

## Tools exposed

| tool             | what it does                                  |
| ---------------- | --------------------------------------------- |
| `clear`          | wipe the canvas                               |
| `undo`           | remove the most recent drawing command        |
| `set_background` | change the background color                   |
| `draw_line`      | straight line between two points              |
| `draw_rect`      | rectangle (stroked or filled)                 |
| `draw_ellipse`   | ellipse inscribed in a rect                   |
| `draw_circle`    | circle at (x, y) with radius                  |
| `draw_path`      | freehand/poly path through `[x, y]` points    |
| `draw_text`      | text label at a position                      |

All shape tools accept `color` (hex), `strokeWidth`, and `coords`
(`"normalized"` — default, `0..1` of the canvas — or `"absolute"` pixels).

## Environment

- `WHITEBOARD_ENDPOINT` — override the app endpoint (default
  `http://127.0.0.1:7017`).

## Example session

Once wired up, try asking Claude:

> "Draw me a simple block diagram of a request hitting an API gateway, then
> a load balancer, then two app servers."

Claude picks tools, the MCP server forwards them to the running app, and the
shapes appear on your whiteboard as it talks.
