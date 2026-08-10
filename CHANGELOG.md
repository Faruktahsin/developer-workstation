# Changelog

All notable changes to DevCompass will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Workspace profiles: `foundation`, `web`, `data-science`, and `devops`.
- Versioned profile schema with validated profile IDs and repository-scoped Brewfiles.
- `devcompass profile list`, `devcompass profile list --json`, and `devcompass profile show <id>`.
- Strict command/flag validation and profile schema tests.
- Offline versioned knowledge graph with Role, Skill, Technology, Tool, and Playbook nodes.
- `devcompass knowledge status`, `knowledge validate`, and `knowledge show <id>`.

### Changed
- `devcompass init` now supports `--profile <id>` and uses the selected profile's declared Brewfile.

## [0.1.0-foundation] - 2026-08-10

### Added
- Canonical DevCompass modular monolith directory structure (`apps/cli`, `packages/workstation`, `specs/`, `docs/`).
- Architectural Decision Records: `ADR-001` through `ADR-004`.
- Portable, zero-dependency Bash 4+ CLI dispatcher (`apps/cli/bin/devcompass`).
- Supported CLI commands: `devcompass --help`, `devcompass version`, `devcompass doctor`, `devcompass init --dry-run`, `devcompass init`.
- Pre-flight system checks for macOS, Xcode CLI tools, Homebrew, Git, Python, Node.js.
- Foundation-only Brewfile profile (`packages/workstation/brewfiles/Brewfile.foundation`).
- Baseline Git (`.gitconfig`), Zsh (`.zshrc`), and VS Code (`settings.json`, `extensions.txt`) configuration templates.
- Explicit interactive confirmation prompt (`[y/N]`) before executing system modifications.
- Non-destructive `--dry-run` execution mode.
- Unit test framework with 19 automated tests (`apps/cli/tests/`).
- `Makefile` for developer tasks (`make check`, `make test`, `make lint`, `make smoke`).
- CI GitHub Actions workflow (`.github/workflows/ci.yml`).

### Changed
- Transitioned project branding and architectural scope from `developer-workstation` installer to **DevCompass** Developer Operating System platform.
- Replaced 0-byte placeholder files with complete community & architectural documentation.
- Deprecated legacy entry points in `bootstrap/`, `scripts/`, `python/` while preserving files for backwards compatibility.
