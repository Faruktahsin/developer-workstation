#!/usr/bin/env bash

set -Eeuo pipefail

recommend_usage() {
    log_error "Usage: devcompass recommend --role <role-id> [--format plain|json]"
    log_error "   or: devcompass recommend path --goal <node-id> [--format plain|json]"
}

cmd_recommend() {
    local mode="role-roadmap"
    local role_id=""
    local goal_id=""
    local output_format="plain"

    if [[ "${1:-}" == "path" ]]; then
        mode="prerequisite-path"
        shift
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --role)
                if [[ "$mode" != "role-roadmap" || $# -lt 2 || -z "$2" ]]; then
                    recommend_usage
                    return 3
                fi
                role_id="$2"
                shift
                ;;
            --role=*)
                if [[ "$mode" != "role-roadmap" ]]; then
                    recommend_usage
                    return 3
                fi
                role_id="${1#*=}"
                ;;
            --goal)
                if [[ "$mode" != "prerequisite-path" || $# -lt 2 || -z "$2" ]]; then
                    recommend_usage
                    return 3
                fi
                goal_id="$2"
                shift
                ;;
            --goal=*)
                if [[ "$mode" != "prerequisite-path" ]]; then
                    recommend_usage
                    return 3
                fi
                goal_id="${1#*=}"
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

    if [[ "$output_format" != "plain" && "$output_format" != "json" ]]; then
        recommend_usage
        return 3
    fi

    if ! validate_knowledge_graph; then
        log_error "Knowledge graph is invalid; cannot create a recommendation."
        return 2
    fi

    case "$mode" in
        role-roadmap)
            if [[ -z "$role_id" ]]; then
                recommend_usage
                return 3
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
            ;;
        prerequisite-path)
            if [[ -z "$goal_id" ]]; then
                recommend_usage
                return 3
            fi
            if ! knowledge_node_exists "$goal_id"; then
                log_error "Goal '$goal_id' was not found in the knowledge graph."
                log_info "Try 'devcompass knowledge show package.pandas' or 'skill.data-analysis'."
                return 1
            fi
            if ! build_prerequisite_path "$goal_id"; then
                log_error "${PREREQUISITE_PATH_ERROR:-Unable to build prerequisite path.}"
                return 2
            fi
            case "$output_format" in
                plain) render_prerequisite_path_plain "$goal_id" ;;
                json) render_prerequisite_path_json "$goal_id" ;;
            esac
            ;;
    esac
}
