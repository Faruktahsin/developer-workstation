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

prerequisite_path_contains_node() {
    local node_id="$1"
    local existing_id

    for existing_id in "${PREREQUISITE_PATH_NODE_IDS[@]:-}"; do
        [[ "$existing_id" == "$node_id" ]] && return 0
    done
    return 1
}

prerequisite_path_is_active() {
    local node_id="$1"
    local active_id

    for active_id in "${PREREQUISITE_PATH_ACTIVE_IDS[@]:-}"; do
        [[ "$active_id" == "$node_id" ]] && return 0
    done
    return 1
}

collect_prerequisite_path_node() {
    local node_id="$1"
    local prerequisite_id
    local last_index

    if prerequisite_path_contains_node "$node_id"; then
        return 0
    fi

    if prerequisite_path_is_active "$node_id"; then
        PREREQUISITE_PATH_ERROR="Cycle detected in depends_on relationships at '$node_id'."
        return 1
    fi

    PREREQUISITE_PATH_ACTIVE_IDS+=("$node_id")
    while IFS= read -r prerequisite_id; do
        [[ -n "$prerequisite_id" ]] || continue
        if ! collect_prerequisite_path_node "$prerequisite_id"; then
            return 1
        fi
    done < <(
        awk -F '\t' -v id="$node_id" 'NR > 1 && $1 == id && $2 == "depends_on" { print $3 }' \
            "$(get_knowledge_edges_file)" | LC_ALL=C sort
    )

    last_index=$((${#PREREQUISITE_PATH_ACTIVE_IDS[@]} - 1))
    unset "PREREQUISITE_PATH_ACTIVE_IDS[$last_index]"
    PREREQUISITE_PATH_NODE_IDS+=("$node_id")
}

build_prerequisite_path() {
    local goal_id="$1"

    PREREQUISITE_PATH_NODE_IDS=()
    PREREQUISITE_PATH_ACTIVE_IDS=()
    # shellcheck disable=SC2034 # Read by cmd_recommend after a traversal failure.
    PREREQUISITE_PATH_ERROR=""
    collect_prerequisite_path_node "$goal_id"
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

render_prerequisite_path_plain() {
    local goal_id="$1"
    local goal_label
    local node_id
    local step=1

    goal_label="$(recommendation_node_label "$goal_id")"
    log_bold "🧭 DevCompass Prerequisite Path: $goal_label"
    echo "=================================================="
    echo "Goal  : $goal_id"
    echo "Basis : transitive depends_on relationships in the offline graph"
    echo "Order : prerequisites appear before the goal"
    echo

    for node_id in "${PREREQUISITE_PATH_NODE_IDS[@]}"; do
        printf '%d. %s [%s]\n' "$step" "$(recommendation_node_label "$node_id")" "$node_id"
        step=$((step + 1))
    done

    echo
    echo "Use 'devcompass knowledge show <id>' to inspect a path item."
}

render_prerequisite_path_json() {
    local goal_id="$1"
    local goal_label
    local node_id
    local first=true
    local step=1

    goal_label="$(recommendation_node_label "$goal_id")"
    printf '{\n'
    printf '  "goal":{"id":"%s","label":"%s","type":"%s"},\n' \
        "$(recommendation_json_escape "$goal_id")" \
        "$(recommendation_json_escape "$goal_label")" \
        "$(recommendation_json_escape "$(recommendation_node_type "$goal_id")")"
    printf '  "basis":"transitive depends_on relationships in the offline graph",\n'
    printf '  "order":"prerequisites appear before the goal",\n'
    printf '  "steps":[\n'

    for node_id in "${PREREQUISITE_PATH_NODE_IDS[@]}"; do
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
