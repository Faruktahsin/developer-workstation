# ADR-002: Modular Monolith and Architectural Boundaries

## Status
Accepted

## Context
DevCompass requires a clean, maintainable architecture that can grow from a single CLI workstation tool into a multi-module developer platform (Knowledge, Profiles, AI Engine, etc.) without early over-engineering or premature microservices.

## Decision
1. Adopt a **Modular Monolith** pattern applying Clean Architecture, Hexagonal Architecture (Ports and Adapters), and DDD principles.
2. Structure the codebase into:
   - `apps/`: Executable entry points (`apps/cli`)
   - `packages/`: Domain packages (`packages/workstation`, `packages/profiles`, `packages/core`)
   - `specs/`: Architecture specs, domain schemas, ADRs
   - `docs/`: Audit, guides, and migration docs
3. Modules communicate through explicit contracts/interfaces.
4. Legacy files in `bootstrap/` and `scripts/` are preserved as deprecated adapters pointing to the canonical CLI.

## Consequences
- Single repository simplicity with strict internal directory boundaries.
- Independent package evolvability.
- Clear path for future language/framework adoption (e.g. Go/Rust) for heavy engines while keeping CLI interface contract consistent.
