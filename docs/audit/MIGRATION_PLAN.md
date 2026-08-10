# DevCompass Migration Plan

## Objectives
1. Transition `developer-workstation` into **DevCompass** platform architecture.
2. Establish the canonical modular structure (`apps/cli`, `packages/workstation`, `specs/`, `docs/`).
3. Build the zero-dependency Bash CLI (`devcompass`).
4. Maintain backwards compatibility by marking legacy script entry points as deprecated without deleting them.

## Phase Execution Plan

### Phase 0: Audit & Architecture Contracts (Completed)
- Complete filesystem audit.
- Write ADR-001 through ADR-004.
- Publish `REPOSITORY_BLUEPRINT.md`, `ARCHITECTURE.md`, `ROADMAP.md`.

### Phase 1: Canonical Directory Layout (Current)
- Establish `apps/cli/bin/`, `apps/cli/lib/`, `apps/cli/tests/`.
- Establish `packages/workstation/brewfiles/` and `packages/workstation/configs/`.
- Add deprecation headers to legacy files in `bootstrap/`, `scripts/`, `python/`.

### Phase 2: Workstation MVP Implementation
- Implement CLI dispatcher (`devcompass`).
- Implement core functions (`lib/core.sh`).
- Implement system checks (`lib/checks/`).
- Implement commands (`doctor`, `init`, `version`, `help`).
- Enforce explicit confirmation & dry-run behavior.

### Phase 3: Validation, CI, and Documentation
- Write unit tests (`apps/cli/tests/`).
- Configure GitHub Actions CI workflow (`.github/workflows/ci.yml`).
- Create `Makefile` for developer workflows.
- Update `README.md` and community docs (`CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`).
