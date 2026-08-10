#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

test_recommendation_engine() {
    local output

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

    assert_exit_code 1 "$CLI" recommend --role role.unknown
    assert_exit_code 1 "$CLI" recommend --role skill.git
    assert_exit_code 3 "$CLI" recommend
    assert_exit_code 3 "$CLI" recommend --role role.devops --format yaml
    assert_exit_code 3 "$CLI" recommend --role role.devops --unknown
    assert_exit_code 1 "$CLI" --profile devops recommend --role role.devops
}
