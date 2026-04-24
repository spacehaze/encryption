import { strict as assert } from "node:assert";
import { describe, it } from "node:test";
import { z } from "zod";

import { toolNames, toolToCommand, tools } from "../src/tools.js";

describe("toolToCommand", () => {
  it("covers every registered tool", () => {
    assert.deepEqual(
      [...toolNames].sort(),
      [
        "clear",
        "draw_circle",
        "draw_ellipse",
        "draw_line",
        "draw_path",
        "draw_rect",
        "draw_text",
        "set_background",
        "undo",
      ].sort()
    );
  });

  it("emits plain command envelopes for clear / undo", () => {
    assert.deepEqual(toolToCommand("clear", {}), { type: "clear" });
    assert.deepEqual(toolToCommand("undo", {}), { type: "undo" });
  });

  it("maps set_background to the backgroundColor field", () => {
    assert.deepEqual(toolToCommand("set_background", { color: "#123456" }), {
      type: "background",
      backgroundColor: "#123456",
    });
  });

  it("forwards shape arguments as-is", () => {
    assert.deepEqual(
      toolToCommand("draw_line", { x: 0, y: 0, x2: 1, y2: 1, color: "#FF0000" }),
      { type: "line", x: 0, y: 0, x2: 1, y2: 1, color: "#FF0000" }
    );
    assert.deepEqual(
      toolToCommand("draw_rect", { x: 0, y: 0, w: 0.5, h: 0.5, filled: true }),
      { type: "rect", x: 0, y: 0, w: 0.5, h: 0.5, filled: true }
    );
    assert.deepEqual(
      toolToCommand("draw_circle", { x: 0.5, y: 0.5, radius: 0.1 }),
      { type: "circle", x: 0.5, y: 0.5, radius: 0.1 }
    );
  });

  it("rejects malformed input", () => {
    assert.throws(() => toolToCommand("set_background", { color: "not-a-color" }), z.ZodError);
    assert.throws(() => toolToCommand("draw_line", { x: 0, y: 0 }), z.ZodError);
    assert.throws(() => toolToCommand("draw_rect", { x: 0, y: 0, w: -1, h: 1 }), z.ZodError);
    assert.throws(() => toolToCommand("draw_path", { points: [[0, 0]] }), z.ZodError);
    assert.throws(() => toolToCommand("draw_text", { x: 0, y: 0, text: "" }), z.ZodError);
  });

  it("requires a hex-shaped color when supplied", () => {
    assert.throws(() => toolToCommand("draw_line", {
      x: 0, y: 0, x2: 1, y2: 1, color: "red",
    }), z.ZodError);
  });

  it("every tool has a non-empty description", () => {
    for (const name of toolNames) {
      assert.ok(tools[name].description.length > 0, `${name} missing description`);
    }
  });
});
