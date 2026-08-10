#!/usr/bin/env bash

set -Eeuo pipefail

check_homebrew() {
    log_info "Checking Homebrew..."
    if command -v brew >/dev/null 2>&1; then
        local version
        version="$(HOMEBREW_NO_AUTO_UPDATE=1 brew --version 2>/dev/null | head -n 1 || echo 'Installed')"
        log_success "Homebrew ($version)"
        return 0
    else
        log_warn "Homebrew is not installed"
        return 1
    fi
}
