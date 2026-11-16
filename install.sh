#!/usr/bin/env bash

# ==============================================================================
# Script: install.sh
# Purpose: Package installer for Arch Linux and CachyOS
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

# Load i18n
source "$SCRIPT_DIR/scripts/lib/i18n.sh"

PARU_TMP_DIR=""

cleanup_resources() {
    if [ -n "$PARU_TMP_DIR" ] && [ -d "$PARU_TMP_DIR" ]; then
        rm -rf "$PARU_TMP_DIR"
    fi
}
trap cleanup_resources EXIT INT TERM

log_info() { echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $1"; }

# ------------------------------------------------------------------------------
# Check OS (Arch Linux or CachyOS)
# ------------------------------------------------------------------------------
check_os() {
    log_info "$(t inst_checking_os)"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "${ID:-}" == "arch" || "${ID_LIKE:-}" == *"arch"* || "${ID:-}" == "cachyos" ]]; then
            log_success "$(t inst_os_valid) ${PRETTY_NAME:-Arch Linux}"
        else
            log_error "$(t inst_os_error)"
            log_error "Current OS: ${PRETTY_NAME:-Unknown}"
            exit 1
        fi
    else
        log_error "File /etc/os-release not found. Cannot determine OS."
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
                sudo pacman -S --needed --noconfirm gnome gnome-tweaks gdm
                sudo systemctl enable gdm
                log_success "$(t inst_de_done)"
                ;;
            *)
                log_info "$(t inst_de_skip)"
                ;;
        esac
    fi
}

