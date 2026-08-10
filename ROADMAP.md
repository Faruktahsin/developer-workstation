# DevCompass Product Roadmap

## Milestone Overview

```text
M1 — Foundation + DevCompass Workstation (COMPLETE)
M2 — Workspace Profiles & Configuration (COMPLETE)
M3 — Knowledge Engine Foundation (COMPLETE)
M4 — Search & Recommendation Engine (role-roadmap MVP COMPLETE)
M5 — Learning & Assessment
M6 — AI Context, Memory & Tool Orchestration
M7 — Plugin System (WASM)
M8 — Team & Enterprise Capabilities
```

---

### 🟢 M1 — Foundation + DevCompass Workstation (Complete)
- [x] Canonical modular monolith structure (`apps/cli`, `packages/workstation`, `specs/`, `docs/`)
- [x] Architectural decision records (ADR-001 through ADR-004)
- [x] Portable Bash CLI framework (`devcompass`)
- [x] `devcompass --help`, `devcompass version`
- [x] `devcompass doctor` system health check
- [x] `devcompass init --dry-run` non-destructive execution preview
- [x] `devcompass init` with explicit user confirmation and foundation Brewfile
- [x] Unit test suite (`apps/cli/tests/`)
- [x] Automated CI workflow (`.github/workflows/ci.yml`)

### 🟢 M2 — Workspace Profiles & Configuration (Complete)
- [x] Profile engine (`packages/profiles`)
- [x] Validated profile schema (`schema_version`, `id`, `display_name`, `description`, `brewfile`)
- [x] Tiered toolsets (Foundation, Web Engineering, Data Science, Cloud/DevOps)
- [x] `devcompass profile list`, `profile list --json`, and `profile show <id>`
- [x] Profile-aware, dry-run-first initialization
- [ ] Custom profile definitions (`devcompass.yaml`) — deferred to a later milestone
- [ ] Configuration sync and diff utilities — deferred to a later milestone

### 🟢 M3 — Knowledge Engine Foundation (Complete)
- [x] Versioned offline graph data model (Role → Skill → Technology → Tool → Playbook)
- [x] Graph validation and read-only CLI inspection commands
- [x] Initial Backend, Web, and DevOps role nodes
- [ ] Persistent graph database and role breadth — deferred until M4/M5 needs justify them

### 🟢 M4 — Search & Recommendation Engine (Role-roadmap MVP Complete)
- [x] `devcompass recommend --role <role-id>` role-roadmap command
- [x] Deterministic graph traversal of `requires` and directly used `uses` relationships
- [x] Plain and JSON recommendation output with scope explanation
- [ ] Personalized skill-gap detection — deferred to M5
- [ ] True prerequisite-ranked learning paths — deferred until the graph models prerequisite relationships

### ⚪ M5 — Learning & Assessment
- [ ] Skill assessment engine
- [ ] Interactive developer diagnostic quizzes
- [ ] Personalized learning path generation

### ⚪ M6 — AI Context, Memory & Tool Orchestration
- [ ] Provider-agnostic LLM interface (Ollama, OpenAI, Anthropic, Gemini)
- [ ] Local developer memory engine
- [ ] Autonomous task execution dispatcher

### ⚪ M7 — Plugin System
- [ ] WASM plugin host sandbox
- [ ] Extension API for third-party tools and playbooks

### ⚪ M8 — Team & Enterprise Capabilities
- [ ] Team workstation profiles & policy enforcement
- [ ] Shared team playbooks and knowledge sync
