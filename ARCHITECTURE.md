# DevCompass Architecture

DevCompass is designed as a **Developer Operating System platform**. It adopts a **Modular Monolith** architecture governed by **Clean Architecture**, **Hexagonal Architecture (Ports & Adapters)**, and **Domain-Driven Design (DDD)** principles.

```text
DevCompass Platform
├── Apps Layer (CLI Dispatcher, Web/Desktop Shells)
├── Modules Layer (Workstation, Profiles, Knowledge, AI Memory, Plugin Host)
└── Shared Core (Domain Types, Event Bus, Logger, Config Store)
```

## Architectural Layers

### 1. Presentation Layer (`apps/`)
- `apps/cli`: Command Line Interface. Entry point (`devcompass`) routes user commands to internal module controllers. Performs option parsing, input validation, output formatting, and terminal UI rendering.

### 2. Domain & Application Modules (`packages/`)
- `packages/workstation`: System detection, dependency resolution, package installation (Brewfile), configuration management.
- `packages/profiles`: (Future M2) Workspace profiles and configuration management.
- `packages/knowledge`: (Future M3-M4) Relational knowledge engine linking Roles → Skills → Tech → Tools → Playbooks.
- `packages/learning`: (Future M5) Developer assessment and path recommendations.
- `packages/ai`: (Future M6) Provider-agnostic AI memory and tool orchestration context.

### 3. Hexagonal Ports & Adapters
- **Ports (Interfaces)**: System check contracts, package manager contracts, configuration sync contracts.
- **Adapters (Implementations)**: macOS Shell execution, Homebrew CLI wrapper, Git config writer, VS Code settings provider.

## Homebrew Installer Trust Boundary & Failure Model

- **Trust Boundary**: Homebrew installation invokes official install script (`https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh`). Users running `devcompass init` trust official Homebrew infrastructure.
- **Failure Behavior**: If Xcode CLI is missing, `devcompass init` triggers `xcode-select --install` and halts with exit code 1 to allow manual installation completion before continuing. If Homebrew or `brew bundle` fails, `devcompass init` logs an actionable warning/error, preserves existing system state, and allows non-destructive reruns once connectivity/dependencies are resolved.

## Core Design Principles

1. **Provider-, Model-, and Framework-Agnostic**: Core domain logic does not depend on cloud providers or specific AI APIs.
2. **Offline-First & Safe Execution**: Machine environment setup operates locally without mandatory cloud connectivity. Operations check current system state before executing mutations.
3. **Idempotency & Non-Destructive**: Every step checks if work is already completed. Re-running commands makes 0 redundant changes and backs up modified configuration files.
4. **Zero-Dependency Bootstrap**: The initial Workstation MVP is implemented in pure Bash 4+ (`set -Eeuo pipefail`) to allow bootstrapping on fresh macOS installations without requiring pre-existing runtime installations (Python/Go/Node).

## Knowledge Graph Model (Long-Term Vision)

```text
Role
 └── Skills
      └── Technologies
           └── Tools
                └── Projects
                     └── Playbooks
                          └── Learning Paths
                               └── Assessments
```
