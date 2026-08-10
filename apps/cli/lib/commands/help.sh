#!/usr/bin/env bash

set -Eeuo pipefail

cmd_help() {
    log_bold "DevCompass — Developer Operating System (Workstation MVP)"
    echo "Version: ${DEVCOMPASS_VERSION}"
    echo
    log_bold "USAGE:"
    echo "  devcompass [options] <command>"
    echo
    log_bold "COMMANDS:"
    echo "  doctor         Check system readiness and developer tool availability"
    echo "  init           Initialize workstation setup with specified workspace profile"
    echo "  profile        List or inspect workspace profiles (list, show <name>)"
    echo "  version        Show DevCompass version"
    echo "  help           Show this help menu"
    echo
    log_bold "FLAGS & OPTIONS:"
    echo "  --profile <p>  Select workspace profile (foundation, web, data-science, devops)"
    echo "  --dry-run      (Use with init) Preview actions without executing mutations"
    echo "  --yes, -y      (Use with init) Automatically confirm execution prompts"
    echo "  --help, -h     Show command help"
    echo "  --version, -v  Show version string"
    echo "  --no-color     Disable ANSI colored output"
    echo
    log_bold "EXAMPLES:"
    echo "  devcompass doctor"
    echo "  devcompass profile list"
    echo "  devcompass profile show web"
    echo "  devcompass init --profile web --dry-run"
    echo "  devcompass init --profile data-science"
}
