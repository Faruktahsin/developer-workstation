#!/usr/bin/env bash

set -Eeuo pipefail

recommend_usage() {
    log_error "Usage: devcompass recommend --role <role-id> [--format plain|json]"
}

cmd_recommend() {
    local role_id=""
    local output_format="plain"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --role)
                if [[ $# -lt 2 || -z "$2" ]]; then
                    recommend_usage
                    return 3
                fi
                role_id="$2"
                shift
                ;;
            --role=*)
                role_id="${1#*=}"
                ;;
            --format)
                if [[ $# -lt 2 || -z "$2" ]]; then
                    recommend_usage
                    return 3
                fi
                output_format="$2"
                shift
                ;;
            --format=*)
                output_format="${1#*=}"
                ;;
            *)
                recommend_usage
                return 3
                ;;
        esac
        shift
    done

    if [[ -z "$role_id" ]] || [[ "$output_format" != "plain" && "$output_format" != "json" ]]; then
        recommend_usage
        return 3
    fi

    if ! validate_knowledge_graph; then
        log_error "Knowledge graph is invalid; cannot create a recommendation."
        return 2
    fi

    if ! knowledge_node_exists "$role_id" || [[ "$(recommendation_node_type "$role_id")" != "role" ]]; then
        log_error "Role '$role_id' was not found in the knowledge graph."
        log_info "Try 'devcompass knowledge show role.backend', 'role.web', or 'role.devops'."
        return 1
    fi

    build_role_recommendation "$role_id"

    if [[ ${#RECOMMENDATION_NODE_IDS[@]} -eq 0 ]]; then
        log_error "Role '$role_id' has no requirements in the knowledge graph."
        return 2
    fi

    case "$output_format" in
        plain) render_role_recommendation_plain "$role_id" ;;
        json) render_role_recommendation_json "$role_id" ;;
    esac
}
