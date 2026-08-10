#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"

test_parser_commands() {
    local output

    output="$("$CLI" --help)"
    assert_contains "$output" "DevCompass — Developer Operating System" "CLI --help output"
    assert_contains "$output" "COMMANDS:" "CLI --help commands section"

    output="$("$CLI" version)"
    assert_contains "$output" "DevCompass version 0.1.0-foundation" "CLI version command"

    output="$("$CLI" --version)"
    assert_contains "$output" "DevCompass version 0.1.0-foundation" "CLI --version flag"

    assert_exit_code 1 "$CLI" --unknown-flag
    assert_exit_code 1 "$CLI" invalidcommand
    assert_exit_code 1 "$CLI" doctor init
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "CLI Parser Tests" test_parser_commands
    print_summary
fi
