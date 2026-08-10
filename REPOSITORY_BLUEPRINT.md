# DevCompass Repository Blueprint

```text
.
├── apps/
│   └── cli/
│       ├── bin/
│       │   └── devcompass              # Main CLI entry point
│       ├── lib/
│       │   ├── core.sh                 # Logging, colors, error handling, dry-run & prompt state
│       │   ├── commands/
│       │   │   ├── doctor.sh           # devcompass doctor
│       │   │   ├── init.sh             # devcompass init [--dry-run]
│       │   │   ├── version.sh          # devcompass version
│       │   │   └── help.sh             # devcompass --help / help
│       │   └── checks/
│       │       ├── system.sh           # OS & architecture checks
│       │       ├── xcode.sh            # Xcode CLI Tools checks
│       │       ├── homebrew.sh         # Homebrew checks
│       │       ├── git.sh              # Git checks
│       │       ├── python.sh           # Python checks
│       │       └── node.sh             # Node.js checks
│       └── tests/
│           ├── test_runner.sh          # Unit test runner framework
│           ├── test_parser.sh          # CLI argument parser tests
│           ├── test_doctor.sh          # Doctor command tests
│           ├── test_init.sh            # Init command dry-run & prompt tests
│           ├── test_checks.sh          # System check tests
│           └── test_platform.sh        # Unsupported OS platform tests
├── packages/
│   └── workstation/
│       ├── brewfiles/
│       │   └── Brewfile.foundation     # Foundation-only Brewfile
│       └── configs/
│           ├── git/
│           │   └── .gitconfig          # Baseline Git config
│           ├── shell/
│           │   └── .zshrc              # Baseline Zsh config
│           └── vscode/
│               ├── settings.json       # Baseline VS Code settings
│               └── extensions.txt      # Foundation VS Code extensions
├── docs/
│   └── audit/
│       ├── REPOSITORY_AUDIT.md
│       └── MIGRATION_PLAN.md
├── specs/
│   ├── adr/
│   │   ├── ADR-001-product-boundary.md
│   │   ├── ADR-002-modular-monolith.md
│   │   ├── ADR-003-cli-contract.md
│   │   └── ADR-004-safe-idempotent-changes.md
│   ├── architecture/
│   ├── knowledge/
│   └── product/
├── bootstrap/                          # Deprecated (legacy compatibility wrappers)
├── config/                             # Deprecated (legacy config files preserved)
├── python/                             # Deprecated (legacy python stubs preserved)
├── scripts/                            # Deprecated (legacy script stubs preserved)
├── .github/
│   ├── workflows/
│   │   └── ci.yml                     # Continuous Integration workflow
│   └── pull_request_template.md
├── ARCHITECTURE.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── Makefile                            # Developer task runner
├── README.md
├── ROADMAP.md
├── SECURITY.md
├── .editorconfig
├── .gitattributes
└── .gitignore
```
