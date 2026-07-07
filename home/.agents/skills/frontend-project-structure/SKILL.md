---
name: frontend-project-structure
description: Default project structure, tooling, and library choices for frontend web apps (Vue 3 + Vite + TypeScript + Tailwind, deployed to Cloudflare Workers). Use this skill whenever scaffolding a new frontend project or SPA, adding tooling to one (linting, formatting, testing, CI, PWA, deployment), restructuring an existing frontend repo, or deciding which library or pattern to use for state, routing, charts, styling, or backend logic — even if the user doesn't explicitly ask for "the default structure".
---

# Frontend Project Structure

The default structure for new frontend projects. Follow it unless the project has a
concrete reason to deviate; when deviating, keep the tooling layer (pnpm, oxlint/oxfmt,
vue-tsc, vitest, CI) identical so all projects stay uniform to work in.

## Core stack

Every project uses:

| Concern | Choice |
|---|---|
| Framework | Vue 3, Composition API, `<script setup lang="ts">` SFCs |
| Language | TypeScript, strict |
| Build | Vite (rolldown-based) + `@vitejs/plugin-vue` |
| Styling | Tailwind CSS v4 via `@tailwindcss/vite` |
| Lint/format | oxlint + oxfmt (never ESLint/Prettier) |
| Type check | `vue-tsc --noEmit` |
| Tests | vitest, colocated `*.test.ts` |
| Package manager | pnpm, with `pnpm-workspace.yaml` + catalog even for single-package repos |
| Hosting | Cloudflare Workers (wrangler) with static assets + SPA fallback |
| CI | GitHub Actions: lint, test, per-PR preview deploy, deploy on main |
| Tool versions | `mise.toml` pinning node, pnpm, and prek |

Do not pin the specific versions from this document; use current versions.

## Repository layout

```
project/
├── index.html                  # Entry HTML
├── vite.config.ts
├── tsconfig.json
├── wrangler.jsonc              # At root for static-only projects; in worker/ when a worker exists
├── pnpm-workspace.yaml         # Declares packages + catalog (typescript, oxlint, oxfmt)
├── mise.toml                   # node + pnpm versions
├── .oxlintrc.json
├── .oxfmtrc.json
├── .editorconfig               # 2-space indent, LF, UTF-8, final newline
├── .pre-commit-config.yaml     # standard hooks + lint:fix + type-check + test (run via prek)
├── .env.example                # Env var template (only when env vars exist); other .env* gitignored
├── .claude/launch.json         # dev/preview launch configs (pnpm, project ports, autoPort)
├── .github/workflows/ci.yml
├── public/
│   ├── logo.svg                # Source for PWA asset generation
│   └── _headers                # Cache headers (see Deployment)
├── src/                        # See src layout below
└── worker/                     # Optional: Cloudflare Worker backend (separate workspace package)
    ├── package.json
    ├── wrangler.jsonc
    └── src/index.ts
```

Only `.env.example` is committed — `.env.development`, `.env.production`, and any other
`.env*` files stay in `.gitignore`; CI builds receive their values as `VITE_*` secrets.
Projects with no build-time env vars skip `.env*` files entirely.

`pnpm-workspace.yaml` also carries the `allowBuilds` allowlist for dependency build
scripts (e.g. `esbuild: false`, `sharp: false`, `workerd: true`) and `publicHoistPattern`
where a dependency needs it (e.g. `workbox-*`).

`mise.toml` pins node, pnpm, and prek, and defines a `[tasks.setup]` task running
`prek install`. The README contains a setup section with exactly this flow:

```sh
mise trust && mise install   # toolchain (node, pnpm, prek)
mise setup                   # install the pre-commit hooks
pnpm install
```

Architecture decisions worth recording go into lightweight ADRs under `docs/adr/`.

### src/ layout

