#!/usr/bin/env bash

# ==============================================================================
# Script: install.sh
# Purpose: Multi-distribution Package Installer
#          Supports: Arch Linux/CachyOS (Pacman/Paru), Debian/Ubuntu (APT), Fedora (DNF)
#          Reads package lists from:
#          - packages/manager.md
#          - packages/work.md
#          - packages/social.md
# ==============================================================================

set -uo pipefail

COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/packages"

# Load i18n & package manager adapter
source "$SCRIPT_DIR/scripts/lib/i18n.sh"
source "$SCRIPT_DIR/scripts/lib/pkg_adapter.sh"

log_info() { echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $1"; }

# ------------------------------------------------------------------------------
# Check Operating System and Package Manager
# ------------------------------------------------------------------------------
check_os() {
    log_info "$(t inst_checking_os)"
    if detect_system; then
        log_success "$(t inst_os_valid) $DETECTED_OS_NAME ($DETECTED_OS_ID)"
        log_info "$(t inst_detected_family) ${COLOR_GREEN}${DETECTED_FAMILY}${COLOR_RESET}"
        log_info "$(t inst_detected_pkg_mgr) ${COLOR_CYAN}${DETECTED_PKG_MGR}${COLOR_RESET}"
    else
        log_error "$(t inst_os_error)"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Check Desktop Environment (GNOME). Auto-offer install if missing.
# ------------------------------------------------------------------------------
check_desktop_environment() {
    if ! command -v gnome-shell &> /dev/null && ! command -v hyprland &> /dev/null; then
        echo ""
        log_warning "$(t inst_de_warn)"
        read -rp "$(t inst_de_prompt)" install_de
        install_de="${install_de:-Y}"
        case "$install_de" in
            [yY]|[yY][eE][sS])
                log_info "$(t inst_de_installing)"
                case "$DETECTED_FAMILY" in
                    arch)
                        sudo pacman -S --needed --noconfirm gnome gnome-tweaks gdm
                        sudo systemctl enable gdm
                        ;;
                    debian)
                        sudo apt-get install -y ubuntu-desktop-minimal gnome-tweaks gdm3 2>/dev/null || sudo apt-get install -y gnome-shell gnome-tweaks gdm3
                        sudo systemctl enable gdm3 2>/dev/null || sudo systemctl enable gdm || true
                        ;;
                    fedora)
                        sudo dnf groupinstall -y "GNOME Desktop Environment" 2>/dev/null || sudo dnf install -y gnome-shell gnome-tweaks gdm
                        sudo systemctl enable gdm || true
                        ;;
                esac
                log_success "$(t inst_de_done)"
                ;;
            *)
                log_info "$(t inst_de_skip)"
                ;;
        esac
    fi
}

# ------------------------------------------------------------------------------
# Flatpak & Flathub setup (Optional)
# ------------------------------------------------------------------------------
setup_flatpak() {
    log_info "$(t inst_flatpak_check)"
    if ! command -v flatpak &> /dev/null; then
        log_info "$(t inst_flatpak_installing)"
        case "$DETECTED_FAMILY" in
            arch)
                paru -S --needed --noconfirm flatpak
                ;;
            debian)
                sudo apt-get install -y flatpak
                ;;
            fedora)
                sudo dnf install -y flatpak
                ;;
        esac
    fi

    if command -v flatpak &> /dev/null; then
        log_info "$(t inst_flatpak_remote)"
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
        log_success "$(t inst_flatpak_done)"
    fi
}

# ------------------------------------------------------------------------------
# Parse packages from markdown using AWK
# ------------------------------------------------------------------------------
extract_packages_from_md() {
    local md_file="$1"
    local target_section="$2"

    if [ ! -f "$md_file" ]; then
        return 1
    fi

    awk -v target="$target_section" '
    BEGIN { cur="" }
    /^## (Pacman|Arch)/           { cur="pacman"; next }
    /^## (APT|Debian|Ubuntu)/     { cur="apt"; next }
    /^## (DNF|Fedora)/            { cur="dnf"; next }
    /^## Flatpak/                 { cur="flatpak"; next }
    /^## /                        { cur="" }

    target == cur && /^[ \t]*-[ \t]*`/ {
        match($0, /`[^`]+`/)
        pkg = substr($0, RSTART+1, RLENGTH-2)
        print pkg
    }
    ' "$md_file"
}

