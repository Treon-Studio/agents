# Hunivo — AI Agent Context (Single Source of Truth)

<purpose>
Hunivo — Indonesian property management SaaS (kos/kontrakan/apartemen).
Multi-tenant via workspaces. Core flow: Property → Room → Tenant → Lease → Billing → Payment.
Full docs: [docs/PRD.md](docs/PRD.md) | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | [CODING_STANDARDS.md](CODING_STANDARDS.md)
</purpose>

<onboarding_order>
When asked to understand, scan, or onboard to this repo, ALWAYS follow this order:

**Step 0 — Check Knowledge Items (KI)**
Look for existing KI at `~/.gemini/antigravity/knowledge/hunivo_repo_context/`.
- If KI exists → Read `artifacts/repo_understanding.md` and use it as your base context. Skip to Step 4 (source code) only if you need to verify something specific.
- If KI does NOT exist → Continue to Step 1.

**Step 1 — Context files FIRST**
Read `AGENTS.md` (this file) and `CODING_STANDARDS.md`. These contain core rules. Then check `.opencode/context/project/` and `.opencode/context/development/` for domain-specific guidelines (architecture, backend, frontend rules). (Note: All AI configurations are stored in `.opencode/`, replacing the legacy `.claude` folder).

**Step 2 — Knowledge graph**
Read `graphify-out/GRAPH_REPORT.md` — focus on the Summary, God Nodes, and Surprising Connections sections. Skip the 1000+ community list.

**Step 3 — Documentation**
Read `docs/ARCHITECTURE.md` and `docs/PRD.md` for business logic and API specs.

**Step 4 — Source code LAST**
Only explore `apps/`, `packages/`, `platforms/` to verify or deepen understanding.

**Step 5 — Create/Update KI**
After onboarding, if no KI existed, create one at `~/.gemini/antigravity/knowledge/hunivo_repo_context/` with `metadata.json` + `artifacts/repo_understanding.md` containing distilled knowledge. This saves tokens for future conversations.

NEVER start by scanning raw source directories. The context files and KI exist specifically to save time.
</onboarding_order>

<tech_stack>
| Layer | Stack |
|-------|-------|
| Package manager | pnpm@10 with workspaces |
| API | Hono, Cloudflare Workers, D1 (SQLite), Drizzle ORM |
| Web | Astro 5 (SSR), React 19 islands, Axios, TailwindCSS 4 |
| Mobile | Expo 54, React Native 0.81, Expo Router 6, HeroUI Native, Uniwind |
| State | Zustand 5 (client), React Query 5 (server) |
| Auth | JWT (HS256, 15min access + 7d refresh), RBAC with 4 roles |
| Linting | Biome 2 (formatter + linter) |
| Icons | react-icons/io5 (web), @expo/vector-icons (mobile) |
| Validation | Zod |
</tech_stack>

<project_structure>
```
apps/
  api/            # Hono API + Cloudflare Workers + D1
  web/            # Astro 5 + React 19 islands
  app/            # Expo 54 mobile app

packages/
  api-types/      # Zod schemas + TS types (shared contract)
  api-services/   # Service factories: createApiServices(apiClient)
  api-hooks/      # React Query hooks
  http/           # HTTP client abstraction (fetch & axios)
  ui/             # Web UI components (Radix)
  stores/         # Zustand stores
  hooks/          # Custom React hooks
  data/           # Constants (features, icons, labels)
  utils/          # Utilities (pagination, classnames)
  types/          # Shared TS types

platforms/
  auth/           # Auth components
  house-rent/     # Core property management UI
  notifications/  # Notification system
  settings/       # Settings UI
  chats/          # Chat/messaging
```
</project_structure>

