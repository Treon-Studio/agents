import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { skillsRoutes } from "./routes/skills";

const app = new Hono();

app.use("*");
app.use(cors());
app.use(logger());

app.get("/health", (c) => c.json({ status: "ok", timestamp: new Date().toISOString() }));

app.route("/api/v1", skillsRoutes);

app.notFound((c) => c.json({ success: false, error: "Not Found" }, 404));
app.onError((c, err) => {
  console.error(err);
  return c.json({ success: false, error: "Internal Server Error" }, 500);
});

export default app;