# ------------------------------------------------------------------------------
# Bootstrap Paru (AUR Helper) if not found
# ------------------------------------------------------------------------------
bootstrap_paru() {
    if command -v paru &> /dev/null; then
        log_success "$(t inst_paru_found) $(command -v paru)"
        return 0
    fi

    log_warning "$(t inst_paru_missing)"
    log_info "$(t inst_paru_deps)"
    sudo pacman -S --needed --noconfirm base-devel git

    PARU_TMP_DIR="$(mktemp -d /tmp/paru-bootstrap.XXXXXX)"
    log_info "$(t inst_paru_cloning) $PARU_TMP_DIR"
    git clone https://aur.archlinux.org/paru-bin.git "$PARU_TMP_DIR"

    (
        cd "$PARU_TMP_DIR" || exit 1
        makepkg -si --noconfirm
    )

    rm -rf "$PARU_TMP_DIR"
    PARU_TMP_DIR=""

    if command -v paru &> /dev/null; then
        log_success "$(t inst_paru_success)"
    else
        log_error "$(t inst_paru_failed)"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Flatpak & Flathub setup
# ------------------------------------------------------------------------------
setup_flatpak() {
    log_info "$(t inst_flatpak_check)"
    if ! command -v flatpak &> /dev/null; then
        log_info "$(t inst_flatpak_installing)"
        paru -S --needed --noconfirm flatpak
    fi

    log_info "$(t inst_flatpak_remote)"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    log_success "$(t inst_flatpak_done)"
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
    BEGIN { in_pacman=0; in_flatpak=0 }
    /^## Pacman \/ AUR/ { in_pacman=1; in_flatpak=0; next }
    /^## Flatpak/       { in_pacman=0; in_flatpak=1; next }
    /^## /              { in_pacman=0; in_flatpak=0 }

    target == "pacman" && in_pacman && /^[ \t]*-[ \t]*`/ {
        match($0, /`[^`]+`/)
        pkg = substr($0, RSTART+1, RLENGTH-2)
        print pkg
    }

    target == "flatpak" && in_flatpak && /^[ \t]*-[ \t]*`/ {
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
    BEGIN { in_pacman=0; in_flatpak=0 }
    /^## Pacman \/ AUR/ { in_pacman=1; in_flatpak=0; next }
    /^## Flatpak/       { in_pacman=0; in_flatpak=1; next }
    /^## /              { in_pacman=0; in_flatpak=0 }

    target == "pacman" && in_pacman && /^[ \t]*-[ \t]*`/ {
        match($0, /`[^`]+`/)
        pkg = substr($0, RSTART+1, RLENGTH-2)
        desc = substr($0, RSTART+RLENGTH)
        sub(/^[ \t]*[-:]*[ \t]*/, "", desc)
        print pkg "::" desc
    }

    target == "flatpak" && in_flatpak && /^[ \t]*-[ \t]*`/ {
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
    local pacman_items=()
    local flatpak_items=()

    for file_name in "${files[@]}"; do
        local full_path="$PACKAGES_DIR/$file_name"
        if [ -f "$full_path" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && pacman_items+=("$line")
            done < <(extract_packages_with_desc "$full_path" "pacman")

            while IFS= read -r line; do
                [ -n "$line" ] && flatpak_items+=("$line")
            done < <(extract_packages_with_desc "$full_path" "flatpak")
        fi
    done

    echo ""
    echo -e "${COLOR_CYAN}================================================================${COLOR_RESET}"
    echo -e "${COLOR_BOLD}         $(t inst_confirm_title)           ${COLOR_RESET}"
    echo -e "${COLOR_CYAN}================================================================${COLOR_RESET}"

    if [ ${#pacman_items[@]} -gt 0 ]; then
        echo -e "\n${COLOR_YELLOW}[ Pacman / AUR ] (${#pacman_items[@]} packages):${COLOR_RESET}"
        local idx=1
        for item in "${pacman_items[@]}"; do
            local pkg="${item%%::*}"
            local desc="${item#*::}"
            printf "  %2d. ${COLOR_GREEN}%-25s${COLOR_RESET} : %s\n" "$idx" "$pkg" "$desc"
            ((idx++))
        done
    fi

    if [ ${#flatpak_items[@]} -gt 0 ]; then
        echo -e "\n${COLOR_YELLOW}[ Flatpak / Flathub ] (${#flatpak_items[@]} apps):${COLOR_RESET}"
        local fidx=1
        for item in "${flatpak_items[@]}"; do
            local pkg="${item%%::*}"
            local desc="${item#*::}"
            printf "  %2d. ${COLOR_GREEN}%-25s${COLOR_RESET} : %s\n" "$fidx" "$pkg" "$desc"
            ((fidx++))
        done
    fi

    echo ""
    echo -e "${COLOR_CYAN}----------------------------------------------------------------${COLOR_RESET}"
    echo -e "Total: ${COLOR_GREEN}${#pacman_items[@]} Pacman/AUR packages${COLOR_RESET} and ${COLOR_GREEN}${#flatpak_items[@]} Flatpak apps${COLOR_RESET}."
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

    # 1. Pacman / AUR
    mapfile -t pacman_pkgs < <(extract_packages_from_md "$full_path" "pacman")
    if [ ${#pacman_pkgs[@]} -gt 0 ]; then
        log_info "Installing ${#pacman_pkgs[@]} Pacman/AUR packages via paru..."
        paru -S --needed --noconfirm "${pacman_pkgs[@]}"
        log_success "Finished installing Pacman/AUR packages for $category_name."
    fi

    # 2. Flatpak
    mapfile -t flatpak_pkgs < <(extract_packages_from_md "$full_path" "flatpak")
    if [ ${#flatpak_pkgs[@]} -gt 0 ]; then
        for app in "${flatpak_pkgs[@]}"; do
            log_info "Installing Flatpak: $app..."
            flatpak install -y flathub "$app"
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
            paru -Sc --noconfirm
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
                bootstrap_paru
                setup_flatpak
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
                bootstrap_paru
                setup_flatpak
                install_from_file "manager.md" "Manager"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        3)
            check_os
            if confirm_installation "work.md"; then
                bootstrap_paru
                install_from_file "work.md" "Work"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        4)
            check_os
            if confirm_installation "social.md"; then
                bootstrap_paru
                setup_flatpak
                install_from_file "social.md" "Social"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        5)
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
                bootstrap_paru
                setup_flatpak
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
                bootstrap_paru
                setup_flatpak
                install_from_file "manager.md" "Manager"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        work)
            check_os
            if confirm_installation "work.md"; then
                bootstrap_paru
                install_from_file "work.md" "Work"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        social)
            check_os
            if confirm_installation "social.md"; then
                bootstrap_paru
                setup_flatpak
                install_from_file "social.md" "Social"
                cleanup_package_cache
                prompt_setup_sh
            fi
            ;;
        check)
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
