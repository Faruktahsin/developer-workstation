#!/usr/bin/env bash

set -Eeuo pipefail

recommendation_node_label() {
    local node_id="$1"
    awk -F '\t' -v id="$node_id" 'NR > 1 && $1 == id { print $3; exit }' "$(get_knowledge_nodes_file)"
}

recommendation_node_type() {
    local node_id="$1"
    awk -F '\t' -v id="$node_id" 'NR > 1 && $1 == id { print $2; exit }' "$(get_knowledge_nodes_file)"
}

recommendation_json_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\t'/\\t}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\n'/\\n}"
    printf '%s' "$value"
}

recommendation_contains_node() {
    local node_id="$1"
    local existing_id

    for existing_id in "${RECOMMENDATION_NODE_IDS[@]:-}"; do
        [[ "$existing_id" == "$node_id" ]] && return 0
    done
    return 1
}

collect_recommendation_node() {
    local node_id="$1"
    local related_node_id

    if recommendation_contains_node "$node_id"; then
        return 0
    fi

    RECOMMENDATION_NODE_IDS+=("$node_id")

    while IFS= read -r related_node_id; do
        [[ -n "$related_node_id" ]] || continue
        collect_recommendation_node "$related_node_id"
    done < <(
        awk -F '\t' -v id="$node_id" 'NR > 1 && $1 == id && $2 == "uses" { print $3 }' \
            "$(get_knowledge_edges_file)"
    )
}

build_role_recommendation() {
    local role_id="$1"
    local required_node_id

    RECOMMENDATION_NODE_IDS=()

    while IFS= read -r required_node_id; do
        [[ -n "$required_node_id" ]] || continue
        collect_recommendation_node "$required_node_id"
    done < <(
        awk -F '\t' -v id="$role_id" 'NR > 1 && $1 == id && $2 == "requires" { print $3 }' \
            "$(get_knowledge_edges_file)"
    )

    while IFS= read -r required_node_id; do
        [[ -n "$required_node_id" ]] || continue
        collect_recommendation_node "$required_node_id"
    done < <(
        awk -F '\t' -v id="$role_id" 'NR > 1 && $1 == id && $2 == "uses" { print $3 }' \
            "$(get_knowledge_edges_file)"
    )
}

render_role_recommendation_plain() {
    local role_id="$1"
    local role_label
    local node_id
    local step=1

    role_label="$(recommendation_node_label "$role_id")"
    log_bold "🧭 DevCompass Recommendation: $role_label"
    echo "=================================================="
    echo "Basis : role requirements and directly used tools from the offline graph"
    echo "Note  : this is a role roadmap, not a claimed prerequisite sequence"
    echo

    for node_id in "${RECOMMENDATION_NODE_IDS[@]}"; do
        printf '%d. %s [%s]\n' "$step" "$(recommendation_node_label "$node_id")" "$node_id"
        step=$((step + 1))
    done

    echo
    echo "Use 'devcompass knowledge show <id>' to inspect a recommendation item."
}

render_role_recommendation_json() {
    local role_id="$1"
    local role_label
    local node_id
    local first=true
    local step=1

    role_label="$(recommendation_node_label "$role_id")"
    printf '{\n'
    printf '  "role":{"id":"%s","label":"%s"},\n' \
        "$(recommendation_json_escape "$role_id")" \
        "$(recommendation_json_escape "$role_label")"
    printf '  "basis":"role requirements and directly used tools from the offline graph",\n'
    printf '  "note":"This is a role roadmap, not a claimed prerequisite sequence.",\n'
    printf '  "steps":[\n'

    for node_id in "${RECOMMENDATION_NODE_IDS[@]}"; do
        [[ "$first" == "true" ]] || printf ',\n'
        first=false
        printf '    {"step":%d,"id":"%s","label":"%s","type":"%s"}' \
            "$step" \
            "$(recommendation_json_escape "$node_id")" \
            "$(recommendation_json_escape "$(recommendation_node_label "$node_id")")" \
            "$(recommendation_json_escape "$(recommendation_node_type "$node_id")")"
        step=$((step + 1))
    done

    printf '\n  ]\n}\n'
}
