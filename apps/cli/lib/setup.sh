#!/usr/bin/env bash

set -Eeuo pipefail

get_learning_recipes_dir() {
    printf '%s\n' "${DEVCOMPASS_ROOT}/packages/learning/recipes"
}

get_python_recipe_file() {
    local track="$1"
    local level="$2"
    printf '%s/%s-%s.tsv\n' "$(get_learning_recipes_dir)" "$track" "$level"
}

validate_python_recipe() {
    local recipe_file="$1"
    local package_id
    local package_label
    local package_name

    [[ -f "$recipe_file" ]] || return 1
    [[ "$(head -n 1 "$recipe_file")" == $'id\tlabel\tpackage' ]] || return 1

    while IFS=$'\t' read -r package_id package_label package_name; do
        [[ -n "$package_id" && -n "$package_label" && -n "$package_name" ]] || return 1
        [[ "$package_id" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || return 1
        [[ "$package_name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || return 1
    done < <(tail -n +2 "$recipe_file")
}

python_environment_path() {
    local track="$1"
    local level="$2"
    printf '%s/.devcompass/environments/python-%s-%s\n' "$(get_home_dir)" "$track" "$level"
}

render_python_setup_plan() {
    local track="$1"
    local level="$2"
    local recipe_file="$3"
    local environment_path="$4"
    local package_id
    local package_label
    local package_name

    log_bold "🐍 DevCompass Python Learning Environment"
    echo "=================================================="
    echo "Track       : $track"
    echo "Level       : $level"
    echo "Environment : $environment_path"
    echo "Packages:"
    while IFS=$'\t' read -r package_id package_label package_name; do
        printf '  - %s (%s)\n' "$package_label" "$package_name"
    done < <(tail -n +2 "$recipe_file")
    echo "=================================================="
    echo "This creates an isolated virtual environment; it does not install Python packages globally."
}

install_python_recipe() {
    local recipe_file="$1"
    local environment_path="$2"
    local package_id
    local package_label
    local package_name
    local environment_python="${environment_path}/bin/python"
    local environment_created=false

    if [[ ! -x "$environment_python" ]]; then
        log_info "Creating isolated Python environment..."
        mkdir -p "$(dirname "$environment_path")" || return 1
        python3 -m venv "$environment_path" || return 1
        environment_created=true
    else
        log_info "Python environment already exists; preserving it."
    fi

    if [[ "$environment_created" == "true" ]]; then
        log_info "Updating pip inside the new isolated environment..."
        if ! "$environment_python" -m pip install --upgrade pip; then
            log_error "Python environment was created, but pip initialization failed. Rerun this command to retry."
            return 1
        fi
    fi

    while IFS=$'\t' read -r package_id package_label package_name; do
        log_info "Installing $package_label..."
        if ! "$environment_python" -m pip install "$package_name"; then
            if [[ "$environment_created" == "true" ]]; then
                log_error "Python environment was created, but package installation is incomplete. Rerun this command to continue."
            else
                log_error "Package installation is incomplete. The existing Python environment was preserved; rerun this command to continue."
            fi
            return 1
        fi
    done < <(tail -n +2 "$recipe_file")
}