# ------------------------------------------------------------------------------
# Parse packages with descriptions for preview list
# ------------------------------------------------------------------------------
extract_packages_with_desc() {
    local md_file="$1"
    local target_section="$2"

    if [ ! -f "$md_file" ]; then
        return 1
    fi

    awk -v target="$target_section" '
    BEGIN { cur="" }
    /^## (Pacman|Arch)/           { cur="pacman"; next }
    /^## (APT|Debian|Ubuntu)/     { cur="apt"; next }
    /^## (DNF|Fedora)/            { cur="dnf"; next }
    /^## Flatpak/                 { cur="flatpak"; next }
    /^## /                        { cur="" }

    target == cur && /^[ \t]*-[ \t]*`/ {
        match($0, /`[^`]+`/)
        pkg = substr($0, RSTART+1, RLENGTH-2)
        desc = substr($0, RSTART+RLENGTH)
        sub(/^[ \t]*[-:]*[ \t]*/, "", desc)
        print pkg "::" desc
    }
    ' "$md_file"
}

# ------------------------------------------------------------------------------
# Numbered list preview
# ------------------------------------------------------------------------------
display_packages_list() {
    local files=("$@")
    local native_items=()
    local flatpak_items=()

    [ -z "$DETECTED_PKG_MGR" ] && detect_system

    for file_name in "${files[@]}"; do
        local full_path="$PACKAGES_DIR/$file_name"
        if [ -f "$full_path" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && native_items+=("$line")
            done < <(extract_packages_with_desc "$full_path" "$DETECTED_PKG_MGR")

            while IFS= read -r line; do
                [ -n "$line" ] && flatpak_items+=("$line")
            done < <(extract_packages_with_desc "$full_path" "flatpak")
        fi
    done

    echo ""
    echo -e "${COLOR_CYAN}================================================================${COLOR_RESET}"
    echo -e "${COLOR_BOLD}         $(t inst_confirm_title)           ${COLOR_RESET}"
    echo -e "${COLOR_CYAN}================================================================${COLOR_RESET}"

    local mgr_label
    case "$DETECTED_PKG_MGR" in
        pacman) mgr_label="Pacman / AUR" ;;
        apt) mgr_label="APT (Debian / Ubuntu)" ;;
        dnf) mgr_label="DNF (Fedora)" ;;
        *) mgr_label="Native Packages" ;;
    esac

    if [ ${#native_items[@]} -gt 0 ]; then
        echo -e "\n${COLOR_YELLOW}[ $mgr_label ] (${#native_items[@]} packages):${COLOR_RESET}"
        local idx=1
        for item in "${native_items[@]}"; do
            local pkg="${item%%::*}"
            local desc="${item#*::}"
            printf "  %2d. ${COLOR_GREEN}%-28s${COLOR_RESET} : %s\n" "$idx" "$pkg" "$desc"
            ((idx++))
        done
    fi

    if [ ${#flatpak_items[@]} -gt 0 ]; then
        echo -e "\n${COLOR_YELLOW}[ Flatpak / Flathub (Optional) ] (${#flatpak_items[@]} apps):${COLOR_RESET}"
        local fidx=1
        for item in "${flatpak_items[@]}"; do
            local pkg="${item%%::*}"
            local desc="${item#*::}"
            printf "  %2d. ${COLOR_GREEN}%-28s${COLOR_RESET} : %s\n" "$fidx" "$pkg" "$desc"
            ((fidx++))
        done
    fi

    echo ""
    echo -e "${COLOR_CYAN}----------------------------------------------------------------${COLOR_RESET}"
    echo -e "Total: ${COLOR_GREEN}${#native_items[@]} $mgr_label packages${COLOR_RESET} and ${COLOR_GREEN}${#flatpak_items[@]} Flatpak apps${COLOR_RESET}."
    echo -e "${COLOR_CYAN}================================================================${COLOR_RESET}"
    echo ""
}

confirm_installation() {
    display_packages_list "$@"

    read -rp "$(t inst_confirm_prompt)" confirm_ans
    case "$confirm_ans" in
        [yY]|[yY][eE][sS])
            log_info "$(t inst_confirm_start)"
            return 0
            ;;
        *)
            log_warning "$(t inst_confirm_cancel)"
            return 1
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Install packages from markdown file
# ------------------------------------------------------------------------------
install_from_file() {
    local file_name="$1"
    local category_name="$2"
    local full_path="$PACKAGES_DIR/$file_name"

    echo ""
    log_info "=========================================================="
    log_info "Processing category: ${COLOR_CYAN}${category_name}${COLOR_RESET} ($file_name)"
    log_info "=========================================================="

    if [ ! -f "$full_path" ]; then
        log_error "File not found: $full_path"
        return 1
    fi

    # 1. Native packages via active package manager
    mapfile -t native_pkgs < <(extract_packages_from_md "$full_path" "$DETECTED_PKG_MGR")
    if [ ${#native_pkgs[@]} -gt 0 ]; then
        log_info "Installing ${#native_pkgs[@]} native packages via $DETECTED_PKG_MGR..."
        install_native_packages "${native_pkgs[@]}"
        log_success "Finished installing native packages for $category_name."
    fi

    # Post-install native helpers (uv, pnpm, Nerd Font, Vesktop native deb/rpm)
    post_install_helpers "$category_name"

    # 2. Flatpak (if defined and Flatpak is installed)
    mapfile -t flatpak_pkgs < <(extract_packages_from_md "$full_path" "flatpak")
    if [ ${#flatpak_pkgs[@]} -gt 0 ] && command -v flatpak &> /dev/null; then
        for app in "${flatpak_pkgs[@]}"; do
            log_info "Installing Flatpak: $app..."
            flatpak install -y flathub "$app" 2>/dev/null || true
        done
        log_success "Finished installing Flatpak apps for $category_name."
    fi
}

# ------------------------------------------------------------------------------
# Package cache cleanup
# ------------------------------------------------------------------------------
cleanup_package_cache() {
    echo ""
    read -rp "$(t inst_clean_cache_prompt)" clean_ans
    case "$clean_ans" in
        [yY]|[yY][eE][sS])
            log_info "$(t inst_clean_cache_cleaning)"
            clean_system_cache
            log_success "$(t inst_clean_cache_done)"
            ;;
        *)
            log_info "$(t inst_clean_cache_keep)"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Handoff to setup.sh
# ------------------------------------------------------------------------------
prompt_setup_sh() {
    echo ""
    log_success "Package installation step finished."
    if [ -f "$SCRIPT_DIR/setup.sh" ]; then
        read -rp "$(t inst_setup_prompt)" run_setup
        run_setup="${run_setup:-Y}"
        case "$run_setup" in
            [nN]|[nN][oO])
                log_info "$(t inst_setup_manual)"
                ;;
            *)
                log_info "$(t inst_setup_handoff)"
                "$SCRIPT_DIR/setup.sh" all
                ;;
        esac
    fi
}

toggle_language() {
    if [ "$APP_LANG" == "vi" ]; then
        set_language "en"
    else
        set_language "vi"
    fi
    exec "$0"
}

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------
print_banner() {
    if command -v chafa &> /dev/null && [ -f "$SCRIPT_DIR/assets/avatars/mahihi.png" ]; then
        echo ""
        chafa --size=24x12 "$SCRIPT_DIR/assets/avatars/mahihi.png" 2>/dev/null || true
    fi
    echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
    echo -e "${COLOR_BOLD}       $(t inst_menu_title)               ${COLOR_RESET}"
    echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
}

# ------------------------------------------------------------------------------
# Interactive Menu
# ------------------------------------------------------------------------------
show_menu() {
    print_banner
    echo "$(t inst_menu_prompt)"
    echo "  1) $(t inst_opt_all)"
    echo "  2) $(t inst_opt_manager)"
    echo "  3) $(t inst_opt_work)"
    echo "  4) $(t inst_opt_social)"
    echo "  5) $(t inst_opt_check)"
    echo "  L) $(t inst_opt_lang)"
    echo "  0) $(t exit)"
    echo ""
    read -rp "$(t select_prompt)" choice

    case "$choice" in
        1)
            check_os
            check_desktop_environment
            if confirm_installation "manager.md" "work.md" "social.md"; then
                bootstrap_environment
                install_from_file "manager.md" "Manager"
                install_from_file "work.md" "Work"
                install_from_file "social.md" "Social"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        2)
            check_os
            check_desktop_environment
            if confirm_installation "manager.md"; then
                bootstrap_environment
                install_from_file "manager.md" "Manager"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        3)
            check_os
            if confirm_installation "work.md"; then
                bootstrap_environment
                install_from_file "work.md" "Work"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        4)
            check_os
            if confirm_installation "social.md"; then
                bootstrap_environment
                install_from_file "social.md" "Social"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        5)
            check_os
            display_packages_list "manager.md" "work.md" "social.md"
            ;;
        [lL])
            toggle_language
            ;;
        0)
            log_info "$(t exit)"
            exit 0
            ;;
        *)
            log_error "$(t invalid_choice)"
            exit 1
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Entrypoint: CLI parameters support
# ------------------------------------------------------------------------------
if [ $# -gt 0 ]; then
    case "$1" in
        all)
            check_os
            check_desktop_environment
            if confirm_installation "manager.md" "work.md" "social.md"; then
                bootstrap_environment
                install_from_file "manager.md" "Manager"
                install_from_file "work.md" "Work"
                install_from_file "social.md" "Social"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        manager)
            check_os
            check_desktop_environment
            if confirm_installation "manager.md"; then
                bootstrap_environment
                install_from_file "manager.md" "Manager"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        work)
            check_os
            if confirm_installation "work.md"; then
                bootstrap_environment
                install_from_file "work.md" "Work"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        social)
            check_os
            if confirm_installation "social.md"; then
                bootstrap_environment
                install_from_file "social.md" "Social"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        check)
            check_os
            display_packages_list "manager.md" "work.md" "social.md"
            ;;
        *)
            echo "Usage: $0 [all|manager|work|social|check]"
            exit 1
            ;;
    esac
else
    show_menu
fi
