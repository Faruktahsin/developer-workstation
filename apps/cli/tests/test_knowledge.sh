#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

test_knowledge_engine() {
    local output

    output="$("$CLI" knowledge status)"
    assert_contains "$output" "Graph status : valid" "Knowledge status reports a valid graph"
    assert_contains "$output" "Nodes        : 22" "Knowledge status reports node count"
    assert_contains "$output" "Edges        : 25" "Knowledge status reports edge count"

    assert_exit_code 0 "$CLI" knowledge validate

    output="$("$CLI" knowledge show role.backend)"
    assert_contains "$output" "Backend Developer" "Knowledge show displays node label"
    assert_contains "$output" "requires → skill.git" "Knowledge show displays relationships"

    assert_exit_code 1 "$CLI" knowledge show unknown.node
    assert_exit_code 1 "$CLI" knowledge status extra
}
