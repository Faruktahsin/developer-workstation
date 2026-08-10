#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"

test_doctor_command() {
    local tmp_sandbox
    tmp_sandbox="$(mktemp -d 2>/dev/null || mktemp -d -t 'devcompass_doc_test')"
    local bin_dir="${tmp_sandbox}/bin"
    local sandbox_home="${tmp_sandbox}/home"
    mkdir -p "$bin_dir" "$sandbox_home"
    trap 'rm -rf "${tmp_sandbox:-}"' EXIT

    # Prepend mock bin directory to PATH and isolate HOME
    local ORIGINAL_PATH="$PATH"
    local ORIGINAL_HOME="$HOME"
    export PATH="${bin_dir}:${PATH}"
    export HOME="$sandbox_home"

    # Mock binaries placed in PATH
    cat <<'EOF' > "${bin_dir}/uname"
#!/usr/bin/env bash
if [[ "${1:-}" == "-m" ]]; then
    echo "arm64"
else
    echo "Darwin"
fi
EOF

    cat <<'EOF' > "${bin_dir}/sw_vers"
#!/usr/bin/env bash
echo "14.2.1"
EOF

    cat <<'EOF' > "${bin_dir}/xcode-select"
#!/usr/bin/env bash
if [[ "${TEST_XCODE_STATUS:-installed}" == "missing" ]]; then
    exit 1
fi
echo "/Library/Developer/CommandLineTools"
EOF

    cat <<'EOF' > "${bin_dir}/brew"
#!/usr/bin/env bash
echo "Homebrew 4.2.0"
EOF

    cat <<'EOF' > "${bin_dir}/git"
#!/usr/bin/env bash
echo "git version 2.43.0"
EOF

    chmod +x "${bin_dir}"/*

    local output
    output="$("$CLI" doctor)"

    assert_contains "$output" "DevCompass Workstation Doctor" "Doctor header"
    assert_contains "$output" "macOS detected" "Doctor macOS check"
    assert_contains "$output" "Xcode Command Line Tools installed" "Doctor Xcode check"
    assert_contains "$output" "System readiness verified" "Doctor success summary"

    # Test doctor critical failure when Xcode CLI missing
    export TEST_XCODE_STATUS="missing"
    local fail_output
    set +e
    fail_output="$("$CLI" doctor 2>&1)"
    local exit_code=$?
    set -e
    export TEST_XCODE_STATUS="installed"

    assert_equals "1" "$exit_code" "Doctor exit code 1 when critical check fails"
    assert_contains "$fail_output" "critical check(s) failed" "Doctor failure message"

    # Restore PATH and HOME
    export PATH="$ORIGINAL_PATH"
    export HOME="$ORIGINAL_HOME"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "Doctor Command Tests" test_doctor_command
    print_summary
fi
