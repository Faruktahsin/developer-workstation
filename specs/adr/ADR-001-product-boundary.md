# ADR-001: DevCompass Product Boundary and Workstation Module

## Status
Accepted

## Context
The repository was originally titled `developer-workstation`, focused on macOS bootstrap shell scripts. The product vision evolves this into **DevCompass** — a comprehensive Developer Operating System platform.

## Decision
1. **DevCompass** is the overall product platform name.
2. The initial macOS setup and machine provisioning capabilities are bounded into the **DevCompass Workstation** module (`packages/workstation`).
3. Developer Workstation CLI is renamed to `devcompass`.
4. The product architecture will support future modules (Knowledge Engine, Profiles, Recommendation Engine, Learning & Assessment, AI Context/Memory, WASM Plugins, Enterprise) without altering core Workstation capabilities.

## Consequences
- Existing scripts and paths are migrated or aliased to `devcompass`.
- Product documentation and branding consistently reflect DevCompass.
- Workstation setup logic is isolated within modular boundaries (`packages/workstation` and `apps/cli`).
