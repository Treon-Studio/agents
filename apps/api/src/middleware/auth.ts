import { Context } from "hono";

export function getMasterKey(c: Context): string | null {
  return getCookie(c, "master_key") || c.req.header("x-master-key") || null;
}

export function isValidMasterKey(c: Context, validKey: string): boolean {
  const key = getMasterKey(c);
  return key === validKey;
}