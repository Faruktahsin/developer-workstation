#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"

test_regression_no_env_overrides() {
    local output

    # 1. Test version command ignores malicious command & mock environment variables
    output="$(DEVCOMPASS_UNAME_CMD="/bin/nonexistent_command" DEVCOMPASS_MOCK_UNAME="Linux" "$CLI" version)"
    assert_contains "$output" "DevCompass version 0.1.0-foundation" "Version command ignores DEVCOMPASS_UNAME_CMD and DEVCOMPASS_MOCK_UNAME"

    # 2. Test doctor command ignores malicious DEVCOMPASS_*_CMD variables
    set +e
    output="$(DEVCOMPASS_UNAME_CMD="/bin/nonexistent" \
              DEVCOMPASS_XCODE_SELECT_CMD="/bin/nonexistent" \
              DEVCOMPASS_BREW_CMD="/bin/nonexistent" \
              DEVCOMPASS_BREW_INSTALL_RUNNER="/bin/nonexistent" \
              DEVCOMPASS_GIT_CMD="/bin/nonexistent" \
              DEVCOMPASS_PYTHON_CMD="/bin/nonexistent" \
              DEVCOMPASS_NODE_CMD="/bin/nonexistent" \
              DEVCOMPASS_HOME="/tmp/fake_dir" \
              DEVCOMPASS_MOCK_UNAME="Linux" \
              "$CLI" doctor 2>&1)"
    local exit_code=$?
    set -e

    assert_equals "0" "$exit_code" "Doctor command ignores DEVCOMPASS_*_CMD and succeeds on real macOS system"
    assert_contains "$output" "DevCompass Workstation Doctor" "Doctor executes normally despite DEVCOMPASS_* overrides"
    assert_contains "$output" "macOS detected" "Doctor uses real uname/is_macos despite DEVCOMPASS_MOCK_UNAME"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "Regression Tests — No Environment Overrides" test_regression_no_env_overrides
    print_summary
fi
