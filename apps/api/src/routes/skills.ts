import { Hono } from "hono";
import { getCookie, setCookie } from "hono/cookie";
import { drizzle } from "drizzle-orm/d1";
import { getMasterKey } from "./middleware/auth";
import { skills, type Skill } from "../db/schema";
import { eq, desc, and, like, or } from "drizzle-orm";
import { z } from "zod";

export const skillsRoutes = new Hono();

skillsRoutes.get("/skills", async (c) => {
  const db = drizzle(c.env.DB);
  const category = c.req.query("category");
  const search = c.req.query("search");
  const page = parseInt(c.req.query("page") || "1");
  const limit = parseInt(c.req.query("limit") || "20");
  const offset = (page - 1) * limit;

  try {
    let query = db.select().from(skills).orderBy(desc(skills.featured), desc(skills.installs));

    if (category) {
      query = query.where(eq(skills.category, category as any));
    }

    if (search) {
      query = query.where(
        or(
          like(skills.title, `%${search}%`),
          like(skills.description, `%${search}%`),
          like(skills.author, `%${search}%`)
        )
      ) as any;
    }

    const results = await query.limit(limit).offset(offset);
    const totalResult = await db.select({ count: skills.id }).from(skills).limit(1);
    const total = totalResult.length;

    return c.json({
      success: true,
      data: results,
      meta: {
        page,
        limit,
        total,
        lastPage: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error("Error fetching skills:", error);
    return c.json({ success: false, error: "Failed to fetch skills" }, 500);
  }
});

skillsRoutes.get("/skills/:id", async (c) => {
  const db = drizzle(c.env.DB);
  const id = c.req.param("id");

  try {
    const skill = await db.select().from(skills).where(eq(skills.id, id)).limit(1);

    if (skill.length === 0) {
      return c.json({ success: false, error: "Skill not found" }, 404);
    }

    return c.json({ success: true, data: skill[0] });
  } catch (error) {
    console.error("Error fetching skill:", error);
    return c.json({ success: false, error: "Failed to fetch skill" }, 500);
  }
});

skillsRoutes.get("/skills/featured/list", async (c) => {
  const db = drizzle(c.env.DB);

  try {
    const featured = await db
      .select()
      .from(skills)
      .where(eq(skills.featured, true))
      .orderBy(desc(skills.installs))
      .limit(6);

    return c.json({ success: true, data: featured });
  } catch (error) {
    console.error("Error fetching featured skills:", error);
    return c.json({ success: false, error: "Failed to fetch featured skills" }, 500);
  }
});

skillsRoutes.get("/categories", async (c) => {
  const db = drizzle(c.env.DB);

  try {
    const categories = [
      "design",
      "engineering",
      "data",
      "writing",
      "product",
      "business",
      "education",
      "science",
      "ai",
      "community",
    ] as const;

    const result = await Promise.all(
      categories.map(async (cat) => {
        const count = await db
          .select({ count: skills.id })
          .from(skills)
          .where(eq(skills.category, cat))
          .limit(1);
        return { slug: cat, count: count.length };
      })
    );

    return c.json({ success: true, data: result });
  } catch (error) {
    console.error("Error fetching categories:", error);
    return c.json({ success: false, error: "Failed to fetch categories" }, 500);
  }
});