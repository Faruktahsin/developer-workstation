#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

test_assessment_engine() {
    local output

    output="$("$CLI" assess --role role.data-science --answers 1,1,1)"
    assert_contains "$output" "DevCompass Assessment: Data Scientist" "Assessment identifies the requested role"
    assert_contains "$output" "Score: 3/3" "Assessment scores correct answers"
    assert_contains "$output" "Strong foundation" "Assessment gives a next step for a strong result"

    output="$("$CLI" assess --role role.data-science --answers 2,1,3)"
    assert_contains "$output" "Score: 1/3" "Assessment scores mixed answers"
    assert_contains "$output" "recommend path --goal skill.data-analysis" "Assessment gives a review path"

    assert_exit_code 3 "$CLI" assess
    assert_exit_code 3 "$CLI" assess --role role.web --answers 1,1,1
    assert_exit_code 1 "$CLI" --dry-run assess --role role.data-science
}
