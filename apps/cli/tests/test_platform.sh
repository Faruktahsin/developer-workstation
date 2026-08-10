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

    # 2. Test init on non-macOS (Linux) -> exit code 2 with no plan, prompt, or writes
    local init_output
    local init_exit_code
    printf 'existing git config\n' > "${sandbox_home}/.gitconfig"
    set +e
    init_output="$("$CLI" init 2>&1)"
    init_exit_code=$?
    set -e
    assert_equals "2" "$init_exit_code" "Init exits 2 on unsupported platform"
    assert_contains "$init_output" "macOS-only" "Init explains macOS-only support"
    if [[ "$init_output" == *"Selected Profile"* || "$init_output" == *"[y/N]"* ]]; then
        assert_equals "no-plan-or-prompt" "plan-or-prompt-found" "Init performs no profile work or confirmation"
    else
        assert_equals "no-plan-or-prompt" "no-plan-or-prompt" "Init performs no profile work or confirmation"
    fi
    assert_equals "existing git config" "$(cat "${sandbox_home}/.gitconfig")" "Init performs no writes on unsupported platform"

    export PATH="$ORIGINAL_PATH"
    export HOME="$ORIGINAL_HOME"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "Platform Support Tests" test_unsupported_platform
    print_summary
fi
