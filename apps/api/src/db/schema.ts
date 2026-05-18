import { drizzle } from "drizzle-orm/d1";
import { text, integer, sqliteTable } from "drizzle-orm/sqlite-core";

export const skills = sqliteTable("skills", {
  id: text("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description").notNull(),
  category: text("category", {
    enum: ["design", "engineering", "data", "writing", "product", "business", "education", "science", "ai", "community"]
  }).notNull(),
  tags: text("tags").default("[]"),
  author: text("author").notNull(),
  authorUrl: text("author_url"),
  skillUrl: text("skill_url").notNull(),
  featured: integer("featured", { mode: "boolean" }).default(false),
  installs: integer("installs").default(0),
  stars: integer("stars").default(0),
  publishDate: text("publish_date").notNull(),
  createdAt: text("created_at").notNull(),
  updatedAt: text("updated_at").notNull(),
});

export type Skill = typeof skills.$inferSelect;
export type NewSkill = typeof skills.$inferInsert;