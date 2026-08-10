#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"

test_init_safety_and_idempotency() {
    local tmp_sandbox
    tmp_sandbox="$(mktemp -d 2>/dev/null || mktemp -d -t 'devcompass_init_test')"
    local sandbox_home="${tmp_sandbox}/home"
    local bin_dir="${tmp_sandbox}/bin"
    mkdir -p "$sandbox_home" "$bin_dir"
    trap 'rm -rf "${tmp_sandbox:-}"' EXIT

    local ORIGINAL_PATH="$PATH"
    local ORIGINAL_HOME="$HOME"
    export PATH="${bin_dir}:${PATH}"
    export HOME="$sandbox_home"

    # Create mock binaries in PATH
    cat <<'EOF' > "${bin_dir}/uname"
#!/usr/bin/env bash
if [[ "${1:-}" == "-m" ]]; then echo "arm64"; else echo "Darwin"; fi
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
if [[ "${1:-}" == "--version" ]]; then
    echo "Homebrew 4.2.0"
    exit 0
fi
if [[ "${1:-}" == "bundle" ]]; then
    if [[ "${TEST_BREW_BUNDLE_STATUS:-success}" == "fail" ]]; then
        echo "Error: Failed to install formula foo" >&2
        exit 1
    fi
    echo "Homebrew bundle satisfied."
    exit 0
fi
EOF

    cat <<'EOF' > "${bin_dir}/git"
#!/usr/bin/env bash
echo "git version 2.43.0"
EOF

    chmod +x "${bin_dir}"/*

    # Pre-create user configuration files
    local git_config="${sandbox_home}/.gitconfig"
    local zsh_rc="${sandbox_home}/.zshrc"
    printf "[user]\n    name = Test User\n    email = test@example.com\n" > "$git_config"
    printf "# USER PRE-EXISTING ZSHRC\nexport MY_CUSTOM_VAR=1\n" > "$zsh_rc"

    # --- 1. Test Dry-Run performs ZERO writes and ZERO backups ---
    local dryrun_output
    dryrun_output="$("$CLI" init --dry-run)"

    assert_contains "$dryrun_output" "[DRY-RUN] Execution plan completed" "Dry-run header present"
    assert_contains "$dryrun_output" "macOS system defaults are excluded" "Dry-run opt-in notice"

    local git_content zsh_content backup_count
    git_content="$(cat "$git_config")"
    zsh_content="$(cat "$zsh_rc")"
    backup_count=$(find "$sandbox_home" -name "*devcompass_backup*" | wc -l | tr -d ' ')

    assert_contains "$git_content" "test@example.com" "Dry-run preserved gitconfig user email"
    if grep -qF "# DEVCOMPASS BEGIN" "$git_config"; then
        assert_equals "no_block" "block_found" "Dry-run did not add gitconfig block"
    else
        assert_equals "no_block" "no_block" "Dry-run did not add gitconfig block"
    fi

    assert_contains "$zsh_content" "MY_CUSTOM_VAR=1" "Dry-run preserved zshrc custom var"
    if grep -qF "# DEVCOMPASS BEGIN" "$zsh_rc"; then
        assert_equals "no_block" "block_found" "Dry-run did not add zshrc block"
    else
        assert_equals "no_block" "no_block" "Dry-run did not add zshrc block"
    fi
    assert_equals "0" "$backup_count" "Dry-run created 0 backups"

    # --- 2. Test Refused Confirmation performs ZERO writes ---
    assert_exit_code 3 bash -c "echo 'n' | '$CLI' init"

    git_content="$(cat "$git_config")"
    backup_count=$(find "$sandbox_home" -name "*devcompass_backup*" | wc -l | tr -d ' ')
    assert_contains "$git_content" "test@example.com" "Refused confirmation preserved original gitconfig"
    if grep -qF "# DEVCOMPASS BEGIN" "$git_config"; then
        assert_equals "no_block" "block_found" "Refused confirmation did not add gitconfig block"
    else
        assert_equals "no_block" "no_block" "Refused confirmation did not add gitconfig block"
    fi
    assert_equals "0" "$backup_count" "Refused confirmation created 0 backups"

    # --- 3. Test Accepted Init Additive Integration ---
    local init_output
    init_output="$(echo "y" | "$CLI" init)"

    assert_contains "$init_output" "DevCompass Workstation initialization complete" "Accepted init success header"

    git_content="$(cat "$git_config")"
    zsh_content="$(cat "$zsh_rc")"
    backup_count=$(find "$sandbox_home" -name "*devcompass_backup*" | wc -l | tr -d ' ')

    assert_contains "$git_content" "test@example.com" "Accepted init PRESERVED user gitconfig content"
    assert_contains "$git_content" "# DEVCOMPASS BEGIN" "Accepted init APPENDED gitconfig include block"
    assert_contains "$git_content" "path = ~/.devcompass/config/gitconfig" "Gitconfig include path is correct"

    assert_contains "$zsh_content" "MY_CUSTOM_VAR=1" "Accepted init PRESERVED user zshrc content"
    assert_contains "$zsh_content" "# DEVCOMPASS BEGIN" "Accepted init APPENDED zshrc source block"
    assert_contains "$zsh_content" "source \"\$HOME/.devcompass/config/zshrc\"" "Zshrc source path is correct"

    assert_equals "2" "$backup_count" "Accepted init created exactly 2 initial backups (.gitconfig + .zshrc)"

    # Check managed snippets exist under ~/.devcompass/config/
    local managed_git="${sandbox_home}/.devcompass/config/gitconfig"
    local managed_zsh="${sandbox_home}/.devcompass/config/zshrc"
    if [[ -f "$managed_git" ]] && [[ -f "$managed_zsh" ]]; then
        assert_equals "snippets_exist" "snippets_exist" "Managed git & zsh snippets created"
    else
        assert_equals "snippets_exist" "snippets_missing" "Managed git & zsh snippets created"
    fi

    # --- 4. Test Idempotency & Snippet Preservation on Rerun ---
    # Customize the managed git snippet to simulate a user edit
    printf "\n# USER CUSTOM GIT ALIAS\n[alias]\n    myalias = status\n" >> "$managed_git"

    local rerun_output
    rerun_output="$(echo "y" | "$CLI" init)"

    assert_contains "$rerun_output" "Preserved user-modified managed Git snippet" "Rerun preserved user-modified managed git snippet"

    local managed_git_content rerun_backup_count git_block_count zsh_block_count
    managed_git_content="$(cat "$managed_git")"
    git_block_count=$(grep -c "# DEVCOMPASS BEGIN" "$git_config" || true)
    zsh_block_count=$(grep -c "# DEVCOMPASS BEGIN" "$zsh_rc" || true)
    rerun_backup_count=$(find "$sandbox_home" -name "*devcompass_backup*" | wc -l | tr -d ' ')

    assert_contains "$managed_git_content" "myalias = status" "User custom edit inside managed snippet was NOT overwritten"
    assert_equals "1" "$git_block_count" "Rerun produced NO duplicate gitconfig block (Count: 1)"
    assert_equals "1" "$zsh_block_count" "Rerun produced NO duplicate zshrc block (Count: 1)"
    assert_equals "2" "$rerun_backup_count" "Rerun created NO unnecessary backup files (Count: 2)"

    # --- 5. Test brew bundle Failure Exits Nonzero (Requirement 1) ---
    export TEST_BREW_BUNDLE_STATUS="fail"
    local brew_fail_output
    set +e
    brew_fail_output="$(echo "y" | "$CLI" init 2>&1)"
    local brew_exit_code=$?
    set -e
    export TEST_BREW_BUNDLE_STATUS="success"

    assert_equals "1" "$brew_exit_code" "brew bundle failure causes devcompass init to exit code 1"
    assert_contains "$brew_fail_output" "Foundation package installation failed via Homebrew bundle" "brew bundle failure error message"
    assert_contains "$brew_fail_output" "Initialization incomplete" "Initialization incomplete notification"

    # --- 6. Test Xcode CLI missing stops installation sequencing ---
    export TEST_XCODE_STATUS="missing"
    local xcode_missing_output
    set +e
    xcode_missing_output="$(echo "y" | "$CLI" init 2>&1)"
    local xcode_exit_code=$?
    set -e
    export TEST_XCODE_STATUS="installed"

    assert_equals "1" "$xcode_exit_code" "Xcode missing halts init with exit code 1"
    assert_contains "$xcode_missing_output" "Xcode Command Line Tools are missing" "Xcode missing error message"
    assert_contains "$xcode_missing_output" "Please complete the installer dialog, then rerun 'devcompass init'" "Xcode rerun instruction"

    export PATH="$ORIGINAL_PATH"
    export HOME="$ORIGINAL_HOME"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "Init Command & Safety Tests" test_init_safety_and_idempotency
    print_summary
fi
