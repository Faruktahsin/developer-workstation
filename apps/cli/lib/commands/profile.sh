#!/usr/bin/env bash

set -Eeuo pipefail

cmd_profile() {
    local subcmd="${1:-list}"
    shift 1 2>/dev/null || true

    case "$subcmd" in
        list)
            local is_json="false"
            if [[ "${1:-}" == "--json" ]]; then
                is_json="true"
            fi
            list_available_profiles "$is_json"
            ;;
        show)
            local target_profile="${1:-}"
            if [[ -z "$target_profile" ]]; then
                log_error "Profile name is required for 'devcompass profile show <name>'."
                return 1
            fi
            show_profile_details "$target_profile"
            ;;
        *)
            log_error "Unknown profile command: $subcmd"
            echo "Usage: devcompass profile [list|show <name>]"
            return 1
            ;;
    esac
}
