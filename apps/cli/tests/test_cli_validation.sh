#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

test_cli_validation() {
    assert_exit_code 1 "$CLI" init doctor
    assert_exit_code 1 "$CLI" init --dry-run doctor
    assert_exit_code 1 "$CLI" doctor --profile web
    assert_exit_code 1 "$CLI" doctor --dry-run
    assert_exit_code 1 "$CLI" version extra
    assert_exit_code 1 "$CLI" profile list extra
    assert_exit_code 1 "$CLI" profile show
    assert_exit_code 1 "$CLI" profile show web extra
}
