#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"
CLI="${REPO_ROOT}/apps/cli/bin/devcompass"

# shellcheck source=apps/cli/tests/test_runner.sh
source "${TEST_DIR}/test_runner.sh"

test_profiles_feature() {
    local tmp_sandbox
    tmp_sandbox="$(mktemp -d 2>/dev/null || mktemp -d -t 'devcompass_prof_test')"
    local sandbox_home="${tmp_sandbox}/home"
    local bin_dir="${tmp_sandbox}/bin"
    mkdir -p "$sandbox_home" "$bin_dir"
    trap 'rm -rf "${tmp_sandbox:-}"' EXIT

    local ORIGINAL_PATH="$PATH"
    local ORIGINAL_HOME="$HOME"
    export PATH="${bin_dir}:${PATH}"
    export HOME="$sandbox_home"

    # Mock binaries in PATH
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
echo "/Library/Developer/CommandLineTools"
EOF

    cat <<'EOF' > "${bin_dir}/brew"
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then echo "Homebrew 4.2.0"; exit 0; fi
if [[ "${1:-}" == "bundle" ]]; then echo "Homebrew bundle satisfied."; exit 0; fi
EOF

    chmod +x "${bin_dir}"/*

    # --- 1. Test profile list ---
    local list_output
    list_output="$("$CLI" profile list)"
    assert_contains "$list_output" "foundation" "Profile list includes foundation profile"
    assert_contains "$list_output" "web" "Profile list includes web profile"
    assert_contains "$list_output" "data-science" "Profile list includes data-science profile"
    assert_contains "$list_output" "devops" "Profile list includes devops profile"

    # Test profile list --json
    local json_output
    json_output="$("$CLI" profile list --json)"
    assert_contains "$json_output" '"id":"foundation"' "JSON profile list output contains foundation"
    assert_contains "$json_output" '"id":"web"' "JSON profile list output contains web"

    # --- 2. Test profile show <name> ---
    local show_output
    show_output="$("$CLI" profile show web)"
    assert_contains "$show_output" "Web Engineering Profile" "Profile show web display name"
    assert_contains "$show_output" "node" "Profile show web includes node package"

    # Test profile show invalid name -> exit code 1
    assert_exit_code 1 "$CLI" profile show invalidprofile

    # --- 3. Test init --profile <name> --dry-run ---
    local init_dryrun_output
    init_dryrun_output="$("$CLI" init --profile web --dry-run)"
    assert_contains "$init_dryrun_output" "Selected Profile: web" "Init dry-run selects web profile"
    assert_contains "$init_dryrun_output" "Brewfile.web" "Init dry-run uses Brewfile.web"
    assert_contains "$init_dryrun_output" "[DRY-RUN] Execution plan completed" "Init dry-run header present"

    # Verify zero files modified in dry-run
    local backup_count
    backup_count=$(find "$sandbox_home" -name "*devcompass_backup*" | wc -l | tr -d ' ')
    assert_equals "0" "$backup_count" "Init --profile web --dry-run created 0 backups"

    # --- 4. Test init --profile invalidprofile -> exit code 1 ---
    assert_exit_code 1 "$CLI" init --profile invalidprofile

    # --- 5. Test init --profile devops execution ---
    local git_config="${sandbox_home}/.gitconfig"
    printf "[user]\n    name = DevOps User\n" > "$git_config"

    local init_output
    init_output="$(echo "y" | "$CLI" init --profile devops)"
    assert_contains "$init_output" "DevCompass initialization complete for profile 'devops'" "Init --profile devops success"

    local git_content
    git_content="$(cat "$git_config")"
    assert_contains "$git_content" "DevOps User" "Init --profile devops preserved user gitconfig"
    assert_contains "$git_content" "# DEVCOMPASS BEGIN" "Init --profile devops added additive include block"

    export PATH="$ORIGINAL_PATH"
    export HOME="$ORIGINAL_HOME"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_test_suite "Workspace Profiles & Resolution Tests" test_profiles_feature
    print_summary
fi
