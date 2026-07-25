#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=bootstrap/lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"

# shellcheck source=bootstrap/lib/checks.sh
source "$SCRIPT_DIR/lib/checks.sh"

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