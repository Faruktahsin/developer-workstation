#!/usr/bin/env bash

set -Eeuo pipefail

get_knowledge_dir() {
    printf '%s\n' "${DEVCOMPASS_ROOT}/packages/knowledge/graph"
}

get_knowledge_nodes_file() {
    printf '%s\n' "$(get_knowledge_dir)/nodes.tsv"
}

get_knowledge_edges_file() {
    printf '%s\n' "$(get_knowledge_dir)/edges.tsv"
}

knowledge_node_exists() {
    local node_id="$1"
    awk -F '\t' -v id="$node_id" 'NR > 1 && $1 == id { found = 1 } END { exit !found }' "$(get_knowledge_nodes_file)"
}

validate_knowledge_graph() {
    local nodes_file
    local edges_file
    local result=0

    nodes_file="$(get_knowledge_nodes_file)"
    edges_file="$(get_knowledge_edges_file)"

    [[ -f "$nodes_file" && -f "$edges_file" ]] || return 1
    [[ "$(head -n 1 "$nodes_file")" == $'id\ttype\tlabel\tdescription' ]] || return 1
    [[ "$(head -n 1 "$edges_file")" == $'source_id\trelation\ttarget_id' ]] || return 1

    while IFS=$'\t' read -r node_id node_type node_label node_description; do
        [[ -n "$node_id" && -n "$node_type" && -n "$node_label" && -n "$node_description" ]] || { result=1; break; }
        [[ "$node_id" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || { result=1; break; }
        case "$node_type" in role|skill|technology|tool|playbook) ;; *) result=1; break ;; esac
    done < <(tail -n +2 "$nodes_file")

    [[ $result -eq 0 ]] || return 1
    [[ "$(tail -n +2 "$nodes_file" | cut -f1 | sort | uniq -d | wc -l | tr -d ' ')" == "0" ]] || return 1

    while IFS=$'\t' read -r source_id relation target_id; do
        [[ -n "$source_id" && -n "$relation" && -n "$target_id" ]] || { result=1; break; }
        case "$relation" in requires|uses|guides_to) ;; *) result=1; break ;; esac
        if ! knowledge_node_exists "$source_id" || ! knowledge_node_exists "$target_id"; then
            result=1
            break
        fi
    done < <(tail -n +2 "$edges_file")

    return "$result"
}

knowledge_node_count() {
    tail -n +2 "$(get_knowledge_nodes_file)" | wc -l | tr -d ' '
}

knowledge_edge_count() {
    tail -n +2 "$(get_knowledge_edges_file)" | wc -l | tr -d ' '
}

show_knowledge_node() {
    local node_id="$1"
    local nodes_file
    local edges_file
    local node_line

    nodes_file="$(get_knowledge_nodes_file)"
    edges_file="$(get_knowledge_edges_file)"
    node_line="$(awk -F '\t' -v id="$node_id" 'NR > 1 && $1 == id { print; exit }' "$nodes_file")"
    [[ -n "$node_line" ]] || return 1

    IFS=$'\t' read -r _ node_type node_label node_description <<< "$node_line"
    log_bold "📚 Knowledge Node: $node_id"
    echo "=================================================="
    echo "Type        : $node_type"
    echo "Label       : $node_label"
    echo "Description : $node_description"
    echo
    log_bold "Relationships:"
    awk -F '\t' -v id="$node_id" '$1 == id { print "  • " $2 " → " $3 } $3 == id { print "  • " $1 " → " $2 }' "$edges_file"
    echo "=================================================="
}
