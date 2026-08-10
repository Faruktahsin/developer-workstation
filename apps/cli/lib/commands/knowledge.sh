#!/usr/bin/env bash

set -Eeuo pipefail

cmd_knowledge() {
    local subcommand="${1:-status}"

    case "$subcommand" in
        status)
            if validate_knowledge_graph; then
                log_bold "📚 DevCompass Knowledge Engine"
                echo "=================================================="
                echo "Graph status : valid"
                echo "Nodes        : $(knowledge_node_count)"
                echo "Edges        : $(knowledge_edge_count)"
                echo "Storage      : offline versioned TSV graph"
                return 0
            fi
            log_error "Knowledge graph validation failed. Run 'devcompass knowledge validate' for the exit status."
            return 1
            ;;
        validate)
            if validate_knowledge_graph; then
                log_success "Knowledge graph is valid."
                return 0
            fi
            log_error "Knowledge graph is invalid."
            return 1
            ;;
        show)
            if show_knowledge_node "${2:-}"; then
                return 0
            fi
            log_error "Knowledge node '${2:-}' was not found."
            return 1
            ;;
    esac
}
