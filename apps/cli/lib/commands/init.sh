#!/usr/bin/env bash

set -Eeuo pipefail

cmd_init() {
    local is_dry_run="${DEVCOMPASS_DRY_RUN:-false}"
    local root_dir="${DEVCOMPASS_ROOT}"
    local target_home
    target_home="$(get_home_dir)"

    log_bold "🚀 DevCompass Workstation Initialization"
    echo "=================================================="

    # Pre-flight platform guard
    if ! is_macos; then
        log_error "DevCompass init requires macOS."
        return 2
    fi

    log_info "Building initialization plan (Foundation Profile)..."
    echo

    local plan_steps=()

    # Step 1: Xcode CLI Check
    local xcode_missing=false
    if check_xcode_cli >/dev/null 2>&1; then
        plan_steps+=("Skip: Xcode Command Line Tools already installed")
    else
        xcode_missing=true
        plan_steps+=("Install & STOP: Trigger Xcode Command Line Tools installation dialog")
    fi

    # Step 2: Homebrew Check
    if check_homebrew >/dev/null 2>&1; then
        plan_steps+=("Skip: Homebrew already installed")
    else
        plan_steps+=("Install: Homebrew package manager (via official install.sh script)")
    fi

    # Step 3: Foundation Brewfile
    local brewfile="${root_dir}/packages/workstation/brewfiles/Brewfile.foundation"
    plan_steps+=("Install: Foundation Brewfile packages ($brewfile)")

    # Step 4: Baseline Configurations (Additive & Idempotent)
    local git_target="${target_home}/.gitconfig"
    if [[ -f "$git_target" ]] && grep -qF "# DEVCOMPASS BEGIN" "$git_target"; then
        plan_steps+=("Skip: Git config integration already present in $git_target")
    else
        plan_steps+=("Integrate: Additive DevCompass include block into $git_target")
    fi

    local zsh_target="${target_home}/.zshrc"
    if [[ -f "$zsh_target" ]] && grep -qF "# DEVCOMPASS BEGIN" "$zsh_target"; then
        plan_steps+=("Skip: Zsh config integration already present in $zsh_target")
    else
        plan_steps+=("Integrate: Additive DevCompass source block into $zsh_target")
    fi

    log_bold "Execution Plan:"
    for step in "${plan_steps[@]}"; do
        echo "  - $step"
    done
    echo "  - NOTE: macOS system defaults are excluded from the default path (opt-in)."
    echo "=================================================="

    if [[ "$is_dry_run" == "true" ]]; then
        echo
        log_success "[DRY-RUN] Execution plan completed. Zero system changes made."
        return 0
    fi

    # Explicit confirmation required
    echo
    if ! confirm_action "Do you want to proceed with DevCompass Workstation initialization?" "N"; then
        log_warn "Initialization aborted by user."
        return 3
    fi

    echo
    log_info "Executing Workstation setup..."

    # Step 1 execution: Xcode CLI Tools sequencing
    if [[ "$xcode_missing" == "true" ]]; then
        log_info "Triggering Xcode Command Line Tools installation..."
        xcode-select --install 2>/dev/null || log_warn "Xcode CLI installation dialog is already active."
        log_error "Xcode Command Line Tools are missing. Please complete the installer dialog, then rerun 'devcompass init'."
        return 1
    else
        log_success "Xcode Command Line Tools verified."
    fi

    # Step 2 execution: Homebrew
    if ! check_homebrew >/dev/null 2>&1; then
        log_info "Homebrew installer trust boundary: Executing official Homebrew install script..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            log_error "Homebrew installation failed or was interrupted. Please inspect output and rerun."
            return 1
        }
    else
        log_success "Homebrew verified."
    fi

    # Step 3 execution: Brewfile Bundle (Exits nonzero if installation fails)
    if [[ -f "$brewfile" ]]; then
        log_info "Installing foundation packages via Homebrew bundle..."
        if ! brew bundle --file="$brewfile"; then
            log_error "Foundation package installation failed via Homebrew bundle."
            log_error "Initialization incomplete. Please resolve Homebrew issues and rerun 'devcompass init'."
            return 1
        fi
        log_success "Foundation packages installed successfully."
    fi

    # Step 4 execution: Managed Snippets & Additive Integration
    local devcompass_config_dir="${target_home}/.devcompass/config"
    mkdir -p "$devcompass_config_dir"

    # Managed snippet copies (Preserves user customizations, avoids unnecessary rewrites)
    local git_tmpl="${root_dir}/packages/workstation/configs/git/.gitconfig"
    local managed_git="${devcompass_config_dir}/gitconfig"
    if [[ -f "$git_tmpl" ]]; then
        if [[ ! -f "$managed_git" ]]; then
            cp "$git_tmpl" "$managed_git"
            log_info "Created managed Git snippet ($managed_git)"
        elif cmp -s "$git_tmpl" "$managed_git"; then
            log_info "Managed Git snippet is unchanged ($managed_git)"
        else
            log_warn "Preserved user-modified managed Git snippet ($managed_git)"
        fi
    fi

    local zsh_tmpl="${root_dir}/packages/workstation/configs/shell/.zshrc"
    local managed_zsh="${devcompass_config_dir}/zshrc"
    if [[ -f "$zsh_tmpl" ]]; then
        if [[ ! -f "$managed_zsh" ]]; then
            cp "$zsh_tmpl" "$managed_zsh"
            log_info "Created managed Zsh snippet ($managed_zsh)"
        elif cmp -s "$zsh_tmpl" "$managed_zsh"; then
            log_info "Managed Zsh snippet is unchanged ($managed_zsh)"
        else
            log_warn "Preserved user-modified managed Zsh snippet ($managed_zsh)"
        fi
    fi

    # Additive integration into ~/.gitconfig
    if [[ -f "$git_target" ]] && grep -qF "# DEVCOMPASS BEGIN" "$git_target"; then
        log_success "Git config integration already present ($git_target)"
    else
        backup_file "$git_target"
        printf "\n# DEVCOMPASS BEGIN\n[include]\n    path = ~/.devcompass/config/gitconfig\n# DEVCOMPASS END\n" >> "$git_target"
        log_success "Integrated DevCompass snippet into Git config ($git_target)"
    fi

    # Additive integration into ~/.zshrc
    if [[ -f "$zsh_target" ]] && grep -qF "# DEVCOMPASS BEGIN" "$zsh_target"; then
        log_success "Zsh config integration already present ($zsh_target)"
    else
        backup_file "$zsh_target"
        printf "\n# DEVCOMPASS BEGIN\nif [[ -f \"\$HOME/.devcompass/config/zshrc\" ]]; then\n    source \"\$HOME/.devcompass/config/zshrc\"\nfi\n# DEVCOMPASS END\n" >> "$zsh_target"
        log_success "Integrated DevCompass snippet into Zsh config ($zsh_target)"
    fi

    echo "=================================================="
    log_success "DevCompass Workstation initialization complete."
    return 0
}
