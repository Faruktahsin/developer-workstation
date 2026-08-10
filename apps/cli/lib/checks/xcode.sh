#!/usr/bin/env bash

set -Eeuo pipefail

check_xcode_cli() {
    log_info "Checking Xcode Command Line Tools..."
    if xcode-select -p >/dev/null 2>&1; then
        log_success "Xcode Command Line Tools installed"
        return 0
    else
        log_warn "Xcode Command Line Tools not installed"
        return 1
    fi
}
