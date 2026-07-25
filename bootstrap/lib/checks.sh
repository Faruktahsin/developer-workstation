#!/usr/bin/env bash

require_command() {
    local cmd="$1"

    if command -v "$cmd" >/dev/null 2>&1; then
        log_success "$cmd found"
    else
        log_error "$cmd not found"
        return 1
    fi
}

check_macos() {
    log_info "Checking operating system..."

    if [[ "$(uname)" == "Darwin" ]]; then
        log_success "macOS detected"
    else
        log_error "Unsupported operating system"
        return 1
    fi
}