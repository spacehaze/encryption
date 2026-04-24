#!/usr/bin/env node
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

import { createClient, DEFAULT_ENDPOINT } from "./client.js";
import { createServer } from "./server.js";

const endpoint = process.env.WHITEBOARD_ENDPOINT ?? DEFAULT_ENDPOINT;
const server = createServer(createClient(endpoint), endpoint);
const transport = new StdioServerTransport();

server.connect(transport).catch((error) => {
  console.error("whiteboard-mcp failed to start:", error);
  process.exit(1);
});
