#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"

test_unsupported_platform() {
    local tmp_sandbox
    tmp_sandbox="$(mktemp -d 2>/dev/null || mktemp -d -t 'devcompass_plat_test')"
    local bin_dir="${tmp_sandbox}/bin"
    local sandbox_home="${tmp_sandbox}/home"
    mkdir -p "$bin_dir" "$sandbox_home"
    trap 'rm -rf "${tmp_sandbox:-}"' EXIT

    local ORIGINAL_PATH="$PATH"
    local ORIGINAL_HOME="$HOME"
    export PATH="${bin_dir}:${PATH}"
    export HOME="$sandbox_home"

    cat <<'EOF' > "${bin_dir}/uname"
#!/usr/bin/env bash
if [[ "${1:-}" == "-m" ]]; then
    echo "x86_64"
else
    echo "Linux"
fi
EOF
    chmod +x "${bin_dir}/uname"

    # 1. Test doctor on non-macOS (Linux) -> exit code 1
    assert_exit_code 1 "$CLI" doctor

    # 2. Test init on non-macOS (Linux) -> exit code 2 (unsupported platform)
    assert_exit_code 2 "$CLI" init

    export PATH="$ORIGINAL_PATH"
    export HOME="$ORIGINAL_HOME"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "Platform Support Tests" test_unsupported_platform
    print_summary
fi
