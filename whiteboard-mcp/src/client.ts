/**
 * Thin HTTP client for the Whiteboard app's local command endpoint.
 * Factored out of `index.ts` so tests can stub it without touching the
 * MCP server wiring.
 */
export const DEFAULT_ENDPOINT = "http://127.0.0.1:7017";

export type Fetch = typeof fetch;

export interface WhiteboardClient {
  postCommand(body: unknown): Promise<string>;
}

export function createClient(
  endpoint: string = process.env.WHITEBOARD_ENDPOINT ?? DEFAULT_ENDPOINT,
  fetchImpl: Fetch = fetch
): WhiteboardClient {
  return {
    async postCommand(body) {
      const response = await fetchImpl(`${endpoint}/command`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const text = await response.text();
      if (!response.ok) {
        throw new Error(`whiteboard app returned ${response.status}: ${text}`);
      }
      return text;
    },
  };
}
