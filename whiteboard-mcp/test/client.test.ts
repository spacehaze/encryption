import { strict as assert } from "node:assert";
import { describe, it } from "node:test";

import { createClient, type Fetch } from "../src/client.js";

function stubFetch(status: number, body = ""): Fetch & { calls: Array<{ url: string; init?: RequestInit }> } {
  const stub = async (url: string | URL | Request, init?: RequestInit) => {
    stub.calls.push({ url: String(url), init });
    return new Response(body, { status });
  };
  stub.calls = [] as Array<{ url: string; init?: RequestInit }>;
  return stub as unknown as Fetch & { calls: Array<{ url: string; init?: RequestInit }> };
}

describe("WhiteboardClient", () => {
  it("POSTs JSON to /command with the configured endpoint", async () => {
    const fetchStub = stubFetch(200, "ok");
    const client = createClient("http://127.0.0.1:9999", fetchStub);
    await client.postCommand({ type: "clear" });
    assert.equal(fetchStub.calls.length, 1);
    assert.equal(fetchStub.calls[0].url, "http://127.0.0.1:9999/command");
    assert.equal(fetchStub.calls[0].init?.method, "POST");
    assert.equal(
      (fetchStub.calls[0].init?.headers as Record<string, string>)["Content-Type"],
      "application/json"
    );
    assert.equal(fetchStub.calls[0].init?.body, '{"type":"clear"}');
  });

  it("throws an informative error on non-2xx", async () => {
    const fetchStub = stubFetch(500, "boom");
    const client = createClient("http://127.0.0.1:9999", fetchStub);
    await assert.rejects(
      () => client.postCommand({ type: "clear" }),
      /returned 500: boom/
    );
  });
});
