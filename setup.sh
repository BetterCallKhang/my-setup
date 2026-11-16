#!/usr/bin/env bash

# ==============================================================================
# Script: setup.sh
# Purpose: Configuration linker, theme applier and services controller
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
CONFIGS_SRC="$SCRIPT_DIR/configs"
ASSETS_DIR="$SCRIPT_DIR/assets"
TARGET_DIR="$HOME/.config"

# Load i18n & theme dotfile helper
source "$SCRIPT_DIR/scripts/lib/i18n.sh"
source "$SCRIPT_DIR/scripts/lib/theme_apply.sh"

log_info() { echo -e "${COLOR_BLUE}$(t info)${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}$(t success)${COLOR_RESET} $1"; }
log_warning() { echo -e "${COLOR_YELLOW}$(t warning)${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}$(t error)${COLOR_RESET} $1"; }

create_symlink() {
    local src="$1"
    local dest="$2"

    local parent_dir
    parent_dir="$(dirname "$dest")"
    mkdir -p "$parent_dir" 2>/dev/null || true

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]; then
            log_info "$(t link_exists) $dest -> $src"
            return 0
        fi

        local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        log_warning "$(t link_backup) $backup"
        mv "$dest" "$backup"
    fi

    if ln -sfn "$src" "$dest"; then
        log_success "$(t link_success) $dest -> $src"
    else
        log_error "$(t link_failed) $dest"
        return 1
    fi
}

link_all_configs() {
    echo ""
    log_info "$(t link_start)"

    if [ ! -d "$CONFIGS_SRC" ]; then
        log_error "Directory not found: $CONFIGS_SRC"
        return 1
    fi

    local count=0
    while IFS= read -r file_path; do
        [ ! -f "$file_path" ] && continue
        local rel_path="${file_path#$CONFIGS_SRC/}"
        [ "$(basename "$rel_path")" == ".gitkeep" ] && continue

        local dest_path="$TARGET_DIR/$rel_path"
        create_symlink "$file_path" "$dest_path"
        ((count++))
    done < <(find "$CONFIGS_SRC" -type f | sort)

    log_success "$(t link_total) $count"
}

