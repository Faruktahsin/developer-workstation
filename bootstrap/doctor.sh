#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/lib/logging.sh"
source "$(dirname "$0")/lib/checks.sh"

main() {
    echo
    echo "🩺 Developer Workstation Doctor"
    echo

    check_macos

    log_info "Checking development tools..."

    require_command git
    require_command brew
    require_command python3
    require_command gh

    echo
    log_success "System health check completed."
}

main "$@"