<critical_conventions>
  <do_rules>
  - Use `@treonstudio/*` package imports (never relative cross-package)
  - Use React Query hooks for all server data
  - Use Zustand for client-only state
  - Use SQL arithmetic for counter updates (`sql\`col + 1\``)
  - Filter every DB query by `workspaceId`
  - Use `generateId()` (cuid2) for all IDs
  - Use Zod schemas from `@treonstudio/api-types` for validation
  - Run `pnpm check` before committing
  - Keep middleware order: `auth() → workspaceScope() → featureGate() → rbac()`
  </do_rules>

  <dont_rules>
  - Use `useState + useEffect + fetch` for API data
  - Use `uuid` for IDs
  - Skip workspace scoping in DB queries
  - Put `rbac()` in global middleware
  - Hardcode config values (use env vars)
  - Use `lucide-react` or `@remixicon/react` (use `react-icons/io5`)
  - Read-then-write counters (race condition)
  - Create duplicate validation logic in frontend and backend
  </dont_rules>
</critical_conventions>

<database_rules>
- **IDs**: Always `generateId()` (cuid2). Never uuid.
- **Workspace scoping**: EVERY query filters by `workspaceId`. No exceptions.
- **Counter updates**: SQL arithmetic only (`sql\`col + 1\``). Never read-then-write.
- **Soft delete**: Only rooms use `deletedAt`. Always add `WHERE deletedAt IS NULL`.
- **Timestamps**: `new Date().toISOString()` for both `createdAt` and `updatedAt`.
</database_rules>

<api_rules>
- **Response shape**: Always `{ success: true, data }` or `{ success: false, error, code? }`.
- **Middleware order**: `auth() → workspaceScope() → featureGate("code")` global, `rbac([...])` per endpoint.
- **Routes base**: `/api/v1/...`
</api_rules>

<business_constraints>
- `billingDay`: 1–28 only
- `billingPeriod`: format `YYYY-MM`
- Cannot delete property with occupied rooms
- Cannot delete active tenants
- Cannot cancel billing if `paidAmount > 0`
- Lease CREATE = insert + room→occupied + occupiedRooms++ + tenant→active
- Lease END = ended + room→available + occupiedRooms-- + return addons
- Payment (cash): instant confirm; Payment (non-cash): pending until confirm
</business_constraints>

<documentation_sync>
When making code changes, update corresponding docs **in the same session**:
- DB schema → `docs/PRD.md` §3
- Business logic → `docs/PRD.md` §4 + `AGENTS.md`
- API endpoints → `docs/PRD.md` §7
- Patterns/middleware → `docs/ARCHITECTURE.md`
- New packages → `AGENTS.md` + `docs/ARCHITECTURE.md`
</documentation_sync>

<adding_new_feature>
1. DB Schema (`apps/api/src/db/schema/`)
2. Generate migration (`pnpm drizzle-kit generate`)
3. Create route (`apps/api/src/routes/`)
4. Register route (`apps/api/src/index.ts`)
5. Zod schemas (`packages/api-types/src/`)
6. Service factory (`packages/api-services/src/`)
7. Query keys (`packages/api-hooks/src/query-keys.ts`)
8. React Query hooks (`packages/api-hooks/src/`)
9. Feature gate config (`packages/data/src/features.ts`)
10. UI implementation (web island or mobile screen)
</adding_new_feature>

<common_commands>
```bash
pnpm dev                            # API (8787) + Web (4321)
pnpm dev:landing                    # Landing page only
pnpm check                          # Biome lint + format (auto-fix)
cd apps/api && pnpm drizzle-kit generate # Gen DB Migration
POST http://localhost:8787/api/v1/dev/seed  # Seed database
```
</common_commands>

<test_accounts>
| Role | Phone | Password |
|------|-------|----------|
| Super Admin | 81200000001 | superadmin123 |
| Owner | 81200000002 | owner123 |
| Admin | 81200000003 | admin123 |
| Staff | 81200000004 | staff123 |

Login via phone number (without +62 prefix).
</test_accounts>

<graphify>
This project has a graphify knowledge graph at `graphify-out/`.

Rules:
- Before answering architecture or codebase questions, read `graphify-out/GRAPH_REPORT.md`
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
</graphify>

<autonomous_agent_memory>
**Rule for AI Agents:** If you are executing an autonomous loop and learn a new CLI command, a missing dependency issue, or an architectural gotcha that is not documented here, **you MUST update this `AGENTS.md` file autonomously** to add that knowledge under the relevant section. This ensures future loops don't repeat your mistakes.
</autonomous_agent_memory>
