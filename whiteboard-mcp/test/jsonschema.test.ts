import { strict as assert } from "node:assert";
import { describe, it } from "node:test";
import { z } from "zod";

import { zodToJsonSchema } from "../src/jsonschema.js";
import { tools, toolNames } from "../src/tools.js";

describe("zodToJsonSchema", () => {
  it("converts primitive types", () => {
    assert.deepEqual(zodToJsonSchema(z.string()), { type: "string" });
    assert.deepEqual(zodToJsonSchema(z.number()), { type: "number" });
    assert.deepEqual(zodToJsonSchema(z.boolean()), { type: "boolean" });
  });

  it("preserves descriptions on primitives", () => {
    const schema = z.string().describe("hello");
    assert.deepEqual(zodToJsonSchema(schema), { type: "string", description: "hello" });
  });

  it("marks only non-optional fields required", () => {
    const schema = z.object({
      needed: z.number(),
      maybe: z.string().optional(),
    });
    const json = zodToJsonSchema(schema) as { required?: string[] };
    assert.deepEqual(json.required, ["needed"]);
  });

  it("emits fixed-length array for tuples", () => {
    const schema = z.tuple([z.number(), z.number()]);
    assert.deepEqual(zodToJsonSchema(schema), {
      type: "array",
      items: [{ type: "number" }, { type: "number" }],
      minItems: 2,
      maxItems: 2,
    });
  });

  it("handles enums", () => {
    const schema = z.enum(["a", "b"]);
    assert.deepEqual(zodToJsonSchema(schema), {
      type: "string",
      enum: ["a", "b"],
    });
  });

  it("produces an object schema for every tool", () => {
    for (const name of toolNames) {
      const json = zodToJsonSchema(tools[name].schema) as { type: string };
      assert.equal(json.type, "object", `${name} schema is not an object`);
    }
  });
});
