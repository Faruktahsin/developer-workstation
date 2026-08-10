#!/usr/bin/env bash

set -Eeuo pipefail

export DEVCOMPASS_VERSION="0.1.0-foundation"

# Color setup with NO_COLOR and TERM support
if [[ -n "${NO_COLOR:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_BOLD=""
    COLOR_RESET=""
else
    COLOR_RED='\033[0;31m'
    COLOR_GREEN='\033[0;32m'
    COLOR_YELLOW='\033[1;33m'
    COLOR_BLUE='\033[0;34m'
    COLOR_BOLD='\033[1m'
    COLOR_RESET='\033[0m'
fi

log_info() {
    printf "%bℹ %s%b\n" "${COLOR_BLUE}" "$1" "${COLOR_RESET}"
}

log_success() {
    printf "%b✓ %s%b\n" "${COLOR_GREEN}" "$1" "${COLOR_RESET}"
}

log_warn() {
    printf "%b⚠ %s%b\n" "${COLOR_YELLOW}" "$1" "${COLOR_RESET}"
}

log_error() {
    printf "%b✗ %s%b\n" "${COLOR_RED}" "$1" "${COLOR_RESET}" >&2
}

log_bold() {
    printf "%b%s%b\n" "${COLOR_BOLD}" "$1" "${COLOR_RESET}"
}

# Target home directory resolution
get_home_dir() {
    echo "$HOME"
}

# Platform detection using standard system commands
is_macos() {
    local os_name
    os_name="$(uname)"
    [[ "$os_name" == "Darwin" ]]
}

get_macos_version() {
    if ! is_macos; then
        echo "N/A"
        return 1
    fi
    sw_vers -productVersion 2>/dev/null || echo "Unknown"
}

get_arch() {
    uname -m 2>/dev/null || echo "Unknown"
}

require_macos_platform() {
    if ! is_macos; then
        log_error "DevCompass Workstation currently supports macOS only."
        log_error "Detected platform: $(uname)"
        return 2
    fi
}

# Interactive confirmation utility
confirm_action() {
    local prompt_msg="$1"
    local default_ans="${2:-N}"

    if [[ "${DEVCOMPASS_ASSUME_YES:-false}" == "true" ]]; then
        log_info "Auto-confirmed via --yes flag."
        return 0
    fi

    local reply
    printf "%b%s [y/N]: %b" "${COLOR_BOLD}" "$prompt_msg" "${COLOR_RESET}"
    read -r reply || reply="$default_ans"

    case "$reply" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Backup utility (Backs up file only when mutating)
backup_file() {
    local target_file="$1"
    if [[ -f "$target_file" ]]; then
        local timestamp
        timestamp="$(date +%Y%m%d_%H%M%S_%N 2>/dev/null || date +%Y%m%d_%H%M%S)"
        local backup_path="${target_file}.devcompass_backup_${timestamp}"
        if [[ "${DEVCOMPASS_DRY_RUN:-false}" == "true" ]]; then
            log_info "[DRY-RUN] Would backup $target_file -> $backup_path"
        else
            cp "$target_file" "$backup_path"
            log_info "Backed up $target_file -> $backup_path"
        fi
    fi
}
