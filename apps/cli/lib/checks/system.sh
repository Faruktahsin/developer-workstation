#!/usr/bin/env bash

set -Eeuo pipefail

check_system() {
    log_info "Checking operating system..."
    if is_macos; then
        local version arch
        version="$(get_macos_version)"
        arch="$(get_arch)"
        log_success "macOS detected (Version: $version, Arch: $arch)"
        return 0
    else
        log_error "Unsupported operating system: $(uname)"
        return 1
    fi
}
