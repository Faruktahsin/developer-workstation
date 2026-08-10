# ADR-005: Workspace Profiles and Configuration Schema

## Status
Accepted

## Context
In Milestone 1, workstation initialization supported only a single hardcoded foundation toolset. Developers have varied roles (Web Engineering, Data Science, Cloud/DevOps) requiring tailored profiles with specific packages, configurations, and toolchain dependencies.

## Decision
1. Introduce a versioned YAML schema for profile definitions stored in `packages/profiles/definitions/*.yaml`. Every definition must contain exactly one `schema_version`, `id`, `display_name`, `description`, and repository-relative `brewfile` field.
2. Initial supported profiles:
   - `foundation`: Baseline CLI utilities (git, curl, jq, gh, shellcheck, tree).
   - `web`: Node.js, Yarn, NVM + foundation tools.
   - `data-science`: Python 3, Pyenv, JupyterLab + foundation tools.
   - `devops`: Docker, kubectl, Terraform, AWS CLI, Helm + foundation tools.
3. The optional `extends` field is descriptive metadata in this MVP. Each declared Brewfile is self-contained; graph-based inheritance and custom user profiles are deferred.
4. Introduce CLI commands:
   - `devcompass profile list [--json]`
   - `devcompass profile show <id>`
   - `devcompass init --profile <id> [--dry-run]`
5. Profile application remains additive, non-destructive, idempotent, dry-run-first, and confirmation-gated.

## Consequences
- Developers can select role-specific profiles or preview them without mutating system configuration.
- Profile inheritance avoids duplicate dependency definitions across toolsets.
- Machine-readable JSON output (`devcompass profile list --json`) enables automation.
