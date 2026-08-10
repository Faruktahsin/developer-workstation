# Contributing to DevCompass

Thank you for your interest in contributing to DevCompass!

## Development Workflow

1. **Fork & Clone**: Fork the repository and clone it locally.
2. **Branching**: Create a feature branch (`git checkout -b feature/my-feature`).
3. **Standards**: Ensure shell scripts follow `set -Eeuo pipefail` and include ShellCheck directives.
4. **Testing**: All changes must pass `make check` (syntax validation, ShellCheck, unit tests, smoke tests).
5. **Pull Request**: Open a PR using the standard template.

## Architectural Decision Records (ADRs)

If your proposed change impacts core platform boundaries, module isolation, or CLI contracts, please include an ADR in `specs/adr/` following existing ADR patterns.
