#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=bootstrap/lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"

# shellcheck source=bootstrap/lib/checks.sh
source "$SCRIPT_DIR/lib/checks.sh"

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