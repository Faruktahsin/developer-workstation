# ADR-003: CLI Contract and Command Lifecycle

## Status
Accepted

## Context
The DevCompass CLI (`devcompass`) is the primary user touchpoint for the Workstation MVP. It requires predictable output, standard exit codes, non-zero error signaling, and zero runtime dependencies for the initial bootstrap environment.

## Decision
1. For the Foundation + Workstation MVP, implementation uses Bash compatible with macOS's built-in **Bash 3.2+** (`set -Eeuo pipefail`) to ensure zero external language runtime requirements on a fresh macOS machine.
2. Mandatory baseline CLI interface:
   - `devcompass --help` / `devcompass help`: Usage and command list.
   - `devcompass version` / `devcompass --version`: Product version output.
   - `devcompass doctor`: System readiness & health diagnostic.
   - `devcompass init --dry-run`: Non-mutating execution preview.
   - `devcompass init`: Interactive installation with explicit confirmation.
3. Exit Code Standard:
   - `0`: Success / Passed.
   - `1`: General error / Doctor checks failed.
   - `2`: Unsupported platform (non-macOS).
   - `3`: User aborted / confirmation declined, or invalid command-specific usage.
4. Support `NO_COLOR` standard for plain-text output.

## Consequences
- CLI execution is deterministic and testable.
- Machine-parseable error exit codes allow CI and outer scripts to handle failures safely.
