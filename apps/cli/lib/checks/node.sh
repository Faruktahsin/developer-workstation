#!/usr/bin/env bash

set -Eeuo pipefail

check_node() {
    log_info "Checking Node.js..."
    if command -v node >/dev/null 2>&1; then
        local version
        version="$(node --version 2>/dev/null || echo 'Installed')"
        log_success "Node.js ($version)"
        return 0
    else
        log_warn "Node.js is not installed"
        return 1
    fi
}
