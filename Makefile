.PHONY: help lint test smoke check install uninstall

DEVCOMPASS_BIN := $(shell pwd)/apps/cli/bin/devcompass
TARGET_BIN := /usr/local/bin/devcompass

help:
	@echo "DevCompass Development Targets:"
	@echo "  make lint     - Run ShellCheck and syntax validations"
	@echo "  make test     - Run CLI test suite"
	@echo "  make smoke    - Run CLI smoke tests"
	@echo "  make check    - Run lint, test, and smoke checks"
	@echo "  make install  - Symlink devcompass to /usr/local/bin"

lint:
	@echo "==> Validating Shell Syntax..."
	@find apps/cli bootstrap scripts -name "*.sh" -print0 | xargs -0 -n1 bash -n
	@echo "==> Running ShellCheck..."
	@shellcheck apps/cli/bin/devcompass apps/cli/lib/*.sh apps/cli/lib/**/*.sh apps/cli/tests/*.sh

test:
	@echo "==> Running DevCompass Unit Tests..."
	@./apps/cli/tests/test_all.sh

smoke:
	@echo "==> Running DevCompass Smoke Tests..."
	@./apps/cli/bin/devcompass --help >/dev/null
	@./apps/cli/bin/devcompass version >/dev/null
	@./apps/cli/bin/devcompass doctor >/dev/null
	@./apps/cli/bin/devcompass knowledge validate >/dev/null
	@./apps/cli/bin/devcompass recommend --role role.web --format json >/dev/null
	@./apps/cli/bin/devcompass recommend path --goal package.pandas --format json >/dev/null
	@./apps/cli/bin/devcompass setup python --track data-science --level beginner --dry-run >/dev/null
	@echo "✓ Smoke tests passed."

check: lint test smoke

install:
	@echo "==> Installing devcompass symlink to $(TARGET_BIN)..."
	@ln -sf $(DEVCOMPASS_BIN) $(TARGET_BIN)
	@echo "✓ devcompass installed to $(TARGET_BIN)."

uninstall:
	@echo "==> Removing $(TARGET_BIN)..."
	@rm -f $(TARGET_BIN)
	@echo "✓ devcompass uninstalled."
