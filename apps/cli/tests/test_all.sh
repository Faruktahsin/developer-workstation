#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"
# shellcheck source=apps/cli/tests/test_parser.sh
source "${TEST_DIR}/test_parser.sh"
# shellcheck source=apps/cli/tests/test_doctor.sh
source "${TEST_DIR}/test_doctor.sh"
# shellcheck source=apps/cli/tests/test_init.sh
source "${TEST_DIR}/test_init.sh"
# shellcheck source=apps/cli/tests/test_profiles.sh
source "${TEST_DIR}/test_profiles.sh"
# shellcheck source=apps/cli/tests/test_profiles_schema.sh
source "${TEST_DIR}/test_profiles_schema.sh"
# shellcheck source=apps/cli/tests/test_cli_validation.sh
source "${TEST_DIR}/test_cli_validation.sh"
# shellcheck source=apps/cli/tests/test_platform.sh
source "${TEST_DIR}/test_platform.sh"
# shellcheck source=apps/cli/tests/test_regression_no_env_overrides.sh
source "${TEST_DIR}/test_regression_no_env_overrides.sh"

main() {
    printf "\n========================================\n"
    printf "🚀 DevCompass Test Suite\n"
    printf "========================================\n"

    run_test_suite "CLI Parser Tests" test_parser_commands
    run_test_suite "Doctor Command Tests" test_doctor_command
    run_test_suite "Init Command & Safety Tests" test_init_safety_and_idempotency
    run_test_suite "Workspace Profiles & Resolution Tests" test_profiles_feature
    run_test_suite "Profile Schema Tests" test_profiles_schema
    run_test_suite "CLI Validation Tests" test_cli_validation
    run_test_suite "Platform Support Tests" test_unsupported_platform
    run_test_suite "Regression Tests — No Environment Overrides" test_regression_no_env_overrides

    print_summary
}

main "$@"
