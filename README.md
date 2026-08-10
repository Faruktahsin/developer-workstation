# 🧩 DevCompass

> The Developer Operating System platform for modern software engineers.

[![CI](https://github.com/Faruktahsin/developer-workstation/actions/workflows/ci.yml/badge.svg)](https://github.com/Faruktahsin/developer-workstation/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-macOS-black)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-M2%20Profiles%20MVP-blue)

---

## 📖 Overview

**DevCompass** is not a simple installer script. It is an open-source **Developer Operating System** platform designed to understand developer roles, skills, and tools, delivering personalized workstation setups, playbooks, and pathing.

The current release implements **Milestone 2 — Workspace Profiles & Configuration**: a zero-dependency, safe, and idempotent macOS workstation manager with validated role-oriented profiles.

---

## 🚀 Quick Start

Run system readiness diagnostic:
```bash
./apps/cli/bin/devcompass doctor
```

Preview initialization plan without system changes (Dry-Run):
```bash
./apps/cli/bin/devcompass init --profile web --dry-run
```

Initialize your workstation (requires explicit confirmation):
```bash
./apps/cli/bin/devcompass init --profile foundation
```

---

## ✨ Features (Workstation Profiles MVP)

- **Zero-Dependency Core**: Built in portable Bash 4+ (`set -Eeuo pipefail`) — no pre-installed Python, Go, or Node required.
- **Safe & Non-Destructive**: `devcompass init` requires explicit interactive confirmation (`[y/N]`).
- **Dry-Run Preview**: Inspect every planned system modification with `--dry-run`.
- **Foundation Brewfile**: Default installation is strictly foundation-only (`git`, `curl`, `wget`, `jq`, `shellcheck`, `gh`).
- **Workspace Profiles**: Choose validated `foundation`, `web`, `data-science`, or `devops` toolsets.
- **Inspectable Profiles**: Use `devcompass profile list`, `profile list --json`, or `profile show <id>` before applying a profile.
- **Opt-in macOS Defaults**: System defaults (UI/Dock/Finder modifications) are excluded from the default path to prevent unwanted changes.
- **Automated Configuration Backup**: Existing configuration files (`.gitconfig`, `.zshrc`) are backed up to timestamped files prior to any updates.

---

## 📂 Repository Structure

```text
.
├── apps/
│   └── cli/                    # DevCompass CLI dispatcher & test suite
├── packages/
│   └── workstation/            # Foundation Brewfiles & baseline configs
├── docs/                       # Audit reports & migration plans
├── specs/                      # Architecture blueprints & ADRs
├── Makefile                    # Developer workflow targets
└── README.md
```

See [REPOSITORY_BLUEPRINT.md](REPOSITORY_BLUEPRINT.md) for full structural details.

---

## 🏛 Architecture & ADRs

DevCompass follows a **Modular Monolith** architecture governed by Clean Architecture, Hexagonal Architecture, and DDD.

- [ARCHITECTURE.md](ARCHITECTURE.md)
- [ADR-001: Product Boundary & Workstation Module](specs/adr/ADR-001-product-boundary.md)
- [ADR-002: Modular Monolith Architecture](specs/adr/ADR-002-modular-monolith.md)
- [ADR-003: CLI Contract & Lifecycle](specs/adr/ADR-003-cli-contract.md)
- [ADR-004: Safe, Idempotent Workstation Changes](specs/adr/ADR-004-safe-idempotent-changes.md)
- [ADR-005: Workspace Profiles and Configuration Schema](specs/adr/ADR-005-workspace-profiles-schema.md)

---

## 🛠 Local Development

```bash
# Validate shell syntax & run ShellCheck
make lint

# Run unit test suite
make test

# Run CLI smoke tests
make smoke

# Run all checks
make check

# Symlink devcompass to /usr/local/bin
make install
```

---

## 📈 Roadmap

- [x] **M1 — Foundation + DevCompass Workstation MVP**
- [x] **M2 — Workspace Profiles & Configuration**
- [ ] **M3 — Knowledge Engine Foundation**
- [ ] **M4 — Search & Recommendation Engine**
- [ ] **M5 — Learning & Assessment**
- [ ] **M6 — AI Context, Memory & Tool Orchestration**
- [ ] **M7 — Plugin System (WASM)**
- [ ] **M8 — Team & Enterprise Capabilities**

See [ROADMAP.md](ROADMAP.md) for full details.

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before submitting pull requests.

---

## 📄 License

Released under the [MIT License](LICENSE).
