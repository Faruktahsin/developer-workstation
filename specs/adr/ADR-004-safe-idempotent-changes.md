# ADR-004: Safe, Idempotent Workstation Changes

## Status
Accepted

## Context
Initial machine setup tools can be dangerous if they make unexpected changes, overwrite existing configurations, or perform destructive operations (such as modifying system defaults or restarting user applications without consent).

## Decision
1. **Explicit Confirmation**: `devcompass init` requires explicit interactive confirmation (`[y/N]`) displaying the exact plan before performing any mutations.
2. **Dry-Run Default Preview**: `devcompass init --dry-run` performs zero system mutations and outputs the exact execution plan.
3. **Idempotency**: All installation and configuration steps inspect state before acting. Re-running `devcompass init` on an already-provisioned machine makes 0 duplicate modifications and reports steps as already satisfied.
4. **Foundation-Only Scope**: The default `Brewfile` contains only essential tooling (`git`, `curl`, `wget`, `jq`, `shellcheck`, `gh`).
5. **Opt-in macOS Defaults**: System defaults (UI/Finder/Dock changes) are excluded from the default `devcompass init` path.
6. **Safety Backups**: Existing configuration files (`.gitconfig`, `.zshrc`, etc.) are backed up to timestamped copies before modification.

## Consequences
- Zero surprises for developers running DevCompass.
- Completely safe to re-run at any time.
- Preserves existing system customizations by default.