setup_default_ui() {
    echo ""
    log_info "Setting up default desktop themes and dotfiles..."

    local ICONS_DIR="$HOME/.local/share/icons"
    local WALLPAPERS_DIR="$HOME/.local/share/backgrounds"
    mkdir -p "$ICONS_DIR" "$WALLPAPERS_DIR" 2>/dev/null || true

    # Wallpapers
    if [ -d "$ASSETS_DIR/wallpapers/images" ]; then
        cp -u "$ASSETS_DIR/wallpapers/images"/* "$WALLPAPERS_DIR/" 2>/dev/null || cp "$ASSETS_DIR/wallpapers/images"/* "$WALLPAPERS_DIR/" 2>/dev/null || true
        local DEFAULT_BG="$WALLPAPERS_DIR/127212220_p0.png"
        if [ ! -f "$DEFAULT_BG" ]; then
            DEFAULT_BG="$(find "$WALLPAPERS_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | head -n 1)"
        fi
        if [ -n "$DEFAULT_BG" ] && command -v gsettings &> /dev/null; then
            gsettings set org.gnome.desktop.background picture-uri "file://$DEFAULT_BG" 2>/dev/null || true
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$DEFAULT_BG" 2>/dev/null || true
            log_success "Wallpaper set to $(basename "$DEFAULT_BG")"
        fi
    fi

    # User avatar
    if [ -f "$ASSETS_DIR/avatars/mahihi.png" ]; then
        cp "$ASSETS_DIR/avatars/mahihi.png" "$HOME/.face" 2>/dev/null || true
    fi

    # Default Candy Icons + Dotfiles
    if [ ! -d "$ICONS_DIR/candy-icons" ] && [ ! -d "/usr/share/icons/candy-icons" ]; then
        log_info "Downloading Candy Icons from GitHub..."
        git clone --depth=1 https://github.com/EliverLara/candy-icons.git "$ICONS_DIR/candy-icons" 2>/dev/null || true
    fi
    apply_icon_dotfile "candy-icons"
    log_success "$(t icon_applied) candy-icons"

    # Default Oreo Cursors + Dotfiles
    if [ ! -d "$ICONS_DIR/oreo_spark_pink_cursors" ] && [ ! -d "/usr/share/icons/oreo_spark_pink_cursors" ]; then
        if command -v paru &> /dev/null; then
            log_info "Installing oreo-cursors-git via paru..."
            paru -S --needed --noconfirm oreo-cursors-git 2>/dev/null || true
        fi
    fi
    apply_cursor_dotfile "oreo_spark_pink_cursors"
    log_success "$(t cursor_applied) oreo_spark_pink_cursors"

    # GNOME font & Flameshot shortcut
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface font-name 'Inter 11' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true

        if command -v flameshot &> /dev/null; then
            local BIND_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/"
            gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$BIND_PATH name 'Flameshot' 2>/dev/null || true
            gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$BIND_PATH command 'flameshot gui' 2>/dev/null || true
            gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$BIND_PATH binding 'Print' 2>/dev/null || true
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$BIND_PATH']" 2>/dev/null || true
        fi
    fi
}

setup_docker() {
    echo ""
    log_info "$(t docker_setup)"
    if command -v docker &> /dev/null; then
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
        log_success "$(t docker_done)"
    else
        log_warning "Docker not installed."
    fi
}

setup_warp() {
    echo ""
    log_info "$(t warp_setup)"
    if command -v warp-cli &> /dev/null || pacman -Qq cloudflare-warp-bin &> /dev/null 2>&1; then
        sudo systemctl enable --now warp-svc
        log_success "$(t warp_done)"
    else
        log_warning "Cloudflare WARP not installed."
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

print_banner() {
    if command -v chafa &> /dev/null && [ -f "$ASSETS_DIR/avatars/mahihi.png" ]; then
        echo ""
        chafa --size=24x12 "$ASSETS_DIR/avatars/mahihi.png" 2>/dev/null || true
    fi
    echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
    echo -e "${COLOR_BOLD}         $(t setup_banner)                    ${COLOR_RESET}"
    echo -e "${COLOR_CYAN}==================================================================${COLOR_RESET}"
}

show_menu() {
    print_banner
    echo "Options:"
    echo "  1) $(t setup_opt_all)"
    echo "  2) $(t setup_opt_links)"
    echo "  3) $(t setup_opt_cursors)"
    echo "  4) $(t setup_opt_icons)"
    echo "  5) $(t setup_opt_wallpapers)"
    echo "  6) $(t setup_opt_grub)"
    echo "  7) $(t setup_opt_services)"
    echo "  L) $(t setup_opt_lang)"
    echo "  0) $(t exit)"
    echo ""
    read -rp "$(t select_prompt)" choice

    case "$choice" in
        1)
            link_all_configs
            setup_default_ui
            setup_docker
            setup_warp
            echo ""
            log_success "$(t setup_done)"
            ;;
        2) link_all_configs ;;
        3) "$SCRIPT_DIR/scripts/cursors.sh" ;;
        4) "$SCRIPT_DIR/scripts/icons.sh" ;;
        5) "$SCRIPT_DIR/scripts/wallpapers.sh" ;;
        6) "$SCRIPT_DIR/scripts/grub.sh" ;;
        7) setup_docker; setup_warp ;;
        [lL]) toggle_language ;;
        0) log_info "$(t exit)"; exit 0 ;;
        *) log_error "$(t invalid_choice)"; exit 1 ;;
    esac
}

if [ $# -gt 0 ]; then
    case "$1" in
        all)
            link_all_configs
            setup_default_ui
            setup_docker
            setup_warp
            ;;
        links) link_all_configs ;;
        cursors) "$SCRIPT_DIR/scripts/cursors.sh" ;;
        icons) "$SCRIPT_DIR/scripts/icons.sh" ;;
        wallpapers) "$SCRIPT_DIR/scripts/wallpapers.sh" ;;
        grub) "$SCRIPT_DIR/scripts/grub.sh" ;;
        services) setup_docker; setup_warp ;;
        *)
            echo "Usage: $0 [all|links|cursors|icons|wallpapers|grub|services]"
            exit 1
            ;;
    esac
else
    show_menu
fi
