import { getStore } from "@netlify/blobs";
import { randomBytes, scryptSync, timingSafeEqual } from "node:crypto";

const store = getStore("room-work-global-settings");
const KEY = "site-config-v1";
const json = (body, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
});
const hashPin = (pin, salt) => scryptSync(pin, salt, 64).toString("hex");
const validPin = (pin, record) => {
  if (typeof pin !== "string" || !record?.pinHash || !record?.pinSalt) return false;
  const actual = Buffer.from(hashPin(pin, record.pinSalt), "hex");
  const expected = Buffer.from(record.pinHash, "hex");
  return actual.length === expected.length && timingSafeEqual(actual, expected);
};

export default async (request) => {
  try {
    if (request.method === "GET") {
      const record = await store.get(KEY, { type: "json" });
      return json({ ownerConfigured: !!record?.pinHash, config: record?.config || {} });
    }
    if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
    const body = await request.json();
    const record = await store.get(KEY, { type: "json" });

    if (body.action === "claim") {
      if (record?.pinHash) return json({ error: "The owner PIN has already been created. Unlock with the existing PIN." }, 409);
      if (typeof body.pin !== "string" || body.pin.length < 8) return json({ error: "Use an owner PIN with at least 8 characters." }, 400);
      const salt = randomBytes(16).toString("hex");
      const next = { pinSalt: salt, pinHash: hashPin(body.pin, salt), config: {} };
      try {
        await store.setJSON(KEY, next, { onlyIfNew: true });
      } catch {
        return json({ error: "Owner setup was claimed already. Reload and unlock with the owner PIN." }, 409);
      }
      return json({ ok: true });
    }

    if (!record?.pinHash) return json({ error: "Owner setup has not been completed yet." }, 409);
    if (!validPin(body.pin, record)) return json({ error: "Incorrect owner PIN." }, 401);

    if (body.action === "unlock") return json({ ok: true });
    if (body.action === "update") {
      const c = body.config || {};
      if (typeof c.url !== "string" || typeof c.key !== "string" || !c.url.startsWith("https://") || !c.key.trim()) {
        return json({ error: "A valid HTTPS Supabase URL and public anon/publishable key are required." }, 400);
      }
      const next = { ...record, config: { name: String(c.name || "Room Work").slice(0, 100), url: c.url.replace(/\/$/, ""), key: c.key.trim() } };
      await store.setJSON(KEY, next);
      return json({ ok: true, config: next.config });
    }
    return json({ error: "Unknown action." }, 400);
  } catch (error) {
    return json({ error: error?.message || "Server error" }, 500);
  }
};
