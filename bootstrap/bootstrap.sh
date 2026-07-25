#!/usr/bin/env bash

set -Eeuo pipefail
source "$(dirname "$0")/lib/logging.sh"
readonly SCRIPT_NAME="$(basename "$0")"

require_command() {
    if command -v "$1" >/dev/null 2>&1; then
        log_success "$1 found"
    else
        log_error "$1 is not installed"
        exit 1
    fi
}

check_os() {
    log_info "Checking operating system..."

    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script only supports macOS."
        exit 1
    fi

    log_success "macOS detected"
}

check_tools() {
    log_info "Checking required tools..."

    require_command git
    require_command brew
    require_command python3
}

main() {
    echo
    echo "🚀 Developer Workstation Bootstrap"
    echo

    check_os
    check_tools

    echo
    log_success "Bootstrap checks completed."
}

main "$@"