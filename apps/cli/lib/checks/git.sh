#!/usr/bin/env bash

set -Eeuo pipefail

check_git() {
    log_info "Checking Git..."
    if command -v git >/dev/null 2>&1; then
        local version
        version="$(git --version 2>/dev/null || echo 'Installed')"
        log_success "Git ($version)"
        return 0
    else
        log_warn "Git is not installed"
        return 1
    fi
}
