#!/usr/bin/env bash

set -Eeuo pipefail

get_assessment_file() {
    case "$1" in
        role.data-science) printf '%s\n' "${DEVCOMPASS_ROOT}/packages/learning/assessments/data-science-basics.tsv" ;;
        *) return 1 ;;
    esac
}

validate_assessment_file() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    [[ "$(head -n 1 "$file")" == $'id\tskill_id\tprompt\toptions\tcorrect_option' ]] || return 1
    awk -F '\t' 'NR > 1 && (NF != 5 || $1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 !~ /^[1-9][0-9]*$/) { invalid = 1 } END { exit invalid }' "$file"
}

run_assessment() {
    local role_id="$1"
    local answers_csv="${2:-}"
    local file skill_id prompt options correct_option answer
    local answers=()
    local question_count=0

    file="$(get_assessment_file "$role_id")" || return 1
    validate_assessment_file "$file" || return 1
    [[ -z "$answers_csv" ]] || IFS=',' read -r -a answers <<< "$answers_csv"

    ASSESSMENT_SCORE=0
    log_bold "🎯 DevCompass Assessment: $(recommendation_node_label "$role_id")"
    echo "=================================================="
    while IFS=$'\t' read -r _ skill_id prompt options correct_option; do
        question_count=$((question_count + 1))
        echo "$question_count. $prompt"
        echo "   $options"
        if [[ -n "$answers_csv" ]]; then
            answer="${answers[$((question_count - 1))]:-}"
            echo "   Answer: ${answer:-missing}"
        else
            printf '   Your answer: '
            read -r answer || answer=""
        fi
        if [[ "$answer" == "$correct_option" ]]; then
            log_success "Correct — $skill_id"
            ASSESSMENT_SCORE=$((ASSESSMENT_SCORE + 1))
        else
            log_warn "Review: $skill_id"
        fi
    done < <(tail -n +2 "$file")
    # shellcheck disable=SC2034 # Read by cmd_assess after the assessment finishes.
    ASSESSMENT_TOTAL="$question_count"
}
