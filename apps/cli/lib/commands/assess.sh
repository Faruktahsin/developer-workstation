#!/usr/bin/env bash

set -Eeuo pipefail

assess_usage() {
    log_error "Usage: devcompass assess --role role.data-science [--answers 1,1,1]"
}

cmd_assess() {
    local role_id=""
    local answers_csv=""
    local assessment_file

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --role) [[ $# -ge 2 && -n "$2" ]] || { assess_usage; return 3; }; role_id="$2"; shift ;;
            --role=*) role_id="${1#*=}" ;;
            --answers) [[ $# -ge 2 && -n "$2" ]] || { assess_usage; return 3; }; answers_csv="$2"; shift ;;
            --answers=*) answers_csv="${1#*=}" ;;
            *) assess_usage; return 3 ;;
        esac
        shift
    done

    [[ "$role_id" == "role.data-science" ]] || { assess_usage; return 3; }
    assessment_file="$(get_assessment_file "$role_id")" || { log_error "No assessment is available for '$role_id'."; return 1; }
    validate_assessment_file "$assessment_file" || { log_error "Assessment data is invalid."; return 2; }
    run_assessment "$role_id" "$answers_csv"
    echo "=================================================="
    echo "Score: $ASSESSMENT_SCORE/$ASSESSMENT_TOTAL"
    if [[ "$ASSESSMENT_SCORE" -lt "$ASSESSMENT_TOTAL" ]]; then
        log_info "Next step: devcompass recommend path --goal skill.data-analysis"
    else
        log_success "Strong foundation. Next step: devcompass setup python --track data-science --level beginner --dry-run"
    fi
}