```
src/
├── main.ts                     # createApp → pinia → router → PWA update hook → mount("#app")
├── App.vue                     # Root; conditional layout (shell vs bare) via route.meta.layout
├── style.css                   # Tailwind import + @theme design tokens
├── vite-env.d.ts               # Declares __BUILD_DATE__, __BUILD_SHA__
├── components/                 # PascalCase.vue; group by domain (ui/, layout/, <feature>/)
├── composables/                # use* prefix (useSettings.ts, usePWAUpdate.ts, ...)
├── views/                      # Route-level components, named <Domain>View.vue
├── router/index.ts
├── stores/                     # Pinia stores, one file per domain (settings.ts, ...)
├── lib/                        # Framework-free business logic, organized by domain
├── api/                        # API clients, one module per data source
├── types/                      # Shared types; generated types live here too
└── sw.ts                       # Only with injectManifest PWA strategy
```

Conventions:
- Components PascalCase, composables `use*` camelCase, views `*View.vue`.
- Tests colocated: `foo.test.ts` next to `foo.ts`. No `__tests__` directories.
- Business logic lives in `lib/` (or `analysis/`, `derive/` etc. by domain) as pure
  functions with no Vue imports — this is what gets unit-tested; components mostly don't.
- Path alias `@/*` → `./src/*`, declared only in tsconfig. Vite picks it up via
  `resolve: { tsconfigPaths: true }` — never duplicate the alias in `resolve.alias`.

## TypeScript

`tsconfig.json` extends `@vue/tsconfig/tsconfig.dom.json` and adds the strictness flags:

```json
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "compilerOptions": {
    "isolatedModules": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "types": [],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src", "src/**/*.vue", "vite.config.ts"]
}
```

With an `injectManifest` service worker (`src/sw.ts`), add
`"lib": ["DOM", "DOM.Iterable", "ESNext", "WebWorker"]` so the worker globals type-check.

## Linting & formatting

oxlint and oxfmt replace ESLint and Prettier entirely — they are Rust-based and fast
enough to run on every commit and in the `lint` script together with vue-tsc.

`pnpm lint` must pass completely clean in every repo — zero errors and zero warnings.
Fix warnings, or disable the rule with a justification in `.oxlintrc.json`; never leave
warnings standing.

`.oxlintrc.json` (extend `ignorePatterns` with generated files and directories the web
lint should not cover, e.g. `worker`, `data`, generated `*.d.ts`):

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["eslint", "typescript", "unicorn", "oxc", "import", "vue"],
  "categories": {
    "correctness": "error",
    "suspicious": "warn",
    "perf": "warn"
  },
  "rules": {
    "consistent-function-scoping": "off",
    "import/no-unassigned-import": ["warn", { "allow": ["**/*.css"] }],
    "no-console": "off",
    "no-underscore-dangle": "off"
  },
  "env": {
    "builtin": true,
    "browser": true,
    "vue": true
  },
  "ignorePatterns": ["dist"]
}
```

`.oxfmtrc.json`:

```json
{
  "$schema": "./node_modules/oxfmt/configuration_schema.json",
  "printWidth": 180,
  "sortImports": true,
  "sortPackageJson": true,
  "sortTailwindcss": true
}
```

## package.json scripts

Keep script names identical across projects so muscle memory and CI transfer:

```jsonc
{
  "dev": "vite",
  "build": "vite build",
  "preview": "vite preview",
  "test": "vitest run",
  "test:watch": "vitest",
  "type-check": "vue-tsc --noEmit",
  "lint": "oxlint && oxfmt --check && vue-tsc",
  "lint:fix": "oxlint --fix && oxfmt --write",
  "deploy": "pnpm build && wrangler deploy",
  "deploy:preview": "pnpm build && wrangler versions upload --preview-alias preview-$(git rev-parse --short=8 HEAD)"
}
```

With a worker package, split into `lint:web` / `lint:worker` (and `lint:fix:*`) where the
root `lint` runs both, `dev:worker` runs the worker locally, and `deploy` builds the web
app then runs `pnpm --filter <name>-worker deploy`.

## Vite config

Standard elements of `vite.config.ts`:

```ts
/// <reference types="vitest/config" />
import { execSync } from "node:child_process";

import tailwindcss from "@tailwindcss/vite";
import vue from "@vitejs/plugin-vue";
import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";

const buildDate = new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
let buildSha = "dev";
try {
  buildSha = execSync("git rev-parse --short HEAD").toString().trim();
} catch {
  // not a git checkout (e.g. tarball build)
}

