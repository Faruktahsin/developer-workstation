#!/usr/bin/env bash

set -Eeuo pipefail
source "$(dirname "$0")/lib/logging.sh"
source "$(dirname "$0")/lib/checks.sh"
readonly SCRIPT_NAME="$(basename "$0")"

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

    check_macos
    check_tools

    echo
    log_success "Bootstrap checks completed."
}

main "$@"