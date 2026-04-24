#!/usr/bin/env node
/**
 * MCP server that bridges Claude to the Whiteboard macOS app.
 *
 * Claude (Desktop or Code) launches this over stdio. Every tool call turns
 * into a `POST /command` request against the app's local HTTP server (default
 * http://127.0.0.1:7017). The app applies the draw command to its canvas.
 *
 * Coordinates default to the normalized space (0..1 of the canvas) so Claude
 * can draw without knowing the current window size; pass `coords: "absolute"`
 * to use pixels instead.
 */
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";

const ENDPOINT =
  process.env.WHITEBOARD_ENDPOINT ?? "http://127.0.0.1:7017";

// ---------- shared schemas ----------

const coords = z
  .enum(["normalized", "absolute"])
  .optional()
  .describe(
    "Coordinate space. 'normalized' (default) uses 0..1 of the canvas; 'absolute' uses pixels."
  );

const color = z
  .string()
  .regex(/^#?[0-9a-fA-F]{3,8}$/)
  .optional()
  .describe("Stroke/fill color as a hex string like '#FF0044' or '#FF004488'.");

const strokeWidth = z.number().positive().optional().describe("Line width in pixels.");

// ---------- tool schemas ----------

const tools = {
  clear: {
    description: "Erase everything on the whiteboard.",
    schema: z.object({}),
  },
  undo: {
    description: "Remove the most recently drawn command.",
    schema: z.object({}),
  },
  set_background: {
    description: "Set the whiteboard background color.",
    schema: z.object({
      color: z
        .string()
        .regex(/^#?[0-9a-fA-F]{3,8}$/)
        .describe("Background color as hex, e.g. '#FFFFFF' for white."),
    }),
  },
  draw_line: {
    description: "Draw a straight line between two points.",
    schema: z.object({
      x: z.number(),
      y: z.number(),
      x2: z.number(),
      y2: z.number(),
      color,
      strokeWidth,
      coords,
    }),
  },
  draw_rect: {
    description: "Draw a rectangle by top-left origin and size.",
    schema: z.object({
      x: z.number(),
      y: z.number(),
      w: z.number().positive(),
      h: z.number().positive(),
      filled: z.boolean().optional(),
      color,
      strokeWidth,
      coords,
    }),
  },
  draw_ellipse: {
    description: "Draw an ellipse inscribed in the given rectangle.",
    schema: z.object({
      x: z.number(),
      y: z.number(),
      w: z.number().positive(),
      h: z.number().positive(),
      filled: z.boolean().optional(),
      color,
      strokeWidth,
      coords,
    }),
  },
  draw_circle: {
    description: "Draw a circle at (x, y) with the given radius.",
    schema: z.object({
      x: z.number(),
      y: z.number(),
      radius: z.number().positive(),
      filled: z.boolean().optional(),
      color,
      strokeWidth,
      coords,
    }),
  },
  draw_path: {
    description:
      "Draw a freehand/poly path through a sequence of [x, y] points.",
    schema: z.object({
      points: z
        .array(z.tuple([z.number(), z.number()]))
        .min(2)
        .describe("Ordered list of [x, y] points forming the path."),
      color,
      strokeWidth,
      coords,
    }),
  },
  draw_text: {
    description: "Draw a text label at the given position.",
    schema: z.object({
      x: z.number(),
      y: z.number(),
      text: z.string().min(1),
      fontSize: z.number().positive().optional(),
      color,
      coords,
    }),
  },
} as const;

type ToolName = keyof typeof tools;

function toolToCommand(name: ToolName, args: unknown) {
  const parsed = tools[name].schema.parse(args) as Record<string, unknown>;
  switch (name) {
    case "clear": return { type: "clear" };
    case "undo": return { type: "undo" };
    case "set_background":
      return { type: "background", backgroundColor: parsed.color };
    case "draw_line":
      return { type: "line", ...parsed };
    case "draw_rect":
      return { type: "rect", ...parsed };
    case "draw_ellipse":
      return { type: "ellipse", ...parsed };
    case "draw_circle":
      return { type: "circle", ...parsed };
    case "draw_path":
      return { type: "path", ...parsed };
    case "draw_text":
      return { type: "text", ...parsed };
  }
}

async function postCommand(body: unknown): Promise<string> {
  const response = await fetch(`${ENDPOINT}/command`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`whiteboard app returned ${response.status}: ${text}`);
  }
  return text;
}

// ---------- MCP wiring ----------

const server = new Server(
  { name: "whiteboard-mcp", version: "0.1.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: (Object.keys(tools) as ToolName[]).map((name) => ({
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
    await postCommand(command);
    return {
      content: [{ type: "text", text: `applied ${name}` }],
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return {
      isError: true,
      content: [
        {
          type: "text",
          text:
            `failed to apply ${name}: ${message}\n` +
            `(is the Whiteboard app running on ${ENDPOINT}?)`,
        },
      ],
    };
  }
});

// Minimal zod -> json-schema converter. We only use primitive shapes above,
// so we handle just what we emit and bail out loudly on anything exotic.
function zodToJsonSchema(schema: z.ZodTypeAny): Record<string, unknown> {
  if (schema instanceof z.ZodObject) {
    const shape = schema.shape as Record<string, z.ZodTypeAny>;
    const properties: Record<string, unknown> = {};
    const required: string[] = [];
    for (const [key, value] of Object.entries(shape)) {
      properties[key] = zodToJsonSchema(value);
      if (!value.isOptional()) required.push(key);
    }
    return {
      type: "object",
      properties,
      ...(required.length ? { required } : {}),
      additionalProperties: false,
    };
  }
  if (schema instanceof z.ZodOptional) return zodToJsonSchema(schema.unwrap());
  if (schema instanceof z.ZodDefault) return zodToJsonSchema(schema._def.innerType);
  if (schema instanceof z.ZodString) {
    const base: Record<string, unknown> = { type: "string" };
    if (schema.description) base.description = schema.description;
    return base;
  }
  if (schema instanceof z.ZodNumber) {
    const base: Record<string, unknown> = { type: "number" };
    if (schema.description) base.description = schema.description;
    return base;
  }
  if (schema instanceof z.ZodBoolean) return { type: "boolean" };
  if (schema instanceof z.ZodEnum) {
    return { type: "string", enum: schema.options };
  }
  if (schema instanceof z.ZodArray) {
    return { type: "array", items: zodToJsonSchema(schema.element) };
  }
  if (schema instanceof z.ZodTuple) {
    return {
      type: "array",
      items: (schema.items as z.ZodTypeAny[]).map(zodToJsonSchema),
      minItems: schema.items.length,
      maxItems: schema.items.length,
    };
  }
  return {};
}

const transport = new StdioServerTransport();
server.connect(transport).catch((error) => {
  console.error("whiteboard-mcp failed to start:", error);
  process.exit(1);
});
