# DevCompass Product Roadmap

## Milestone Overview

```text
M1 — Foundation + DevCompass Workstation (IN PROGRESS)
M2 — Workspace Profiles & Configuration
M3 — Knowledge Engine Foundation
M4 — Search & Recommendation Engine
M5 — Learning & Assessment
M6 — AI Context, Memory & Tool Orchestration
M7 — Plugin System (WASM)
M8 — Team & Enterprise Capabilities
```

---

### 🟢 M1 — Foundation + DevCompass Workstation (Current Status)
- [x] Canonical modular monolith structure (`apps/cli`, `packages/workstation`, `specs/`, `docs/`)
- [x] Architectural decision records (ADR-001 through ADR-004)
- [x] Portable Bash CLI framework (`devcompass`)
- [x] `devcompass --help`, `devcompass version`
- [x] `devcompass doctor` system health check
- [x] `devcompass init --dry-run` non-destructive execution preview
- [x] `devcompass init` with explicit user confirmation and foundation Brewfile
- [x] Unit test suite (`apps/cli/tests/`)
- [x] Automated CI workflow (`.github/workflows/ci.yml`)

### ⚪ M2 — Workspace Profiles & Configuration
- [ ] Profile engine (`packages/profiles`)
- [ ] Tiered toolsets (Data Science, Web Engineering, Cloud/DevOps)
- [ ] Custom profile definitions (`devcompass.yaml`)
- [ ] Configuration sync and diff utilities

### ⚪ M3 — Knowledge Engine Foundation
- [ ] Domain graph data model (Role → Skill → Tech → Tool → Playbook)
- [ ] Relational schema & offline graph database engine
- [ ] Initial Developer Roles schema (Backend, Frontend, AI/ML Engineer)

### ⚪ M4 — Search & Recommendation Engine
- [ ] Graph querying and path finding algorithms
- [ ] Contextual gap detection for developer profiles
- [ ] Explainable step-by-step recommendations

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
