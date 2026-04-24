import { z } from "zod";

/**
 * Minimal zod -> JSON Schema converter. We only emit the shapes used by
 * `tools.ts` (objects, primitives, enums, arrays, tuples); anything exotic
 * returns `{}` rather than throwing, so the MCP handshake can still list
 * the tool.
 */
export function zodToJsonSchema(schema: z.ZodTypeAny): Record<string, unknown> {
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
  if (schema instanceof z.ZodDefault) {
    return zodToJsonSchema(schema._def.innerType);
  }
  if (schema instanceof z.ZodString) {
    return withDescription({ type: "string" }, schema);
  }
  if (schema instanceof z.ZodNumber) {
    return withDescription({ type: "number" }, schema);
  }
  if (schema instanceof z.ZodBoolean) {
    return withDescription({ type: "boolean" }, schema);
  }
  if (schema instanceof z.ZodEnum) {
    return { type: "string", enum: schema.options };
  }
  if (schema instanceof z.ZodArray) {
    return { type: "array", items: zodToJsonSchema(schema.element) };
  }
  if (schema instanceof z.ZodTuple) {
    const items = (schema.items as z.ZodTypeAny[]).map(zodToJsonSchema);
    return {
      type: "array",
      items,
      minItems: items.length,
      maxItems: items.length,
    };
  }
  return {};
}

function withDescription(
  base: Record<string, unknown>,
  schema: z.ZodTypeAny
): Record<string, unknown> {
  return schema.description ? { ...base, description: schema.description } : base;
}
