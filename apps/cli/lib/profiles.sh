#!/usr/bin/env bash

set -Eeuo pipefail

get_profiles_dir() {
    printf '%s\n' "${DEVCOMPASS_ROOT}/packages/profiles/definitions"
}

profile_field_count() {
    local yaml_file="$1"
    local field_name="$2"
    awk -v field="${field_name}:" 'index($0, field) == 1 { count++ } END { print count + 0 }' "$yaml_file"
}

get_profile_field() {
    local yaml_file="$1"
    local field_name="$2"
    local value

    value="$(awk -v field="${field_name}:" 'index($0, field) == 1 { print substr($0, length(field) + 1); exit }' "$yaml_file")"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    if [[ "$value" == \"*\" && "$value" == *\" ]]; then
        value="${value:1:${#value}-2}"
    fi

    printf '%s\n' "$value"
}

resolve_profile_brewfile() {
    local yaml_file="$1"
    local brewfile_path
    local resolved_path

    brewfile_path="$(get_profile_field "$yaml_file" "brewfile")"
    if [[ -z "$brewfile_path" || "$brewfile_path" == /* || "$brewfile_path" == *".."* ]]; then
        return 1
    fi

    resolved_path="${DEVCOMPASS_ROOT}/${brewfile_path}"
    if [[ ! -f "$resolved_path" ]]; then
        return 1
    fi

    resolved_path="$(cd "$(dirname "$resolved_path")" && pwd -P)/$(basename "$resolved_path")"
    case "$resolved_path" in
        "${DEVCOMPASS_ROOT}"/*)
            printf '%s\n' "$resolved_path"
            ;;
        *)
            return 1
            ;;
    esac
}

validate_profile_file() {
    local yaml_file="$1"
    local field
    local field_value
    local schema_version
    local profile_id
    local expected_filename

    [[ -f "$yaml_file" ]] || return 1

    for field in schema_version id display_name description brewfile; do
        [[ "$(profile_field_count "$yaml_file" "$field")" == "1" ]] || return 1
        field_value="$(get_profile_field "$yaml_file" "$field")"
        [[ -n "$field_value" ]] || return 1
        [[ "$field_value" != *$'\t'* && "$field_value" != *$'\r'* && "$field_value" != *$'\n'* ]] || return 1
    done

    schema_version="$(get_profile_field "$yaml_file" "schema_version")"
    [[ "$schema_version" == "1" ]] || return 1

    profile_id="$(get_profile_field "$yaml_file" "id")"
    [[ "$profile_id" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || return 1
    expected_filename="${profile_id}.yaml"
    [[ "$(basename "$yaml_file")" == "$expected_filename" ]] || return 1

    resolve_profile_brewfile "$yaml_file" >/dev/null
}

json_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\t'/\\t}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\n'/\\n}"
    printf '%s' "$value"
}

list_available_profiles() {
    local directory
    local is_json="${1:-false}"
    local file
    local first=true
    local profile_id
    local display_name
    local description

    directory="$(get_profiles_dir)"
    [[ -d "$directory" ]] || {
        log_error "Profiles directory not found: $directory"
        return 1
    }

    if [[ "$is_json" == "true" ]]; then
        printf '[\n'
        for file in "$directory"/*.yaml; do
            validate_profile_file "$file" || continue
            profile_id="$(get_profile_field "$file" "id")"
            display_name="$(get_profile_field "$file" "display_name")"
            description="$(get_profile_field "$file" "description")"
            [[ "$first" == "true" ]] || printf ',\n'
            first=false
            printf '  {"id":"%s","display_name":"%s","description":"%s"}' \
                "$(json_escape "$profile_id")" \
                "$(json_escape "$display_name")" \
                "$(json_escape "$description")"
        done
        printf '\n]\n'
        return 0
    fi

    log_bold "📦 DevCompass Workspace Profiles:"
    echo "=================================================="
    for file in "$directory"/*.yaml; do
        validate_profile_file "$file" || continue
        profile_id="$(get_profile_field "$file" "id")"
        display_name="$(get_profile_field "$file" "display_name")"
        description="$(get_profile_field "$file" "description")"
        printf '  %b%-15s%b %s\n' "${COLOR_BOLD}" "$profile_id" "${COLOR_RESET}" "$display_name"
        printf '                  %s\n\n' "$description"
    done
    echo "Use 'devcompass profile show <id>' for detailed profile specs."
}

show_profile_details() {
    local profile_id="$1"
    local yaml_file
    local brewfile

    yaml_file="$(get_profiles_dir)/${profile_id}.yaml"
    if ! validate_profile_file "$yaml_file"; then
        log_error "Profile '$profile_id' not found or has invalid schema."
        log_info "Run 'devcompass profile list' to view valid profile names."
        return 1
    fi

    brewfile="$(resolve_profile_brewfile "$yaml_file")"
    log_bold "📋 Profile Spec: $(get_profile_field "$yaml_file" "id")"
    echo "=================================================="
    echo "Display Name : $(get_profile_field "$yaml_file" "display_name")"
    echo "Description  : $(get_profile_field "$yaml_file" "description")"
    echo "Brewfile     : $(get_profile_field "$yaml_file" "brewfile")"
    echo
    log_bold "Brew Package Toolset:"
    sed -n -E 's/^brew[[:space:]]+"?([^"[:space:]]+)"?.*/  • \1/p' "$brewfile"
    echo "=================================================="
}
