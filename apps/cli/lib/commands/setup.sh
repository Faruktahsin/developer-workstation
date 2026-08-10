#!/usr/bin/env bash

set -Eeuo pipefail

setup_usage() {
    log_error "Usage: devcompass setup python --track data-science --level beginner [--dry-run] [--yes]"
}

cmd_setup() {
    local setup_target="${1:-}"
    local track=""
    local level=""
    local recipe_file
    local environment_path
    local is_dry_run="${DEVCOMPASS_DRY_RUN:-false}"

    if [[ "$setup_target" != "python" ]]; then
        setup_usage
        return 3
    fi
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --track)
                [[ $# -ge 2 && -n "$2" ]] || { setup_usage; return 3; }
                track="$2"
                shift
                ;;
            --track=*) track="${1#*=}" ;;
            --level)
                [[ $# -ge 2 && -n "$2" ]] || { setup_usage; return 3; }
                level="$2"
                shift
                ;;
            --level=*) level="${1#*=}" ;;
            --dry-run)
                export DEVCOMPASS_DRY_RUN="true"
                is_dry_run="true"
                ;;
            --yes|-y)
                export DEVCOMPASS_ASSUME_YES="true"
                ;;
            *)
                setup_usage
                return 3
                ;;
        esac
        shift
    done

    if [[ "$track" != "data-science" || "$level" != "beginner" ]]; then
        setup_usage
        return 3
    fi

    require_macos_platform || return $?

    recipe_file="$(get_python_recipe_file "$track" "$level")"
    if ! validate_python_recipe "$recipe_file"; then
        log_error "Python package recipe '$track/$level' is missing or invalid."
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python 3 is required before creating a learning environment."
        log_info "Run 'devcompass init --profile data-science' first, then rerun this command."
        return 1
    fi

    environment_path="$(python_environment_path "$track" "$level")"
    render_python_setup_plan "$track" "$level" "$recipe_file" "$environment_path"

    if [[ "$is_dry_run" == "true" ]]; then
        log_success "[DRY-RUN] Python environment plan completed. Zero system changes made."
        return 0
    fi

    if ! confirm_action "Create this Python learning environment and install its packages?" "N"; then
        log_warn "Python environment setup aborted by user."
        return 3
    fi

    if ! install_python_recipe "$recipe_file" "$environment_path"; then
        log_error "Python environment setup failed. Review the message above, then rerun when ready."
        return 1
    fi

    log_success "Python learning environment is ready: $environment_path"
    log_info "Activate it with: source '$environment_path/bin/activate'"
}
