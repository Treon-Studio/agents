import { Hono } from "hono";
import { drizzle } from "drizzle-orm/d1";
import { nanoid } from "nanoid";
import { skills } from "./db/schema";

const seedData = [
  {
    id: "react-doctor",
    title: "React Doctor",
    description: "Run React Doctor to detect regressions in security, performance, correctness, and architecture.",
    category: "engineering" as const,
    tags: JSON.stringify(["react", "performance", "security", "audit"]),
    author: "millionco",
    authorUrl: "https://million.dev",
    skillUrl: "https://www.ui-skills.com/skills/millionco/react-doctor",
    featured: true,
    installs: 1600000,
    stars: 18900,
    publishDate: "2026-01-15T00:00:00Z",
  },
  {
    id: "frontend-design",
    title: "Frontend Design",
    description: "Expert frontend design guidance covering UI/UX principles, component architecture, and accessibility.",
    category: "design" as const,
    tags: JSON.stringify(["design", "ui", "ux", "frontend"]),
    author: "anthropics",
    authorUrl: "https://anthropic.com",
    skillUrl: "https://www.ui-skills.com/skills/anthropics/frontend-design",
    featured: true,
    installs: 422600,
    stars: 12500,
    publishDate: "2026-01-10T00:00:00Z",
  },
  {
    id: "vercel-react-best-practices",
    title: "Vercel React Best Practices",
    description: "Learn Vercel's recommended patterns for building React applications with optimal performance.",
    category: "engineering" as const,
    tags: JSON.stringify(["react", "vercel", "best-practices", "performance"]),
    author: "vercel-labs",
    authorUrl: "https://vercel.com",
    skillUrl: "https://www.ui-skills.com/skills/vercel-labs/react-best-practices",
    featured: true,
    installs: 405400,
    stars: 9800,
    publishDate: "2026-01-12T00:00:00Z",
  },
  {
    id: "web-design-guidelines",
    title: "Web Design Guidelines",
    description: "Comprehensive web design guidelines covering typography, color theory, spacing, and responsive design.",
    category: "design" as const,
    tags: JSON.stringify(["design", "web", "guidelines", "typography"]),
    author: "vercel-labs",
    authorUrl: "https://vercel.com",
    skillUrl: "https://www.ui-skills.com/skills/vercel-labs/web-design-guidelines",
    featured: true,
    installs: 325000,
    stars: 8700,
    publishDate: "2026-01-08T00:00:00Z",
  },
  {
    id: "microsoft-foundry",
    title: "Microsoft Foundry",
    description: "Integrate Microsoft Foundry services for enterprise AI workflows and automation.",
    category: "ai" as const,
    tags: JSON.stringify(["microsoft", "foundry", "enterprise", "ai"]),
    author: "microsoft",
    authorUrl: "https://microsoft.com",
    skillUrl: "https://www.ui-skills.com/skills/microsoft/foundry",
    featured: false,
    installs: 323800,
    stars: 7600,
    publishDate: "2026-01-20T00:00:00Z",
  },
  {
    id: "azure-devops",
    title: "Azure DevOps",
    description: "Automate Azure DevOps workflows including CI/CD pipelines, resource management, and deployments.",
    category: "engineering" as const,
    tags: JSON.stringify(["azure", "devops", "ci-cd", "automation"]),
    author: "microsoft",
    authorUrl: "https://microsoft.com",
    skillUrl: "https://www.ui-skills.com/skills/microsoft/azure-devops",
    featured: false,
    installs: 310000,
    stars: 6900,
    publishDate: "2026-01-18T00:00:00Z",
  },
  {
    id: "azure-openai-sdk",
    title: "Azure OpenAI SDK",
    description: "Seamlessly integrate Azure OpenAI services with advanced prompting and model management.",
    category: "ai" as const,
    tags: JSON.stringify(["azure", "openai", "llm", "ai"]),
    author: "microsoft",
    authorUrl: "https://microsoft.com",
    skillUrl: "https://www.ui-skills.com/skills/microsoft/azure-openai-sdk",
    featured: false,
    installs: 290000,
    stars: 5800,
    publishDate: "2026-01-22T00:00:00Z",
  },
  {
    id: "data-pipeline-builder",
    title: "Data Pipeline Builder",
    description: "Create and manage ETL data pipelines with visual workflow builder and scheduling.",
    category: "data" as const,
    tags: JSON.stringify(["etl", "pipeline", "data-engineering"]),
    author: "dataplate",
    authorUrl: "https://dataplate.io",
    skillUrl: "https://www.ui-skills.com/skills/dataplate/pipeline-builder",
    featured: false,
    installs: 314500,
    stars: 7200,
    publishDate: "2026-02-01T00:00:00Z",
  },
  {
    id: "ai-content-analyzer",
    title: "AI Content Analyzer",
    description: "Analyze and optimize content for readability, SEO, and engagement using advanced AI.",
    category: "ai" as const,
    tags: JSON.stringify(["seo", "content", "writing", "optimization"]),
    author: "contentai",
    authorUrl: "https://contentai.tools",
    skillUrl: "https://www.ui-skills.com/skills/contentai/analyzer",
    featured: true,
    installs: 265000,
    stars: 5400,
    publishDate: "2026-02-10T00:00:00Z",
  },
  {
    id: "product-roadmap-planner",
    title: "Product Roadmap Planner",
    description: "Strategic product planning tool for creating and managing product roadmaps.",
    category: "product" as const,
    tags: JSON.stringify(["roadmap", "planning", "strategy"]),
    author: "roadmaptools",
    authorUrl: "https://roadmap.tools",
    skillUrl: "https://www.ui-skills.com/skills/roadmaptools/planner",
    featured: false,
    installs: 245000,
    stars: 4800,
    publishDate: "2026-02-15T00:00:00Z",
  },
];

const app = new Hono();

app.get("/seed", async (c) => {
  const db = drizzle(c.env.DB);

  try {
    for (const skill of seedData) {
      await db.insert(skills).values({
        ...skill,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });
    }

    return c.json({
      success: true,
      message: `Seeded ${seedData.length} skills successfully`,
    });
  } catch (error) {
    console.error("Seed error:", error);
    return c.json({ success: false, error: "Seed failed" }, 500);
  }
});

export default app;