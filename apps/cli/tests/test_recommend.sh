#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

test_recommendation_engine() {
    local output
    local tmp_graph_root
    local original_devcompass_root

    output="$("$CLI" recommend --role role.devops)"
    assert_contains "$output" "DevOps Engineer" "DevOps roadmap identifies the requested role"
    assert_contains "$output" "1. Git [skill.git]" "DevOps roadmap begins with a role requirement"
    assert_contains "$output" "5. Containers [skill.containers]" "DevOps roadmap includes containers"
    assert_contains "$output" "6. Docker [technology.docker]" "DevOps roadmap includes the container technology"
    assert_contains "$output" "7. Docker CLI [tool.docker]" "DevOps roadmap includes the directly used tool"
    assert_contains "$output" "not a claimed prerequisite sequence" "Plain roadmap explains its scope"

    output="$("$CLI" recommend --role role.web --format json)"
    assert_contains "$output" '"id":"role.web"' "JSON roadmap contains the requested role"
    assert_contains "$output" '"id":"skill.javascript"' "JSON roadmap includes JavaScript"
    assert_contains "$output" '"id":"technology.nodejs"' "JSON roadmap includes Node.js"
    assert_contains "$output" '"steps":[' "JSON roadmap contains step data"

    output="$("$CLI" recommend path --goal package.pandas)"
    assert_contains "$output" "Prerequisite Path: Pandas" "Prerequisite path identifies the requested goal"
    assert_contains "$output" "1. Python [skill.python]" "Prerequisite path begins with Python"
    assert_contains "$output" "2. NumPy [package.numpy]" "Prerequisite path places NumPy after Python"
    assert_contains "$output" "3. Pandas [package.pandas]" "Prerequisite path places the goal last"
    assert_contains "$output" "prerequisites appear before the goal" "Prerequisite path explains ordering"

    output="$("$CLI" recommend path --goal skill.data-analysis --format json)"
    assert_contains "$output" '"goal":{"id":"skill.data-analysis"' "JSON prerequisite path contains the requested goal"
    assert_contains "$output" '"id":"skill.python"' "JSON prerequisite path contains the prerequisite"
    assert_contains "$output" '"order":"prerequisites appear before the goal"' "JSON prerequisite path declares ordering"

    assert_exit_code 1 "$CLI" recommend --role role.unknown
    assert_exit_code 1 "$CLI" recommend --role skill.git
    assert_exit_code 3 "$CLI" recommend
    assert_exit_code 3 "$CLI" recommend --role role.devops --format yaml
    assert_exit_code 3 "$CLI" recommend --role role.devops --unknown
    assert_exit_code 3 "$CLI" recommend path
    assert_exit_code 3 "$CLI" recommend path --role role.devops
    assert_exit_code 1 "$CLI" recommend path --goal package.unknown
    assert_exit_code 1 "$CLI" --profile devops recommend --role role.devops

    tmp_graph_root="$(mktemp -d 2>/dev/null || mktemp -d -t 'devcompass_recommend_test')"
    mkdir -p "${tmp_graph_root}/packages/knowledge/graph"
    printf '%s\n' \
        $'id\ttype\tlabel\tdescription' \
        $'skill.alpha\tskill\tAlpha\tSynthetic test node.' \
        $'skill.beta\tskill\tBeta\tSynthetic test node.' \
        > "${tmp_graph_root}/packages/knowledge/graph/nodes.tsv"
    printf '%s\n' \
        $'source_id\trelation\ttarget_id' \
        $'skill.alpha\tdepends_on\tskill.beta' \
        $'skill.beta\tdepends_on\tskill.alpha' \
        > "${tmp_graph_root}/packages/knowledge/graph/edges.tsv"

    original_devcompass_root="$DEVCOMPASS_ROOT"
    export DEVCOMPASS_ROOT="$tmp_graph_root"
    # shellcheck disable=SC1091 # Sourced again with a temporary graph root for this test.
    source "${REPO_ROOT}/apps/cli/lib/knowledge.sh"
    # shellcheck disable=SC1091 # Sourced again with a temporary graph root for this test.
    source "${REPO_ROOT}/apps/cli/lib/recommendations.sh"
    if build_prerequisite_path "skill.alpha"; then
        assert_equals "cycle-rejected" "cycle-accepted" "Prerequisite path rejects depends_on cycles"
    else
        assert_contains "$PREREQUISITE_PATH_ERROR" "Cycle detected" "Prerequisite path reports detected cycles"
    fi
    export DEVCOMPASS_ROOT="$original_devcompass_root"
    rm -rf "$tmp_graph_root"
}
