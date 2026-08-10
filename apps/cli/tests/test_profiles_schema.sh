#!/usr/bin/env bash

set -Eeuo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TEST_DIR}/../../.." && pwd)"

# shellcheck source=apps/cli/lib/profiles.sh
DEVCOMPASS_ROOT="$REPO_ROOT"
source "${REPO_ROOT}/apps/cli/lib/profiles.sh"

test_profiles_schema() {
    local tmp_dir
    local valid_file
    local invalid_file
    local escaped

    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "${tmp_dir:-}"' EXIT

    valid_file="${tmp_dir}/valid.yaml"
    cat > "$valid_file" <<'EOF'
schema_version: "1"
id: "valid"
display_name: "Valid Profile"
description: "A valid profile"
brewfile: "packages/workstation/brewfiles/Brewfile.foundation"
EOF
    assert_exit_code 0 validate_profile_file "$valid_file"

    valid_file="${tmp_dir}/foundation.yaml"
    cat > "$valid_file" <<'EOF'
schema_version: "1"
id: "foundation"
display_name: "Valid Profile"
description: "A valid profile"
brewfile: "packages/workstation/brewfiles/Brewfile.foundation"
EOF
    assert_exit_code 0 validate_profile_file "$valid_file"

    invalid_file="${tmp_dir}/missing.yaml"
    cat > "$invalid_file" <<'EOF'
schema_version: "1"
id: "missing"
display_name: "Missing field"
description: "No brewfile"
EOF
    assert_exit_code 1 validate_profile_file "$invalid_file"

    invalid_file="${tmp_dir}/wrong-version.yaml"
    cat > "$invalid_file" <<'EOF'
schema_version: "2"
id: "wrong-version"
display_name: "Wrong version"
description: "Unsupported"
brewfile: "packages/workstation/brewfiles/Brewfile.foundation"
EOF
    assert_exit_code 1 validate_profile_file "$invalid_file"

    invalid_file="${tmp_dir}/bad-id.yaml"
    cat > "$invalid_file" <<'EOF'
schema_version: "1"
id: "Bad Id"
display_name: "Bad ID"
description: "Invalid"
brewfile: "packages/workstation/brewfiles/Brewfile.foundation"
EOF
    assert_exit_code 1 validate_profile_file "$invalid_file"

    invalid_file="${tmp_dir}/traversal.yaml"
    cat > "$invalid_file" <<'EOF'
schema_version: "1"
id: "traversal"
display_name: "Traversal"
description: "Invalid"
brewfile: "../Brewfile"
EOF
    assert_exit_code 1 validate_profile_file "$invalid_file"

    escaped="$(json_escape $'quote " slash \\ tab\tline')"
    assert_equals 'quote \" slash \\ tab\tline' "$escaped" "JSON escaping handles quotes, slashes, and tabs"
}
