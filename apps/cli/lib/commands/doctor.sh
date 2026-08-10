#!/usr/bin/env bash

set -Eeuo pipefail

cmd_doctor() {
    log_bold "🩺 DevCompass Workstation Doctor"
    echo "======================================"

    local critical_failed=0
    local passed=0
    local warnings=0

    # 1. System Platform Check (Critical)
    if check_system; then
        passed=$((passed + 1))
    else
        critical_failed=$((critical_failed + 1))
    fi

    echo "--------------------------------------"
    log_bold "Core Developer Tools:"

    # 2. Xcode CLI Tools (Critical)
    if check_xcode_cli; then
        passed=$((passed + 1))
    else
        critical_failed=$((critical_failed + 1))
    fi

    # 3. Homebrew (Critical)
    if check_homebrew; then
        passed=$((passed + 1))
    else
        critical_failed=$((critical_failed + 1))
    fi

    # 4. Git (Critical)
    if check_git; then
        passed=$((passed + 1))
    else
        critical_failed=$((critical_failed + 1))
    fi

    echo "--------------------------------------"
    log_bold "Optional Runtime Tooling:"

    # 5. Python (Optional)
    if check_python; then
        passed=$((passed + 1))
    else
        warnings=$((warnings + 1))
    fi

    # 6. Node.js (Optional)
    if check_node; then
        passed=$((passed + 1))
    else
        warnings=$((warnings + 1))
    fi

    echo "======================================"
    log_bold "Summary:"
    log_success "$passed check(s) passed"
    if [[ $warnings -gt 0 ]]; then
        log_warn "$warnings optional check(s) missing"
    fi
    if [[ $critical_failed -gt 0 ]]; then
        log_error "$critical_failed critical check(s) failed"
        return 1
    fi

    log_success "System readiness verified for DevCompass Workstation."
    return 0
}
