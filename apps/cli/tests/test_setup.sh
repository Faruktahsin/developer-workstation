#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

test_learning_environment_setup() {
    local tmp_sandbox
    local sandbox_home
    local bin_dir
    local output
    local exit_code
    local original_path

    tmp_sandbox="$(mktemp -d 2>/dev/null || mktemp -d -t 'devcompass_setup_test')"
    sandbox_home="${tmp_sandbox}/home"
    bin_dir="${tmp_sandbox}/bin"
    mkdir -p "$sandbox_home" "$bin_dir"
    trap 'rm -rf "${tmp_sandbox:-}"' RETURN

    output="$(HOME="$sandbox_home" "$CLI" setup python --track data-science --level beginner --dry-run)"
    assert_contains "$output" "Python Learning Environment" "Setup dry-run prints the Python environment plan"
    assert_contains "$output" "NumPy (numpy)" "Setup dry-run lists NumPy"
    assert_contains "$output" "Pandas (pandas)" "Setup dry-run lists Pandas"
    assert_contains "$output" "Matplotlib (matplotlib)" "Setup dry-run lists Matplotlib"
    assert_contains "$output" "Zero system changes made" "Setup dry-run confirms no changes"
    if [[ -e "${sandbox_home}/.devcompass/environments/python-data-science-beginner" ]]; then
        assert_equals "not-created" "created" "Setup dry-run does not create an environment"
    else
        assert_equals "not-created" "not-created" "Setup dry-run does not create an environment"
    fi

    set +e
    output="$(printf 'n\n' | HOME="$sandbox_home" "$CLI" setup python --track data-science --level beginner 2>&1)"
    exit_code=$?
    set -e
    assert_equals "3" "$exit_code" "Setup refuses confirmation with exit code 3"
    assert_contains "$output" "setup aborted" "Setup reports a refused confirmation"
    if [[ -e "${sandbox_home}/.devcompass/environments/python-data-science-beginner" ]]; then
        assert_equals "not-created" "created" "Refused setup does not create an environment"
    else
        assert_equals "not-created" "not-created" "Refused setup does not create an environment"
    fi

    assert_exit_code 3 "$CLI" setup python --track data-science --level advanced --dry-run
    assert_exit_code 3 "$CLI" setup node --track data-science --level beginner --dry-run

    cat > "${bin_dir}/python3" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${1:-}" == "-m" && "${2:-}" == "venv" ]]; then
    environment_path="$3"
    mkdir -p "${environment_path}/bin"
    cat > "${environment_path}/bin/python" <<'PYTHON'
#!/usr/bin/env bash
set -Eeuo pipefail
printf '%s\n' "$*" >> "${DEVCOMPASS_TEST_LOG}"
PYTHON
    chmod +x "${environment_path}/bin/python"
    exit 0
fi

exit 1
EOF
    chmod +x "${bin_dir}/python3"

    original_path="$PATH"
    export PATH="${bin_dir}:${PATH}"
    export DEVCOMPASS_TEST_LOG="${tmp_sandbox}/python-commands.log"
    set +e
    output="$(printf 'y\n' | HOME="$sandbox_home" "$CLI" setup python --track data-science --level beginner 2>&1)"
    exit_code=$?
    set -e
    assert_equals "0" "$exit_code" "Accepted setup completes successfully"
    assert_contains "$output" "Python learning environment is ready" "Accepted setup reports the environment path"
    if [[ -x "${sandbox_home}/.devcompass/environments/python-data-science-beginner/bin/python" ]]; then
        assert_equals "created" "created" "Accepted setup creates an isolated environment"
    else
        assert_equals "created" "not-created" "Accepted setup creates an isolated environment"
    fi
    output="$(cat "${DEVCOMPASS_TEST_LOG}")"
    assert_contains "$output" "install numpy" "Accepted setup installs NumPy through the environment"
    assert_contains "$output" "install pandas" "Accepted setup installs Pandas through the environment"
    assert_contains "$output" "install matplotlib" "Accepted setup installs Matplotlib through the environment"

    : > "${DEVCOMPASS_TEST_LOG}"
    output="$(HOME="$sandbox_home" "$CLI" setup python --track data-science --level beginner --yes)"
    assert_contains "$output" "Auto-confirmed via --yes flag" "Setup --yes explicitly auto-confirms"
    assert_contains "$output" "Python environment already exists; preserving it" "Setup rerun preserves the existing environment"
    output="$(cat "${DEVCOMPASS_TEST_LOG}")"
    if [[ "$output" == *"install --upgrade pip"* ]]; then
        assert_equals "pip-upgrade-skipped" "pip-upgrade-ran" "Setup rerun does not upgrade pip"
    else
        assert_equals "pip-upgrade-skipped" "pip-upgrade-skipped" "Setup rerun does not upgrade pip"
    fi
    assert_contains "$output" "install numpy" "Setup rerun checks NumPy without forcing an upgrade"
    export PATH="$original_path"
    unset DEVCOMPASS_TEST_LOG
}
