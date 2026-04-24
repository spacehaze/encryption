import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

import { tools, toolNames, toolToCommand, type ToolName } from "./tools.js";
import { zodToJsonSchema } from "./jsonschema.js";
import type { WhiteboardClient } from "./client.js";

/**
 * Build an MCP {@link Server} wired up to the supplied whiteboard client.
 * The client is injected so tests can drive the full request flow without
 * standing up an HTTP server.
 */
export function createServer(client: WhiteboardClient, endpointLabel: string): Server {
  const server = new Server(
    { name: "whiteboard-mcp", version: "0.1.0" },
    { capabilities: { tools: {} } }
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: toolNames.map((name) => ({
      name,
      description: tools[name].description,
      inputSchema: zodToJsonSchema(tools[name].schema),
    })),
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const name = request.params.name as ToolName;
    if (!(name in tools)) {
      return {
        isError: true,
        content: [{ type: "text", text: `unknown tool: ${name}` }],
      };
    }
    try {
      const command = toolToCommand(name, request.params.arguments ?? {});
      await client.postCommand(command);
      return { content: [{ type: "text", text: `applied ${name}` }] };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return {
        isError: true,
        content: [
          {
            type: "text",
            text:
              `failed to apply ${name}: ${message}\n` +
              `(is the Whiteboard app running on ${endpointLabel}?)`,
          },
        ],
      };
    }
  });

  return server;
}
