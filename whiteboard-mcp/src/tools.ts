import { z } from "zod";

const HEX_COLOR = /^#?[0-9a-fA-F]{3,8}$/;

const coords = z
  .enum(["normalized", "absolute"])
  .optional()
  .describe(
    "Coordinate space. 'normalized' (default) uses 0..1 of the canvas; 'absolute' uses pixels."
  );

const color = z
  .string()
  .regex(HEX_COLOR)
  .optional()
  .describe("Stroke/fill color as a hex string like '#FF0044' or '#FF004488'.");

const strokeWidth = z
  .number()
  .positive()
  .optional()
  .describe("Line width in pixels.");

/**
 * The full set of tools we expose to Claude. Each entry pairs a Zod schema
 * (for validation + JSON-schema generation) with a `toCommand` translator
 * that emits the loose JSON shape the app expects on `POST /command`.
 */
export const tools = {
  clear: {
    description: "Erase everything on the whiteboard.",
    schema: z.object({}),
    toCommand: () => ({ type: "clear" as const }),
  },
  undo: {
    description: "Remove the most recently drawn command.",
    schema: z.object({}),
    toCommand: () => ({ type: "undo" as const }),
  },
  set_background: {
    description: "Set the whiteboard background color.",
    schema: z.object({
      color: z
        .string()
        .regex(HEX_COLOR)
        .describe("Background color as hex, e.g. '#FFFFFF' for white."),
    }),
    toCommand: (args: { color: string }) => ({
      type: "background" as const,
      backgroundColor: args.color,
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
    toCommand: (args: Record<string, unknown>) => ({ type: "line" as const, ...args }),
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
    toCommand: (args: Record<string, unknown>) => ({ type: "rect" as const, ...args }),
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
    toCommand: (args: Record<string, unknown>) => ({ type: "ellipse" as const, ...args }),
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
    toCommand: (args: Record<string, unknown>) => ({ type: "circle" as const, ...args }),
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
    toCommand: (args: Record<string, unknown>) => ({ type: "path" as const, ...args }),
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
    toCommand: (args: Record<string, unknown>) => ({ type: "text" as const, ...args }),
  },
} as const;

export type ToolName = keyof typeof tools;
export const toolNames = Object.keys(tools) as ToolName[];

/**
 * Validate arguments for `name` and translate them into the JSON body that
 * `POST /command` expects. Throws {@link z.ZodError} on invalid input.
 */
export function toolToCommand(name: ToolName, args: unknown): Record<string, unknown> {
  const tool = tools[name];
  const parsed = tool.schema.parse(args ?? {});
  // The per-tool `toCommand` signatures all narrow `args` to their parsed
  // shape; casting is safe because `parsed` comes from the same schema.
  return (tool.toCommand as (p: unknown) => Record<string, unknown>)(parsed);
}