// The preview harness hands the port chosen in .claude/launch.json to Vite
const port = process.env.PORT ? Number(process.env.PORT) : undefined;

export default defineConfig({
  server: { port, strictPort: port !== undefined },
  preview: { port, strictPort: port !== undefined },
  plugins: [
    vue(),
    tailwindcss(),
    VitePWA({ /* see PWA section */ }),
  ],
  resolve: {
    tsconfigPaths: true,
  },
  define: {
    __BUILD_DATE__: JSON.stringify(buildDate),
    __BUILD_SHA__: JSON.stringify(buildSha),
  },
  build: {
    // Vite runs on Rolldown, where the object form of manualChunks is gone;
    // codeSplitting.groups is its replacement. Captured modules pull in their
    // deps by default. Add groups for heavy deps (charts, icons, sdks) between
    // vue and analytics, priorities 30-50. Skip the whole block when no heavy
    // dep sits in the SPA graph. If a heavy chunk legitimately exceeds the
    // size warning, bump chunkSizeWarningLimit with a comment justifying it.
    rolldownOptions: {
      // Silence @vueuse/core's misplaced /* #__PURE__ */ annotation warning
      onLog(level, log, handler) {
        if (log.code === "INVALID_ANNOTATION" && log.id?.includes("@vueuse/core")) return;
        handler(level, log);
      },
      output: {
        codeSplitting: {
          groups: [
            { name: "vue", test: /@vue|vue-router|pinia|@vueuse/, priority: 60 },
            { name: "analytics", test: /posthog/, priority: 20 },
            { name: "vendor", test: /node_modules/, priority: 10 },
            // No src catch-all group — it folds lazily-imported views back into
            // a single chunk, silently defeating route-level code splitting.
          ],
        },
      },
    },
  },
  test: {
    environment: "jsdom", // "node" if no DOM is touched in tests
    include: ["src/**/*.test.ts"],
  },
});
```

`__BUILD_DATE__` and `__BUILD_SHA__` are shown in the app footer/about for build
transparency; declare them in `vite-env.d.ts`.

Commit a `.claude/launch.json` so the preview harness can start the app. The harness
passes the actual port via `PORT`, which the `server`/`preview` blocks above honor with
`strictPort`. Use project-specific default ports and exactly this format:

```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "dev",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["run", "dev"],
      "port": 5183,
      "autoPort": true
    },
    {
      "name": "preview",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["run", "preview"],
      "port": 5184,
      "autoPort": true
    }
  ]
}
```

Gitignore the rest of `.claude/` (`.claude/*` + `!.claude/launch.json`).

## Styling

- Tailwind v4 via the Vite plugin — no `tailwind.config.js`, no preprocessor, no CSS-in-JS.
- Define a project design system as `@theme` tokens in the global stylesheet: custom
  color palettes (e.g. background/ink/accent scales) and font families. Components use
  Tailwind utilities referencing those tokens; `<style scoped>` only for what utilities
  can't express.
- Self-host fonts with `@fontsource-variable/*` packages.
- Dark mode: `.dark` class on `<html>`, toggled via a settings store and persisted to
  localStorage, with `@custom-variant dark (&:where(.dark, .dark *));`. Single-theme
  apps (e.g. dark-only) skip the toggle machinery and just hardcode the palette plus
  `color-scheme: dark`.
- UI components are custom by default. Some older projects use PrimeVue for form/CRUD-heavy
  UIs — do not use it for new projects because of the licensing change planned for
  PrimeVue 5; build on Tailwind-styled custom components instead.

### @nuxt/ui variation

For component-heavy apps, `@nuxt/ui` v4 is a sanctioned alternative to custom
components. It changes several defaults at once:

- Tailwind comes through the `ui()` plugin from `@nuxt/ui/vite` — drop `@tailwindcss/vite`
  (keep the `tailwindcss` package itself; the CSS import resolves from it); the stylesheet
  imports `@import "tailwindcss"; @import "@nuxt/ui";`.
- Theming is configured on the plugin (`ui({ ui: { colors: { ... } } })`) instead of
  `@theme` tokens; dark mode uses Nuxt UI's color-mode system.
- Icons come from Iconify (`@iconify-json/fa6-solid` etc., used as `icon="fa6-solid:..."`)
  instead of fontawesome + `library.add()` — migrate any existing fontawesome usage fully
  rather than running two icon systems. Note: in Vue-plugin mode Nuxt UI resolves icons
  at runtime via `api.iconify.design` rather than embedding SVGs in the bundle; the
  `@iconify-json/*` packages provide names and dev-mode resolution.
- Auto-imports generate `auto-imports.d.ts` and `components.d.ts` — add both to the
  tsconfig `include` and to the oxlint/oxfmt `ignorePatterns`.
- Add codeSplitting groups `ui` (priority 50) and `icons` (priority 40) for the
  Nuxt UI/Reka and Iconify modules.

## State & routing

Scale state management to the app — don't default to a store:

1. Single-view tool → local `ref`/`computed` in the component.
2. Shared state, one domain → composables with module-level state (singleton pattern),
   `useLocalStorage` from `@vueuse/core` for persisted settings.
3. Multiple domains (settings + data lifecycle, auth + entities) → Pinia, one store per
   domain, setup-style (`ref`/`computed` inside `defineStore`). Use `shallowRef` for
   large immutable datasets to avoid deep-reactivity overhead. IndexedDB for large
   persisted data; localStorage only for small settings. When the domains are data
   pipelines rather than interactive entities, composables plus dedicated storage
   modules (versioned IndexedDB/localStorage stores) are a valid alternative to Pinia.

Routing, similarly: no router for single-view apps. Otherwise vue-router with:
- Lazy-loaded views (dynamic `import()`), except the landing view.
- `meta: { requiresAuth }` / `meta: { requiresData }` guards in a global `beforeEach`.
- `meta: { layout: "bare" }` to opt out of the app shell (checked in `App.vue`).
- History mode: `createWebHistory` normally; `createWebHashHistory` only if the app must
  work from `file://` or purely static hosting without rewrites.

`@vueuse/core` is a default dependency — reach for it before writing a custom composable.

## PWA (default for user-facing apps)

`vite-plugin-pwa` + `@vite-pwa/assets-generator`:

- `registerType: "prompt"` — the user decides when to update. Pair with a
  `usePWAUpdate` composable exposing `needRefresh` and an update function, and a
  `PWAUpdateBar` component that shows the prompt. For read-only apps (dashboards,
  viewers) where a mid-session reload can't lose user state,
  `usePWAUpdate({ autoUpdate: true })` without the bar is acceptable.
- Assets generated from `public/logo.svg` with the `2023` preset: transparent 64/192/512
  (+ 48px favicon), maskable 512, apple 180 — maskable/apple padded ~0.15 with the theme
  background color.
- Workbox `runtimeCaching` tuned per asset class: `CacheFirst` with expiration for
  static/third-party assets (tiles, images, models), `NetworkFirst` or
  `StaleWhileRevalidate` with short maxAge for data APIs. Never precache or cache
  user-imported data.
- Default strategy is `generateSW`; switch to `injectManifest` with a custom `src/sw.ts`
  only when the service worker needs custom logic (e.g. BroadcastChannel messages to the
  client when cached API data changes).

Skip PWA entirely for internal tools where offline/installability adds nothing.

## Backend logic (the "worker" variation)

Frontend-only is the default: `wrangler.jsonc` at the repo root serving `./dist` as
static assets, no server code.

When server-side logic is needed (CORS proxy, scraping, secret-holding API calls,
enrichment), add a Cloudflare Worker as a separate pnpm workspace package in `worker/`:

- Own `package.json` (wrangler, oxlint, typescript from the catalog) and `wrangler.jsonc`.
- `wrangler.jsonc` binds `../dist` as the `ASSETS` binding with
  `"not_found_handling": "single-page-application"`, sets the custom domain, and uses
  `run_worker_first` for the API routes (e.g. `/proxy`, `/api/*`) so everything else is
  served as static assets.
- Root scripts delegate via `pnpm --filter <name>-worker`.
- During development, proxy API paths in the Vite dev server to the local worker
  (`wrangler dev`, typically port 8787). Defaulting the proxy target to the production
  API (`process.env.API_PROXY ?? "https://<prod-domain>"`) lets `pnpm dev` work without
  running the worker locally.

Workers can grow beyond proxying: KV bindings for caching, cron `triggers` for scheduled
refresh, and codegen steps are all fine. Test workers with
`@cloudflare/vitest-pool-workers`, and give the worker package its own `.oxlintrc.json`
and `.oxfmtrc.json` (no `vue` plugin, no `sortTailwindcss`).

## Testing

vitest, configured in the `test` block of `vite.config.ts` (no separate config file).
Environment `jsdom` when tests touch the DOM, `node` otherwise. Focus tests on the pure
logic in `lib/`/`api/`/`composables/` — parsing, aggregation, formatting — not on
component rendering. Colocate as `*.test.ts`.

Two patterns for testing against real data without committing it: a smoke test over
gitignored local fixtures via `describe.skipIf(<no fixtures present>)`, and a dev-only
Vite plugin (`apply: "serve"`) that serves sample files from a gitignored `data/`
directory so the app can be exercised with real inputs during development only.

## CI/CD & deployment

`.github/workflows/ci.yml` with four jobs (Node 24, `pnpm/action-setup`, `pnpm ci` —
a real pnpm command since pnpm 11, alias of `clean-install`; don't "correct" it to an
npm-ism). Pin all actions to commit SHAs with a version comment:

1. **lint** — `pnpm lint` (push + PR)
2. **test** — `pnpm test` (push + PR)
3. **preview** — PRs from the same repo only, needs lint+test: build (with `VITE_*`
   secrets), `wrangler versions upload --preview-alias preview-<short-sha>`, comment the
   preview URL on the PR (`cloudflare/wrangler-action`)
4. **deploy** — main branch only, needs lint+test: build and `wrangler deploy`

Secrets: `CLOUDFLARE_API_TOKEN` plus any `VITE_*` build-time vars (PostHog key etc.).

`public/_headers`:

```
/index.html
  Cache-Control: no-cache
/sw.js
  Cache-Control: no-cache
/assets/*
  Cache-Control: public, max-age=31536000, immutable
```

Pre-commit (`.pre-commit-config.yaml`): standard hygiene hooks (trailing-whitespace,
end-of-file-fixer, check-merge-conflict, check-added-large-files) plus local hooks
running `lint:fix`, `type-check`, and `test` on matching file types. Hooks run via
`prek` (a fast Rust pre-commit reimplementation), pinned in `mise.toml` and installed
by the `mise setup` task.

## Default library picks

Reach for these before evaluating alternatives:

| Need | Library |
|---|---|
| Composable utilities | `@vueuse/core` |
| Charts | `echarts` + `vue-echarts`; register only the needed modules in a dedicated `echartsSetup.ts` (tree-shaking), theme colors read from CSS variables so charts follow dark mode; keep echarts in its own lazy chunk |
| Icons | `@fortawesome/*` + `vue-fontawesome`, explicit `library.add()` for tree-shaking |
| Fonts | `@fontsource-variable/*` |
| ZIP read/write | `fflate` |
| CSV parsing | `papaparse` |
| Dates | `dayjs` (only when native `Date`/`Intl` isn't enough) |
| Analytics | `posthog-js` behind a `usePostHog` composable, key via `VITE_POSTHOG_KEY` |
| 3D / geospatial | `three` for generic 3D; CesiumJS + `satellite.js` for globes/orbits |

Analytics is opt-in per project; when present, initialize at router level and gate on
the env key existing plus the URL containing the project name
(`window.location.href.includes("<project>")`) — local dev sends nothing, while
production and preview deploys both report.

## Package upgrades

Only upgrade dependencies when explicitly asked — never as a side effect of another task.
When asked:

- `pnpm update -r` — update all workspace packages within their semver ranges.
- `pnpm update -r --latest` — jump to latest versions, including new majors.

Remember that shared tools (typescript, oxlint, oxfmt) are versioned in the
`pnpm-workspace.yaml` catalog, so check that catalog entries were updated too. After
upgrading, run `pnpm lint && pnpm test && pnpm build` and review changelogs for any
major bumps before committing.
