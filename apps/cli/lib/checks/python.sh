#!/usr/bin/env bash

set -Eeuo pipefail

check_python() {
    log_info "Checking Python..."
    if command -v python3 >/dev/null 2>&1; then
        local version
        version="$(python3 --version 2>/dev/null || echo 'Installed')"
        log_success "Python ($version)"
        return 0
    else
        log_warn "Python (python3) is not installed"
        return 1
    fi
}
